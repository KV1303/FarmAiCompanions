import 'package:cloud_firestore/cloud_firestore.dart';

class DiseaseReportModel {
  final String id;
  final String userId;
  final String? fieldId;
  final String cropType;
  final String diseaseName;
  final String diseaseDescription;
  final double confidenceScore;
  final List<String> symptoms;
  final List<String> treatments;
  final List<String> preventions;
  final String? imageUrl;
  final DateTime createdAt;

  DiseaseReportModel({
    required this.id,
    required this.userId,
    this.fieldId,
    required this.cropType,
    required this.diseaseName,
    required this.diseaseDescription,
    required this.confidenceScore,
    required this.symptoms,
    required this.treatments,
    required this.preventions,
    this.imageUrl,
    required this.createdAt,
  });

  // Create from Firestore document
  factory DiseaseReportModel.fromFirestore(Map<String, dynamic> data, String id) {
    return DiseaseReportModel(
      id: id,
      userId: data['userId'] ?? '',
      fieldId: data['fieldId'],
      cropType: data['cropType'] ?? '',
      diseaseName: data['diseaseName'] ?? '',
      diseaseDescription: data['diseaseDescription'] ?? '',
      confidenceScore: (data['confidenceScore'] ?? 0.0).toDouble(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      treatments: List<String>.from(data['treatments'] ?? []),
      preventions: List<String>.from(data['preventions'] ?? []),
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fieldId': fieldId,
      'cropType': cropType,
      'diseaseName': diseaseName,
      'diseaseDescription': diseaseDescription,
      'confidenceScore': confidenceScore,
      'symptoms': symptoms,
      'treatments': treatments,
      'preventions': preventions,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}