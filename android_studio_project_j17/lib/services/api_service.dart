import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // Base URL of the API - use environment variable or configuration
  final String baseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  ApiService({required this.baseUrl});
  
  // Helper method to get the current user ID
  String? get _userId => _auth.currentUser?.uid;
  
  // Helper to create authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _auth.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Get farming guidance for a specific crop and soil
  Future<Map<String, dynamic>> getFarmGuidance({
    required String cropType,
    required String soilType,
    String? growthStage,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/guidance/quick'),
        headers: headers,
        body: jsonEncode({
          'crop_type': cropType,
          'soil_type': soilType,
          'growth_stage': growthStage,
          'user_id': _userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get farm guidance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting farm guidance: $e');
    }
  }
  
  // Get market prices
  Future<List<dynamic>> getMarketPrices({String? cropType}) async {
    try {
      final headers = await _getHeaders();
      final Uri uri = cropType != null
          ? Uri.parse('$baseUrl/api/market_prices?crop_type=$cropType')
          : Uri.parse('$baseUrl/api/market_prices');
          
      final response = await http.get(
        uri,
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['prices'] ?? [];
      } else {
        throw Exception('Failed to get market prices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting market prices: $e');
    }
  }
  
  // Get user's market favorites
  Future<List<dynamic>> getMarketFavorites() async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/market_favorites?user_id=$_userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['favorites'] ?? [];
      } else {
        throw Exception('Failed to get market favorites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting market favorites: $e');
    }
  }
  
  // Get weather forecast
  Future<Map<String, dynamic>> getWeatherForecast({
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/weather?location=$location&lat=$latitude&lon=$longitude'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get weather forecast: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting weather forecast: $e');
    }
  }
  
  // Detect crop disease from image
  Future<Map<String, dynamic>> detectDisease(File imageFile, String cropType) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/detect_disease'),
      );
      
      // Add headers
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
      // Add fields
      request.fields['user_id'] = _userId!;
      request.fields['crop_type'] = cropType;
      
      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to detect disease: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting disease: $e');
    }
  }
  
  // Get AI-powered fertilizer recommendations
  Future<Map<String, dynamic>> getFertilizerRecommendations({
    required String cropType,
    required String soilType,
    String? growthStage,
    Map<String, dynamic>? soilTestResults,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/fertilizer/advanced'),
        headers: headers,
        body: jsonEncode({
          'crop_type': cropType,
          'soil_type': soilType,
          'growth_stage': growthStage,
          'soil_test_results': soilTestResults,
          'user_id': _userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get fertilizer recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting fertilizer recommendations: $e');
    }
  }
  
  // Get irrigation recommendations
  Future<Map<String, dynamic>> getIrrigationRecommendations({
    required String cropType,
    required String soilType,
    String? growthStage,
    double? soilMoisture,
    String? irrigationSystem,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/irrigation/recommendations'),
        headers: headers,
        body: jsonEncode({
          'crop_type': cropType,
          'soil_type': soilType,
          'growth_stage': growthStage,
          'soil_moisture': soilMoisture,
          'irrigation_system': irrigationSystem,
          'user_id': _userId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get irrigation recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting irrigation recommendations: $e');
    }
  }
  
  // Chat with AI farm assistant
  Future<Map<String, dynamic>> chatWithAssistant({
    required String message,
    String? sessionId,
  }) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'user_id': _userId,
          'session_id': sessionId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get assistant response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error chatting with assistant: $e');
    }
  }
  
  // Get chat history
  Future<List<dynamic>> getChatHistory({required String sessionId}) async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat_history?user_id=$_userId&session_id=$sessionId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['history'] ?? [];
      } else {
        throw Exception('Failed to get chat history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chat history: $e');
    }
  }
  
  // Get chat sessions
  Future<List<dynamic>> getChatSessions() async {
    try {
      if (_userId == null) throw Exception('User not authenticated');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat_sessions?user_id=$_userId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['sessions'] ?? [];
      } else {
        throw Exception('Failed to get chat sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting chat sessions: $e');
    }
  }
}