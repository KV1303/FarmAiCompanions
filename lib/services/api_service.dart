import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/field.dart';
import '../models/disease_report.dart';
import '../models/market_price.dart';
import '../models/weather_forecast.dart';

class ApiService {
  // Base URL for the API
  // The final deployed API URL will be used here
  static String baseUrl = kReleaseMode
      ? 'https://farmassist-api.example.com' // Replace with actual production URL
      : 'http://localhost:5003'; // Local development URL
      
  // Headers for API requests
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Authentication
  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/login'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/register'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Fields
  Future<List<Field>> getFields(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/fields?user_id=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('fields')) {
          final List<dynamic> fields = data['fields'];
          return fields.map((field) => Field.fromJson(field)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Get fields error: $e');
      return [];
    }
  }

  // Disease Detection
  Future<Map<String, dynamic>?> detectDisease(File imageFile, int userId, int fieldId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/detect_disease'),
      );
      
      request.fields['user_id'] = userId.toString();
      request.fields['field_id'] = fieldId.toString();
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      }
      return null;
    } catch (e) {
      print('Disease detection error: $e');
      return null;
    }
  }

  // Weather Data
  Future<WeatherForecast?> getWeatherForecast(String location) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/weather?location=$location'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return WeatherForecast.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Weather forecast error: $e');
      return null;
    }
  }

  // Market Prices
  Future<List<MarketPrice>> getMarketPrices({String? cropType}) async {
    try {
      String url = '$baseUrl/api/market_prices';
      if (cropType != null && cropType.isNotEmpty) {
        url += '?crop_type=$cropType';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('prices')) {
          final List<dynamic> prices = data['prices'];
          return prices.map((price) => MarketPrice.fromJson(price)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Market prices error: $e');
      return [];
    }
  }

  // Farm Guidance
  Future<Map<String, dynamic>?> getFarmGuidance(int fieldId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/farm_guidance?field_id=$fieldId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Farm guidance error: $e');
      return null;
    }
  }
  
  // Quick Farm Guidance
  Future<Map<String, dynamic>?> getQuickFarmGuidance(String cropType, String soilType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/quick_farm_guidance?crop_type=$cropType&soil_type=$soilType'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Quick farm guidance error: $e');
      return null;
    }
  }
  
  // Fertilizer Recommendations
  Future<Map<String, dynamic>?> getFertilizerRecommendations({
    required String cropType,
    required String soilType,
    required String growthStage,
    String? nitrogenLevel,
    String? phosphorusLevel,
    String? potassiumLevel,
    double? phLevel,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'crop_type': cropType,
        'soil_type': soilType,
        'growth_stage': growthStage,
      };
      
      if (nitrogenLevel != null) params['nitrogen_level'] = nitrogenLevel;
      if (phosphorusLevel != null) params['phosphorus_level'] = phosphorusLevel;
      if (potassiumLevel != null) params['potassium_level'] = potassiumLevel;
      if (phLevel != null) params['ph_level'] = phLevel.toString();
      
      final uri = Uri.parse('$baseUrl/api/fertilizer_recommendations')
          .replace(queryParameters: params);
      
      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Fertilizer recommendations error: $e');
      return null;
    }
  }
  
  // Chat
  Future<Map<String, dynamic>?> sendChatMessage(String message, String userId, String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'user_id': userId,
          'session_id': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Chat error: $e');
      return null;
    }
  }
  
  Future<List<Map<String, dynamic>>> getChatHistory(String userId, String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat_history?user_id=$userId&session_id=$sessionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('history')) {
          return List<Map<String, dynamic>>.from(data['history']);
        }
      }
      return [];
    } catch (e) {
      print('Chat history error: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getChatSessions(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat_sessions?user_id=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('sessions')) {
          return List<Map<String, dynamic>>.from(data['sessions']);
        }
      }
      return [];
    } catch (e) {
      print('Chat sessions error: $e');
      return [];
    }
  }
}