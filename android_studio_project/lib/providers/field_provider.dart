import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

import '../models/field_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../constants/app_images.dart';

class FieldProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final _uuid = Uuid();
  
  List<Field> _fields = [];
  Field? _selectedField;
  bool _isLoading = false;
  String _error = '';
  
  List<Field> get fields => _fields;
  Field? get selectedField => _selectedField;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  Future<void> fetchFields(String userId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to get fields from local storage first
      final localFields = await _localStorageService.getFields(userId);
      
      if (localFields.isNotEmpty) {
        _fields = localFields;
        notifyListeners();
      }
      
      // Then try to fetch from API (to get the latest data)
      final apiFields = await _apiService.fetchFields(userId);
      
      if (apiFields.isNotEmpty) {
        _fields = apiFields;
        
        // Save to local storage
        await _localStorageService.saveFields(userId, _fields);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> addField(String ownerId, String name, String cropType, double area, 
      String areaUnit, double latitude, double longitude, DateTime sowingDate, 
      DateTime expectedHarvestDate) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Generate random NDVI and soil moisture for demo
      final Random random = Random();
      final double ndviIndex = 0.3 + random.nextDouble() * 0.7; // Between 0.3 and 1.0
      final double soilMoisture = 20 + random.nextDouble() * 50; // Between 20 and 70%
      
      // Get random field image
      final imageUrl = AppImages.defaultFieldImages[random.nextInt(AppImages.defaultFieldImages.length)];
      
      // Create field object
      final field = Field(
        id: _uuid.v4(),
        name: name,
        ownerId: ownerId,
        cropType: cropType,
        area: area,
        areaUnit: areaUnit,
        latitude: latitude,
        longitude: longitude,
        sowingDate: sowingDate,
        expectedHarvestDate: expectedHarvestDate,
        ndviIndex: ndviIndex,
        soilMoisture: soilMoisture,
        healthStatus: ndviIndex > 0.6 ? 'Good' : (ndviIndex > 0.4 ? 'Fair' : 'Poor'),
        imageUrl: imageUrl,
        lastUpdated: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      // Save to API
      final success = await _apiService.addField(field);
      
      if (success) {
        // Add to local list
        _fields.add(field);
        
        // Also save to local storage
        await _localStorageService.saveFields(ownerId, _fields);
        
        _selectedField = field;
        return true;
      } else {
        _error = 'Failed to add field. Please try again.';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updateField(Field field) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Update via API
      final success = await _apiService.updateField(field);
      
      if (success) {
        // Update local list
        final index = _fields.indexWhere((f) => f.id == field.id);
        if (index != -1) {
          _fields[index] = field;
        }
        
        // Also update in local storage
        await _localStorageService.saveFields(field.ownerId, _fields);
        
        if (_selectedField?.id == field.id) {
          _selectedField = field;
        }
        
        return true;
      } else {
        _error = 'Failed to update field. Please try again.';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteField(String fieldId, String ownerId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Delete via API
      final success = await _apiService.deleteField(fieldId);
      
      if (success) {
        // Remove from local list
        _fields.removeWhere((field) => field.id == fieldId);
        
        // Also remove from local storage
        await _localStorageService.saveFields(ownerId, _fields);
        
        if (_selectedField?.id == fieldId) {
          _selectedField = null;
        }
        
        return true;
      } else {
        _error = 'Failed to delete field. Please try again.';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void selectField(String fieldId) {
    _selectedField = _fields.firstWhere(
      (field) => field.id == fieldId,
      orElse: () => _fields.isNotEmpty ? _fields.first : null!,
    );
    notifyListeners();
  }
  
  Future<bool> updateFieldNDVI(String fieldId, double ndviIndex) async {
    try {
      // Find the field
      final fieldIndex = _fields.indexWhere((field) => field.id == fieldId);
      if (fieldIndex == -1) {
        _error = 'Field not found';
        return false;
      }
      
      // Update field with new NDVI
      final field = _fields[fieldIndex];
      final updatedField = field.copyWith(
        ndviIndex: ndviIndex,
        healthStatus: ndviIndex > 0.6 ? 'Good' : (ndviIndex > 0.4 ? 'Fair' : 'Poor'),
        lastUpdated: DateTime.now(),
      );
      
      // Update the field
      return await updateField(updatedField);
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
  
  Future<bool> refreshFieldData(String fieldId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Find the field
      final fieldIndex = _fields.indexWhere((field) => field.id == fieldId);
      if (fieldIndex == -1) {
        _error = 'Field not found';
        return false;
      }
      
      final field = _fields[fieldIndex];
      
      // Fetch latest field data from API
      final updatedField = await _apiService.fetchFieldDetails(fieldId);
      
      if (updatedField != null) {
        // Update local list
        _fields[fieldIndex] = updatedField;
        
        // Also update in local storage
        await _localStorageService.saveFields(field.ownerId, _fields);
        
        if (_selectedField?.id == fieldId) {
          _selectedField = updatedField;
        }
        
        return true;
      } else {
        // If API fails, simulate update with random data for demo
        final Random random = Random();
        final double ndviIndex = 0.3 + random.nextDouble() * 0.7; // Between 0.3 and 1.0
        final double soilMoisture = 20 + random.nextDouble() * 50; // Between 20 and 70%
        
        final updatedField = field.copyWith(
          ndviIndex: ndviIndex,
          soilMoisture: soilMoisture,
          healthStatus: ndviIndex > 0.6 ? 'Good' : (ndviIndex > 0.4 ? 'Fair' : 'Poor'),
          lastUpdated: DateTime.now(),
        );
        
        // Update local list
        _fields[fieldIndex] = updatedField;
        
        // Also update in local storage
        await _localStorageService.saveFields(field.ownerId, _fields);
        
        if (_selectedField?.id == fieldId) {
          _selectedField = updatedField;
        }
        
        return true;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
