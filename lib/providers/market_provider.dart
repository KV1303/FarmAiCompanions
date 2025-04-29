import 'package:flutter/material.dart';
import 'dart:math';

import '../models/market_price_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../constants/app_constants.dart';

class MarketProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  
  List<MarketPrice> _marketPrices = [];
  List<MarketPrice> _historicalPrices = [];
  MarketPrice? _selectedPrice;
  bool _isLoading = false;
  String _error = '';
  
  List<MarketPrice> get marketPrices => _marketPrices;
  List<MarketPrice> get historicalPrices => _historicalPrices;
  MarketPrice? get selectedPrice => _selectedPrice;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  Future<void> fetchMarketPrices(String cropType, String state) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to get prices from local storage first
      final localPrices = await _localStorageService.getMarketPrices(cropType);
      
      final now = DateTime.now();
      final isCacheValid = localPrices.isNotEmpty && 
          now.difference(localPrices.first.lastUpdated).inHours < AppConstants.cacheDurationHours;
      
      if (isCacheValid) {
        _marketPrices = localPrices;
        notifyListeners();
      }
      
      // Then try to fetch from API (to get the latest data)
      final apiPrices = await _apiService.fetchMarketPrices(cropType, state);
      
      if (apiPrices.isNotEmpty) {
        _marketPrices = apiPrices;
        
        // Save to local storage
        await _localStorageService.saveMarketPrices(cropType, _marketPrices);
      } else if (_marketPrices.isEmpty) {
        // If API fails and we don't have cached data, create mock data
        _createMockMarketData(cropType, state);
      }
    } catch (e) {
      _error = e.toString();
      
      // If there's an error and we don't have data, create mock data
      if (_marketPrices.isEmpty) {
        _createMockMarketData(cropType, state);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchHistoricalPrices(String cropType, String marketName) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to get prices from local storage first
      final localPrices = await _localStorageService.getHistoricalPrices(cropType, marketName);
      
      if (localPrices.isNotEmpty) {
        _historicalPrices = localPrices;
        notifyListeners();
      }
      
      // Then try to fetch from API (to get the latest data)
      final apiPrices = await _apiService.fetchHistoricalPrices(cropType, marketName);
      
      if (apiPrices.isNotEmpty) {
        _historicalPrices = apiPrices;
        
        // Save to local storage
        await _localStorageService.saveHistoricalPrices(cropType, marketName, _historicalPrices);
      } else if (_historicalPrices.isEmpty) {
        // If API fails and we don't have cached data, create mock data
        _createMockHistoricalData(cropType, marketName);
      }
    } catch (e) {
      _error = e.toString();
      
      // If there's an error and we don't have data, create mock data
      if (_historicalPrices.isEmpty) {
        _createMockHistoricalData(cropType, marketName);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void selectMarketPrice(String id) {
    _selectedPrice = _marketPrices.firstWhere(
      (price) => price.id == id,
      orElse: () => _marketPrices.isNotEmpty ? _marketPrices.first : null!,
    );
    notifyListeners();
  }
  
  // For demo/fallback purposes only - creates mock market data
  void _createMockMarketData(String cropType, String state) {
    final random = Random();
    final now = DateTime.now();
    
    // Base price depending on crop
    double basePrice = _getBasePriceForCrop(cropType);
    
    // Create 10 market prices
    _marketPrices = [];
    
    final districts = [
      'Nashik', 'Pune', 'Mumbai', 'Nagpur', 'Aurangabad',
      'Amravati', 'Solapur', 'Kolhapur', 'Sangli', 'Satara'
    ];
    
    final markets = [
      'APMC', 'Krishi Bazaar', 'Farmers Market', 'Wholesale Market',
      'Rural Market', 'Urban Market', 'Local Mandi', 'eNAM Centre',
      'Village Market', 'District Market'
    ];
    
    for (int i = 0; i < 10; i++) {
      final district = districts[i];
      final market = markets[i];
      
      // Vary price slightly by district
      final variation = random.nextDouble() * 200 - 100; // -100 to +100
      final modalPrice = basePrice + variation;
      
      _marketPrices.add(
        MarketPrice(
          id: 'market_price_$i',
          cropName: cropType,
          marketName: '$market, $district',
          state: state,
          district: district,
          minPrice: modalPrice - (random.nextDouble() * 50 + 50), // 50-100 less than modal
          maxPrice: modalPrice + (random.nextDouble() * 50 + 50), // 50-100 more than modal
          modalPrice: modalPrice,
          unit: 'Quintal',
          date: now,
          lastUpdated: now,
        ),
      );
    }
    
    // Save to local storage
    _localStorageService.saveMarketPrices(cropType, _marketPrices);
  }
  
  // For demo/fallback purposes only - creates mock historical data
  void _createMockHistoricalData(String cropType, String marketName) {
    final random = Random();
    final now = DateTime.now();
    
    // Base price depending on crop
    double basePrice = _getBasePriceForCrop(cropType);
    
    // Create 30 days of historical prices
    _historicalPrices = [];
    
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: 29 - i));
      
      // Create some seasonal variation and upward/downward trend
      final seasonalFactor = 1 + 0.1 * sin((date.day + date.month * 30) / 45 * pi);
      final trendFactor = 1 + (i / 100); // Slight upward trend
      
      // Add some random noise
      final noise = 0.9 + random.nextDouble() * 0.2; // 0.9 to 1.1
      
      final modalPrice = basePrice * seasonalFactor * trendFactor * noise;
      
      _historicalPrices.add(
        MarketPrice(
          id: 'historical_price_$i',
          cropName: cropType,
          marketName: marketName,
          state: 'Sample State',
          district: 'Sample District',
          minPrice: modalPrice - (random.nextDouble() * 50 + 50), // 50-100 less than modal
          maxPrice: modalPrice + (random.nextDouble() * 50 + 50), // 50-100 more than modal
          modalPrice: modalPrice,
          unit: 'Quintal',
          date: date,
          lastUpdated: now,
        ),
      );
    }
    
    // Save to local storage
    _localStorageService.saveHistoricalPrices(cropType, marketName, _historicalPrices);
  }
  
  double _getBasePriceForCrop(String cropType) {
    // Base price depending on crop (as per approx. Indian market rates in INR per quintal)
    switch (cropType.toLowerCase()) {
      case 'rice':
        return 1800;
      case 'wheat':
        return 1925;
      case 'maize':
        return 1850;
      case 'cotton':
        return 5500;
      case 'sugarcane':
        return 290;
      case 'soybean':
        return 3900;
      case 'groundnut':
        return 5200;
      case 'mustard':
        return 4600;
      case 'potato':
        return 1200;
      case 'tomato':
        return 1500;
      case 'onion':
        return 2400;
      case 'chilli':
        return 8000;
      default:
        return 2000;
    }
  }
  
  // Get price trend (increase/decrease) compared to average of last 7 days
  Map<String, dynamic> getPriceTrend(String cropName, String marketName) {
    if (_historicalPrices.isEmpty) {
      return {'trend': 'stable', 'percentage': 0.0};
    }
    
    // Sort by date, newest first
    final sortedPrices = [..._historicalPrices];
    sortedPrices.sort((a, b) => b.date.compareTo(a.date));
    
    // Get current price (most recent)
    final currentPrice = sortedPrices.first.modalPrice;
    
    // Get prices from last 7 days (excluding today)
    final last7Days = sortedPrices.skip(1).take(7).toList();
    
    if (last7Days.isEmpty) {
      return {'trend': 'stable', 'percentage': 0.0};
    }
    
    // Calculate average price of last 7 days
    final avgPrice = last7Days.map((p) => p.modalPrice).reduce((a, b) => a + b) / last7Days.length;
    
    // Calculate percentage change
    final percentageChange = ((currentPrice - avgPrice) / avgPrice) * 100;
    
    // Determine trend
    String trend;
    if (percentageChange > 3) {
      trend = 'up';
    } else if (percentageChange < -3) {
      trend = 'down';
    } else {
      trend = 'stable';
    }
    
    return {
      'trend': trend,
      'percentage': percentageChange.abs(),
    };
  }
  
  // Get price forecast for next 7 days based on historical data
  List<MarketPrice> getPriceForecast(String cropName, String marketName) {
    if (_historicalPrices.isEmpty) {
      return [];
    }
    
    // Sort by date, newest first
    final sortedPrices = [..._historicalPrices];
    sortedPrices.sort((a, b) => a.date.compareTo(b.date));
    
    // Get current price (most recent)
    final latestPrice = sortedPrices.last.modalPrice;
    final latestDate = sortedPrices.last.date;
    
    // Analyze recent trends (last 7 days)
    final recent = sortedPrices.skip(sortedPrices.length - 7).toList();
    
    if (recent.length < 2) {
      return [];
    }
    
    // Calculate average daily change
    double totalChangePercentage = 0;
    for (int i = 1; i < recent.length; i++) {
      final prev = recent[i - 1].modalPrice;
      final curr = recent[i].modalPrice;
      totalChangePercentage += ((curr - prev) / prev) * 100;
    }
    
    final avgDailyChangePercentage = totalChangePercentage / (recent.length - 1);
    
    // Create forecast for next 7 days
    final forecast = <MarketPrice>[];
    double predictedPrice = latestPrice;
    
    for (int i = 1; i <= 7; i++) {
      final forecastDate = latestDate.add(Duration(days: i));
      
      // Apply average change plus some randomness
      final random = Random();
      final randomFactor = 0.8 + random.nextDouble() * 0.4; // 0.8 to 1.2
      final dailyChange = (avgDailyChangePercentage * randomFactor) / 100;
      
      predictedPrice = predictedPrice * (1 + dailyChange);
      
      forecast.add(
        MarketPrice(
          id: 'forecast_$i',
          cropName: cropName,
          marketName: marketName,
          state: sortedPrices.last.state,
          district: sortedPrices.last.district,
          minPrice: predictedPrice * 0.95,
          maxPrice: predictedPrice * 1.05,
          modalPrice: predictedPrice,
          unit: 'Quintal',
          date: forecastDate,
          lastUpdated: DateTime.now(),
        ),
      );
    }
    
    return forecast;
  }
}
