import 'package:cloud_firestore/cloud_firestore.dart';

class WeatherForecastModel {
  final String id;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime date;
  final double temperature;
  final double minTemperature;
  final double maxTemperature;
  final double humidity;
  final double precipitation;
  final double windSpeed;
  final String weatherCondition;
  final String? weatherIconUrl;
  final DateTime fetchedAt;

  WeatherForecastModel({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCondition,
    this.weatherIconUrl,
    required this.fetchedAt,
  });

  // Create from Firestore document
  factory WeatherForecastModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WeatherForecastModel(
      id: id,
      location: data['location'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      temperature: (data['temperature'] ?? 0.0).toDouble(),
      minTemperature: (data['minTemperature'] ?? 0.0).toDouble(),
      maxTemperature: (data['maxTemperature'] ?? 0.0).toDouble(),
      humidity: (data['humidity'] ?? 0.0).toDouble(),
      precipitation: (data['precipitation'] ?? 0.0).toDouble(),
      windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
      weatherCondition: data['weatherCondition'] ?? '',
      weatherIconUrl: data['weatherIconUrl'],
      fetchedAt: data['fetchedAt'] != null
          ? (data['fetchedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': Timestamp.fromDate(date),
      'temperature': temperature,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'humidity': humidity,
      'precipitation': precipitation,
      'windSpeed': windSpeed,
      'weatherCondition': weatherCondition,
      'weatherIconUrl': weatherIconUrl,
      'fetchedAt': Timestamp.fromDate(fetchedAt),
    };
  }
}