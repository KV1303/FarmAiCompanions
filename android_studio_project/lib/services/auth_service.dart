import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart' as app_models;
import '../constants/app_constants.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();
  
  // Sign in with email and password
  Future<firebase_auth.User?> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      throw Exception('Failed to sign in. Please try again.');
    }
  }
  
  // Register a new user with email and password
  Future<firebase_auth.User?> signUp(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for this email.');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      throw Exception('Failed to register. Please try again.');
    }
  }
  
  // Create a new user in Firestore after registration
  Future<app_models.User?> createUser(
    String uid,
    String name,
    String email,
    String phone,
    String location,
  ) async {
    try {
      // Use a random location in India for demo purposes
      // In a real app, this would come from device GPS or user input
      final Random random = Random();
      final double latitude = 20.5937 + (random.nextDouble() * 8.0); // India range
      final double longitude = 73.9629 + (random.nextDouble() * 10.0); // India range
      
      final user = app_models.User(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        location: location,
        latitude: latitude,
        longitude: longitude,
        preferredLanguage: 'en',
        fieldIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(uid).set(user.toJson());
      
      return user;
    } catch (e) {
      debugPrint('Create user error: $e');
      return null;
    }
  }
  
  // Get user data from Firestore
  Future<app_models.User?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        return app_models.User.fromJson(doc.data()!);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }
  
  // Update user profile in Firestore
  Future<app_models.User?> updateUserProfile(
    String uid,
    String name,
    String phone,
    String location,
  ) async {
    try {
      // Get current user data first
      final currentUserDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!currentUserDoc.exists || currentUserDoc.data() == null) {
        return null;
      }
      
      final currentUser = app_models.User.fromJson(currentUserDoc.data()!);
      
      // Update with new data
      final updatedUser = currentUser.copyWith(
        name: name,
        phone: phone,
        location: location,
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore.collection('users').doc(uid).update(updatedUser.toJson());
      
      return updatedUser;
    } catch (e) {
      debugPrint('Update user profile error: $e');
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email.');
      } else {
        throw Exception('Password reset failed: ${e.message}');
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      throw Exception('Failed to reset password. Please try again.');
    }
  }
}
