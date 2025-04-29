import 'package:flutter/material.dart';
import 'dart:math';

import '../models/weather_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../constants/app_constants.dart';

class WeatherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  Weather? _currentWeather;
  List<Weather> _forecastWeather = [];
  bool _isLoading = false;
  String _error = '';
  
  Weather? get currentWeather => _currentWeather;
  List<Weather> get forecastWeather => _forecastWeather;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  Future<void> fetchWeatherData(double latitude, double longitude, String location) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to get weather from local storage first
      final localWeather = await _localStorageService.getCurrentWeather();
      final localForecast = await _localStorageService.getForecastWeather();
      
      final now = DateTime.now();
      final isCacheValid = localWeather != null && 
          now.difference(localWeather.lastUpdated).inHours < AppConstants.cacheDurationHours;
      
      if (isCacheValid && localWeather != null && localForecast.isNotEmpty) {
        _currentWeather = localWeather;
        _forecastWeather = localForecast;
        notifyListeners();
      }
      
      // Then try to fetch from API (to get the latest data)
      final result = await _apiService.fetchWeatherData(latitude, longitude, location);
      
      if (result != null && result.isNotEmpty) {
        _currentWeather = result[0];
        _forecastWeather = result.sublist(1);
        
        // Save to local storage
        await _localStorageService.saveCurrentWeather(_currentWeather!);
        await _localStorageService.saveForecastWeather(_forecastWeather);
      } else if (_currentWeather == null) {
        // If API fails and we don't have cached data, create mock data
        _createMockWeatherData(latitude, longitude, location);
      }
    } catch (e) {
      _error = e.toString();
      
      // If there's an error and we don't have data, create mock data
      if (_currentWeather == null) {
        _createMockWeatherData(latitude, longitude, location);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // For demo/fallback purposes only - creates mock weather data
  void _createMockWeatherData(double latitude, double longitude, String location) {
    final random = Random();
    final now = DateTime.now();
    
    // Create current weather
    _currentWeather = Weather(
      id: 'current',
      latitude: latitude,
      longitude: longitude,
      location: location,
      date: now,
      temperature: 25 + random.nextDouble() * 10, // 25-35°C
      minTemperature: 22 + random.nextDouble() * 5, // 22-27°C
      maxTemperature: 30 + random.nextDouble() * 5, // 30-35°C
      humidity: 60 + random.nextDouble() * 20, // 60-80%
      precipitation: random.nextDouble() * 5, // 0-5mm
      windSpeed: 5 + random.nextDouble() * 10, // 5-15 km/h
      windDirection: ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'][random.nextInt(8)],
      description: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Light Rain', 'Clear'][random.nextInt(5)],
      iconCode: ['01d', '02d', '03d', '10d', '01d'][random.nextInt(5)],
      lastUpdated: now,
    );
    
    // Create forecast
    _forecastWeather = [];
    for (int i = 1; i <= 5; i++) {
      final forecastDate = now.add(Duration(days: i));
      
      _forecastWeather.add(
        Weather(
          id: 'forecast_$i',
          latitude: latitude,
          longitude: longitude,
          location: location,
          date: forecastDate,
          temperature: 25 + random.nextDouble() * 10, // 25-35°C
          minTemperature: 22 + random.nextDouble() * 5, // 22-27°C
          maxTemperature: 30 + random.nextDouble() * 5, // 30-35°C
          humidity: 60 + random.nextDouble() * 20, // 60-80%
          precipitation: random.nextDouble() * 10, // 0-10mm
          windSpeed: 5 + random.nextDouble() * 10, // 5-15 km/h
          windDirection: ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'][random.nextInt(8)],
          description: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Light Rain', 'Clear'][random.nextInt(5)],
          iconCode: ['01d', '02d', '03d', '10d', '01d'][random.nextInt(5)],
          lastUpdated: now,
        ),
      );
    }
    
    // Save to local storage
    _localStorageService.saveCurrentWeather(_currentWeather!);
    _localStorageService.saveForecastWeather(_forecastWeather);
  }
  
  bool get hasRainAlert {
    if (_currentWeather == null) return false;
    return _currentWeather!.description.toLowerCase().contains('rain') || 
          _currentWeather!.precipitation > 3.0 ||
          (_forecastWeather.isNotEmpty && 
           _forecastWeather[0].description.toLowerCase().contains('rain'));
  }
  
  String get weatherAlert {
    if (!hasRainAlert) return '';
    
    if (_currentWeather!.precipitation > 5.0) {
      return 'Heavy rain expected. Consider postponing field operations.';
    } else if (_currentWeather!.precipitation > 3.0) {
      return 'Moderate rain expected. Plan outdoor activities accordingly.';
    } else {
      return 'Light rain expected. Good for crops.';
    }
  }
  
  bool get hasTemperatureAlert {
    if (_currentWeather == null) return false;
    return _currentWeather!.temperature > 38.0 || _currentWeather!.temperature < 10.0;
  }
  
  String get temperatureAlert {
    if (!hasTemperatureAlert) return '';
    
    if (_currentWeather!.temperature > 38.0) {
      return 'High temperature alert. Ensure adequate irrigation.';
    } else {
      return 'Low temperature alert. Protect sensitive crops.';
    }
  }
}
