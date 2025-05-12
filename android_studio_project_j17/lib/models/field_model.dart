import 'package:cloud_firestore/cloud_firestore.dart';

class FieldModel {
  final String id;
  final String userId;
  final String name;
  final double area;
  final String areaUnit;
  final String cropType;
  final String soilType;
  final String? location;
  final GeoPoint? coordinates;
  final String? irrigationSystem;
  final String? growthStage;
  final DateTime? plantingDate;
  final DateTime? harvestDate;
  final Map<String, dynamic>? soilTestResults;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FieldModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.area,
    required this.areaUnit,
    required this.cropType,
    required this.soilType,
    this.location,
    this.coordinates,
    this.irrigationSystem,
    this.growthStage,
    this.plantingDate,
    this.harvestDate,
    this.soilTestResults,
    required this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore document
  factory FieldModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FieldModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      area: (data['area'] ?? 0).toDouble(),
      areaUnit: data['areaUnit'] ?? 'एकड़',
      cropType: data['cropType'] ?? '',
      soilType: data['soilType'] ?? '',
      location: data['location'],
      coordinates: data['coordinates'],
      irrigationSystem: data['irrigationSystem'],
      growthStage: data['growthStage'],
      plantingDate: data['plantingDate'] != null 
          ? (data['plantingDate'] as Timestamp).toDate()
          : null,
      harvestDate: data['harvestDate'] != null 
          ? (data['harvestDate'] as Timestamp).toDate()
          : null,
      soilTestResults: data['soilTestResults'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'area': area,
      'areaUnit': areaUnit,
      'cropType': cropType,
      'soilType': soilType,
      'location': location,
      'coordinates': coordinates,
      'irrigationSystem': irrigationSystem,
      'growthStage': growthStage,
      'plantingDate': plantingDate != null ? Timestamp.fromDate(plantingDate!) : null,
      'harvestDate': harvestDate != null ? Timestamp.fromDate(harvestDate!) : null,
      'soilTestResults': soilTestResults,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}