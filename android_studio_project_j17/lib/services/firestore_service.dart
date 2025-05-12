import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_auth.currentUser == null) return null;
      
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        return doc.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Save user data to Firestore
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      if (_auth.currentUser == null) return;
      
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }
  
  // Get user fields
  Future<List<Map<String, dynamic>>> getUserFields() async {
    try {
      if (_auth.currentUser == null) return [];
      
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('fields')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user fields: $e');
      return [];
    }
  }
  
  // Add a new field
  Future<String> addField(Map<String, dynamic> fieldData) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');
      
      // Ensure userId is set
      fieldData['userId'] = _auth.currentUser!.uid;
      fieldData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference doc = await _firestore
          .collection('fields')
          .add(fieldData);
      
      return doc.id;
    } catch (e) {
      print('Error adding field: $e');
      rethrow;
    }
  }
  
  // Update a field
  Future<void> updateField(String fieldId, Map<String, dynamic> fieldData) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');
      
      fieldData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('fields')
          .doc(fieldId)
          .update(fieldData);
    } catch (e) {
      print('Error updating field: $e');
      rethrow;
    }
  }
  
  // Delete a field
  Future<void> deleteField(String fieldId) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');
      
      await _firestore
          .collection('fields')
          .doc(fieldId)
          .delete();
    } catch (e) {
      print('Error deleting field: $e');
      rethrow;
    }
  }
  
  // Get disease reports
  Future<List<Map<String, dynamic>>> getDiseaseReports() async {
    try {
      if (_auth.currentUser == null) return [];
      
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('diseaseReports')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting disease reports: $e');
      return [];
    }
  }
  
  // Add a new disease report
  Future<String> addDiseaseReport(Map<String, dynamic> reportData) async {
    try {
      if (_auth.currentUser == null) throw Exception('User not authenticated');
      
      // Ensure userId is set
      reportData['userId'] = _auth.currentUser!.uid;
      reportData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference doc = await _firestore
          .collection('diseaseReports')
          .add(reportData);
      
      return doc.id;
    } catch (e) {
      print('Error adding disease report: $e');
      rethrow;
    }
  }
}