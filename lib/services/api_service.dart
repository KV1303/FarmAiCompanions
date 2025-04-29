import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../models/field_model.dart';
import '../models/weather_model.dart';
import '../models/market_price_model.dart';
import '../models/disease_model.dart';
import '../utils/helpers.dart';

class ApiService {
  final Dio _dio = Dio();
  final Random _random = Random();

  ApiService() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return handler.resolve(
            Response(
              requestOptions: e.requestOptions,
              statusCode: 408,
              data: {'message': 'Connection timeout. Please check your internet connection.'},
            ),
          );
        }
        return handler.next(e);
      },
    ));
  }

  // Field Management API Calls
  Future<List<Field>> fetchFields(String userId) async {
    try {
      // In a real app, this would be an actual API call
      // final response = await _dio.get('${AppConstants.baseUrl}/fields?userId=$userId');
      
      // Since we don't have a real backend, we'll simulate offline-first approach
      // For a real implementation, update this to use actual API endpoints
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception("Network error - using local data instead");
    } catch (e) {
      debugPrint('Error fetching fields: $e');
      return [];
    }
  }

  Future<Field?> fetchFieldDetails(String fieldId) async {
    try {
      // In a real app, this would be an actual API call
      // final response = await _dio.get('${AppConstants.baseUrl}/fields/$fieldId');
      
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception("Network error - using local data instead");
    } catch (e) {
      debugPrint('Error fetching field details: $e');
      return null;
    }
  }

  Future<bool> addField(Field field) async {
    try {
      // In a real app, this would be an actual API call
      // final response = await _dio.post(
      //   '${AppConstants.baseUrl}/fields',
      //   data: jsonEncode(field.toJson()),
      // );
      
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error adding field: $e');
      return false;
    }
  }

  Future<bool> updateField(Field field) async {
    try {
      // In a real app, this would be an actual API call
      // final response = await _dio.put(
      //   '${AppConstants.baseUrl}/fields/${field.id}',
      //   data: jsonEncode(field.toJson()),
      // );
      
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error updating field: $e');
      return false;
    }
  }

  Future<bool> deleteField(String fieldId) async {
    try {
      // In a real app, this would be an actual API call
      // final response = await _dio.delete('${AppConstants.baseUrl}/fields/$fieldId');
      
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error deleting field: $e');
      return false;
    }
  }

  // Weather API Calls
  Future<List<Weather>?> fetchWeatherData(double latitude, double longitude, String location) async {
    try {
      const apiKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: '');
      
      // In a real app with valid API key, this would call the actual weather API
      final url = '${AppConstants.weatherApiUrl}?location=$latitude,$longitude&key=$apiKey&unitGroup=metric&contentType=json';
      
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        // Process the response data and return Weather objects
        // This would depend on the actual response format from the Visual Crossing API
        return parseWeatherResponse(response.data, location);
      } else {
        debugPrint('Failed to load weather data. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching weather data: $e');
      // Create mock weather data if API fails
      return null;
    }
  }

  List<Weather> parseWeatherResponse(Map<String, dynamic> data, String location) {
    final List<Weather> weatherList = [];
    final now = DateTime.now();
    
    try {
      // This is a sample parser for the Visual Crossing API format
      // You would need to adjust this based on the actual API response structure
      final currentConditions = data['currentConditions'];
      final forecast = data['days'];
      
      // Add current weather
      weatherList.add(Weather(
        id: 'current',
        latitude: data['latitude'] ?? 0.0,
        longitude: data['longitude'] ?? 0.0,
        location: location,
        date: now,
        temperature: currentConditions['temp'] ?? 0.0,
        minTemperature: currentConditions['tempmin'] ?? 0.0,
        maxTemperature: currentConditions['tempmax'] ?? 0.0,
        humidity: currentConditions['humidity'] ?? 0.0,
        precipitation: currentConditions['precip'] ?? 0.0,
        windSpeed: currentConditions['windspeed'] ?? 0.0,
        windDirection: currentConditions['winddir'] ?? '',
        description: currentConditions['conditions'] ?? '',
        iconCode: mapWeatherConditionToIcon(currentConditions['conditions'] ?? ''),
        lastUpdated: now,
      ));
      
      // Add forecast data for next days
      for (int i = 0; i < min(5, forecast.length); i++) {
        final day = forecast[i];
        final forecastDate = now.add(Duration(days: i + 1));
        
        weatherList.add(Weather(
          id: 'forecast_$i',
          latitude: data['latitude'] ?? 0.0,
          longitude: data['longitude'] ?? 0.0,
          location: location,
          date: forecastDate,
          temperature: day['temp'] ?? 0.0,
          minTemperature: day['tempmin'] ?? 0.0,
          maxTemperature: day['tempmax'] ?? 0.0,
          humidity: day['humidity'] ?? 0.0,
          precipitation: day['precip'] ?? 0.0,
          windSpeed: day['windspeed'] ?? 0.0,
          windDirection: day['winddir'] ?? '',
          description: day['conditions'] ?? '',
          iconCode: mapWeatherConditionToIcon(day['conditions'] ?? ''),
          lastUpdated: now,
        ));
      }
      
      return weatherList;
    } catch (e) {
      debugPrint('Error parsing weather data: $e');
      return [];
    }
  }

  String mapWeatherConditionToIcon(String condition) {
    // Map weather condition text to icon code
    final conditionLower = condition.toLowerCase();
    
    if (conditionLower.contains('clear') || conditionLower.contains('sunny')) {
      return '01d';
    } else if (conditionLower.contains('partly cloudy')) {
      return '02d';
    } else if (conditionLower.contains('cloudy') || conditionLower.contains('overcast')) {
      return '03d';
    } else if (conditionLower.contains('rain') || conditionLower.contains('shower')) {
      return '10d';
    } else if (conditionLower.contains('thunderstorm') || conditionLower.contains('storm')) {
      return '11d';
    } else if (conditionLower.contains('snow')) {
      return '13d';
    } else if (conditionLower.contains('mist') || conditionLower.contains('fog')) {
      return '50d';
    } else {
      return '02d'; // Default - few clouds
    }
  }

  // Market Price API Calls
  Future<List<MarketPrice>> fetchMarketPrices(String cropType, String state) async {
    try {
      // This would be a call to eNAM API in a real app
      // For now, we'll simulate API error to use local data
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception("Network error - using local data instead");
    } catch (e) {
      debugPrint('Error fetching market prices: $e');
      return [];
    }
  }

  Future<List<MarketPrice>> fetchHistoricalPrices(String cropType, String marketName) async {
    try {
      // This would be a call to eNAM API in a real app
      // For now, we'll simulate API error to use local data
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception("Network error - using local data instead");
    } catch (e) {
      debugPrint('Error fetching historical prices: $e');
      return [];
    }
  }

  // Disease API Calls
  Future<List<Disease>> fetchDiseases() async {
    try {
      // In a real app, this would be an actual API call
      // For now, return common diseases for the demo
      await Future.delayed(const Duration(milliseconds: 800));
      
      return createCommonDiseases();
    } catch (e) {
      debugPrint('Error fetching diseases: $e');
      return [];
    }
  }

  Future<bool> saveDiseaseDetection(Disease disease) async {
    try {
      // In a real app, this would be an actual API call
      // final response = await _dio.post(
      //   '${AppConstants.baseUrl}/diseases',
      //   data: jsonEncode(disease.toJson()),
      // );
      
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error saving disease detection: $e');
      return false;
    }
  }

  List<Disease> createCommonDiseases() {
    final diseases = <Disease>[];
    final diseaseData = [
      {
        'id': 'disease_1',
        'name': 'Bacterial Leaf Blight',
        'scientific_name': 'Xanthomonas oryzae pv. oryzae',
        'crop_type': 'Rice',
        'symptoms': [
          'Water-soaked yellowish stripes on leaf edges',
          'Lesions turn white or gray and then yellow',
          'Affected leaves dry up and die',
          'Wilting of seedlings'
        ],
        'treatments': [
          'Use resistant rice varieties',
          'Apply copper-based bactericides',
          'Drain the field during severe infections',
          'Balanced use of nitrogen fertilizers'
        ],
        'preventive_measures': [
          'Use disease-free seeds',
          'Treat seeds with hot water before planting',
          'Maintain proper spacing between plants',
          'Avoid excessive nitrogen application'
        ],
        'image_url': 'https://images.unsplash.com/photo-1607326207820-989c6d53a0a2',
        'severity': 'High',
        'affected_crops': ['Rice']
      },
      {
        'id': 'disease_2',
        'name': 'Powdery Mildew',
        'scientific_name': 'Erysiphe graminis',
        'crop_type': 'Wheat',
        'symptoms': [
          'White powdery patches on leaves and stems',
          'Yellowing of affected tissue',
          'Stunted growth',
          'Reduced yield'
        ],
        'treatments': [
          'Apply sulfur or potassium bicarbonate sprays',
          'Use fungicides containing triazoles',
          'Remove and destroy infected plant parts',
          'Apply neem oil or milk spray for organic management'
        ],
        'preventive_measures': [
          'Use resistant varieties',
          'Ensure proper spacing for good air circulation',
          'Avoid overhead irrigation',
          'Maintain balanced soil fertility'
        ],
        'image_url': 'https://images.unsplash.com/photo-1528839390497-a161db4bac71',
        'severity': 'Medium',
        'affected_crops': ['Wheat', 'Barley']
      },
      {
        'id': 'disease_3',
        'name': 'Late Blight',
        'scientific_name': 'Phytophthora infestans',
        'crop_type': 'Potato',
        'symptoms': [
          'Dark brown spots on leaves with pale green borders',
          'White fungal growth on leaf undersides',
          'Dark areas on potato tubers',
          'Rapid wilting and death in humid conditions'
        ],
        'treatments': [
          'Apply copper-based fungicides',
          'Use systemic fungicides in severe cases',
          'Remove and destroy infected plants',
          'Harvest potatoes when vines die back'
        ],
        'preventive_measures': [
          'Use certified disease-free seed potatoes',
          'Plant resistant varieties',
          'Ensure good drainage',
          'Practice crop rotation'
        ],
        'image_url': 'https://images.unsplash.com/photo-1576669801820-a9ab287ac2d1',
        'severity': 'Severe',
        'affected_crops': ['Potato', 'Tomato']
      },
      {
        'id': 'disease_4',
        'name': 'Anthracnose',
        'scientific_name': 'Colletotrichum species',
        'crop_type': 'Chilli',
        'symptoms': [
          'Dark, sunken lesions on fruits',
          'Circular spots on leaves and stems',
          'Pink or orange spore masses in lesions',
          'Premature fruit drop'
        ],
        'treatments': [
          'Apply copper oxychloride or mancozeb',
          'Use Trichoderma as biological control',
          'Remove and destroy infected plant parts',
          'Apply potassium fertilizers to strengthen plant'
        ],
        'preventive_measures': [
          'Use disease-free seeds',
          'Treat seeds with fungicides before sowing',
          'Maintain proper plant spacing',
          'Avoid overhead irrigation'
        ],
        'image_url': 'https://images.unsplash.com/photo-1578496479914-7ef3b0193be3',
        'severity': 'Medium',
        'affected_crops': ['Chilli', 'Mango', 'Bean']
      }
    ];
    
    for (final data in diseaseData) {
      diseases.add(Disease(
        id: data['id'] as String,
        name: data['name'] as String,
        scientificName: data['scientific_name'] as String,
        cropType: data['crop_type'] as String,
        symptoms: List<String>.from(data['symptoms'] as List),
        treatments: List<String>.from(data['treatments'] as List),
        preventiveMeasures: List<String>.from(data['preventive_measures'] as List),
        imageUrl: data['image_url'] as String,
        severity: data['severity'] as String,
        affectedCrops: List<String>.from(data['affected_crops'] as List),
      ));
    }
    
    return diseases;
  }
}
