import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Constants
  static const String TRIAL_DAYS = 7;
  static const String SUBSCRIPTION_PRICE = '₹99';
  static const String SUBSCRIPTION_PERIOD = 'yearly';
  
  // Method to check if a user has an active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      if (_auth.currentUser == null) return false;
      
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (!doc.exists) return false;
      
      final userData = doc.data();
      if (userData == null) return false;
      
      // Check if user is subscribed
      if (userData['isSubscribed'] == true) {
        // Check subscription end date if available
        if (userData['subscriptionEndDate'] != null) {
          final endDate = (userData['subscriptionEndDate'] as Timestamp).toDate();
          return DateTime.now().isBefore(endDate);
        }
        return true; // If no end date but marked as subscribed
      }
      
      return false;
    } catch (e) {
      print('Error checking subscription: $e');
      return false;
    }
  }
  
  // Method to check if user is in free trial period
  Future<bool> isInTrialPeriod() async {
    try {
      if (_auth.currentUser == null) return false;
      
      // Check if trial has already been used
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasUsedTrial = prefs.getBool('${_auth.currentUser!.uid}_trial_used') ?? false;
      if (hasUsedTrial) return false;
      
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (!doc.exists) {
        // If user document doesn't exist, they might be new
        final user = _auth.currentUser!;
        final createTime = user.metadata.creationTime;
        
        if (createTime != null) {
          final trialEndTime = createTime.add(Duration(days: TRIAL_DAYS));
          return DateTime.now().isBefore(trialEndTime);
        }
      } else {
        // Check if trial info exists in user document
        final userData = doc.data();
        if (userData != null && userData['trialEndDate'] != null) {
          final trialEndDate = (userData['trialEndDate'] as Timestamp).toDate();
          return DateTime.now().isBefore(trialEndDate);
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking trial period: $e');
      return false;
    }
  }
  
  // Method to get subscription status and details
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      bool isSubscribed = await hasActiveSubscription();
      bool isInTrial = !isSubscribed && await isInTrialPeriod();
      
      // Get subscription end date if subscribed
      String? endDate;
      if (isSubscribed && _auth.currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        
        if (doc.exists) {
          final userData = doc.data();
          if (userData != null && userData['subscriptionEndDate'] != null) {
            final date = (userData['subscriptionEndDate'] as Timestamp).toDate();
            endDate = '${date.day}/${date.month}/${date.year}';
          }
        }
      }
      
      // Get trial end date if in trial
      String? trialEndDate;
      if (isInTrial && _auth.currentUser != null) {
        DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
        
        if (doc.exists) {
          final userData = doc.data();
          if (userData != null && userData['trialEndDate'] != null) {
            final date = (userData['trialEndDate'] as Timestamp).toDate();
            trialEndDate = '${date.day}/${date.month}/${date.year}';
          } else {
            // Calculate from user creation time
            final user = _auth.currentUser!;
            final createTime = user.metadata.creationTime;
            if (createTime != null) {
              final date = createTime.add(Duration(days: TRIAL_DAYS));
              trialEndDate = '${date.day}/${date.month}/${date.year}';
            }
          }
        }
      }
      
      return {
        'isSubscribed': isSubscribed,
        'isInTrial': isInTrial,
        'subscriptionEndDate': endDate,
        'trialEndDate': trialEndDate,
        'price': SUBSCRIPTION_PRICE,
        'period': SUBSCRIPTION_PERIOD,
      };
    } catch (e) {
      print('Error getting subscription status: $e');
      return {
        'isSubscribed': false,
        'isInTrial': false,
        'error': e.toString(),
      };
    }
  }
  
  // Method to mark trial as used (for new signups)
  Future<void> initializeTrialPeriod() async {
    try {
      if (_auth.currentUser == null) return;
      
      // Check if user document exists
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (!doc.exists || doc.data()?['trialEndDate'] == null) {
        // Calculate trial end date
        final trialEndDate = DateTime.now().add(Duration(days: TRIAL_DAYS));
        
        // Update user document
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .set({
              'trialEndDate': Timestamp.fromDate(trialEndDate),
              'isSubscribed': false,
            }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error initializing trial period: $e');
    }
  }
  
  // Method to handle payment completion and activate subscription
  Future<void> activateSubscription() async {
    try {
      if (_auth.currentUser == null) return;
      
      // Calculate subscription end date (1 year from now)
      final subscriptionEndDate = DateTime.now().add(Duration(days: 365));
      
      // Update user document
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({
            'isSubscribed': true,
            'subscriptionEndDate': Timestamp.fromDate(subscriptionEndDate),
            'subscriptionActivatedAt': Timestamp.fromDate(DateTime.now()),
          }, SetOptions(merge: true));
      
      // Mark trial as used
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_auth.currentUser!.uid}_trial_used', true);
    } catch (e) {
      print('Error activating subscription: $e');
      throw Exception('Failed to activate subscription: $e');
    }
  }
}