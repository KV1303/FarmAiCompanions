import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPriceModel {
  final String id;
  final String cropType;
  final String market;
  final String state;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String priceUnit;
  final DateTime date;
  final DateTime? updatedAt;

  MarketPriceModel({
    required this.id,
    required this.cropType,
    required this.market,
    required this.state,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.priceUnit,
    required this.date,
    this.updatedAt,
  });

  // Create from Firestore document
  factory MarketPriceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MarketPriceModel(
      id: id,
      cropType: data['cropType'] ?? '',
      market: data['market'] ?? '',
      state: data['state'] ?? '',
      minPrice: (data['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (data['maxPrice'] ?? 0.0).toDouble(),
      modalPrice: (data['modalPrice'] ?? 0.0).toDouble(),
      priceUnit: data['priceUnit'] ?? '₹/क्विंटल',
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cropType': cropType,
      'market': market,
      'state': state,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'modalPrice': modalPrice,
      'priceUnit': priceUnit,
      'date': Timestamp.fromDate(date),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

class MarketFavoriteModel {
  final String id;
  final String userId;
  final String cropType;
  final double? alertPrice;
  final bool isAlertEnabled;
  final DateTime createdAt;

  MarketFavoriteModel({
    required this.id,
    required this.userId,
    required this.cropType,
    this.alertPrice,
    this.isAlertEnabled = false,
    required this.createdAt,
  });

  // Create from Firestore document
  factory MarketFavoriteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MarketFavoriteModel(
      id: id,
      userId: data['userId'] ?? '',
      cropType: data['cropType'] ?? '',
      alertPrice: data['alertPrice'] != null ? data['alertPrice'].toDouble() : null,
      isAlertEnabled: data['isAlertEnabled'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cropType': cropType,
      'alertPrice': alertPrice,
      'isAlertEnabled': isAlertEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}