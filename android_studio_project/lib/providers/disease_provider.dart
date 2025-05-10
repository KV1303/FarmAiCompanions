import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/disease_model.dart';
import '../services/ml_service.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../constants/app_images.dart';

class DiseaseProvider extends ChangeNotifier {
  final MLService _mlService = MLService();
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final _uuid = Uuid();
  
  List<Disease> _diseases = [];
  Disease? _detectedDisease;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String _error = '';
  
  List<Disease> get diseases => _diseases;
  Disease? get detectedDisease => _detectedDisease;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String get error => _error;
  
  Future<void> loadDiseases() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      // Try to get diseases from local storage first
      final localDiseases = await _localStorageService.getDiseases();
      
      if (localDiseases.isNotEmpty) {
        _diseases = localDiseases;
        notifyListeners();
      }
      
      // Then try to fetch from API (to get the latest data)
      final apiDiseases = await _apiService.fetchDiseases();
      
      if (apiDiseases.isNotEmpty) {
        _diseases = apiDiseases;
        
        // Save to local storage
        await _localStorageService.saveDiseases(_diseases);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
        _detectedDisease = null;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick image: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<bool> analyzeImage() async {
    if (_selectedImage == null) {
      _error = 'No image selected. Please select an image first.';
      notifyListeners();
      return false;
    }
    
    try {
      _isAnalyzing = true;
      _error = '';
      notifyListeners();
      
      // Run ML model to detect disease
      final mlResult = await _mlService.detectDisease(_selectedImage!.path);
      
      if (mlResult != null && mlResult.isNotEmpty) {
        final diseaseName = mlResult['label'] as String;
        final confidence = mlResult['confidence'] as double;
        
        // Check if disease exists in our database
        final existingDisease = _diseases.firstWhere(
          (disease) => disease.name.toLowerCase() == diseaseName.toLowerCase(),
          orElse: () => null!,
        );
        
        if (existingDisease != null) {
          _detectedDisease = existingDisease;
        } else {
          // Create a new disease entry with mock data
          _detectedDisease = _createMockDisease(diseaseName, confidence);
          
          // Add to diseases list
          _diseases.add(_detectedDisease!);
          
          // Save to local storage
          await _localStorageService.saveDiseases(_diseases);
        }
        
        return true;
      } else {
        _error = 'No disease detected or unable to analyze the image.';
        return false;
      }
    } catch (e) {
      _error = 'Failed to analyze image: ${e.toString()}';
      return false;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
  
  Future<bool> saveDetectedDisease() async {
    if (_detectedDisease == null || _selectedImage == null) {
      _error = 'No disease detected to save.';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Save image to local storage
      final appDir = await getApplicationDocumentsDirectory();
      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImagePath = '${appDir.path}/$filename';
      
      await _selectedImage!.copy(savedImagePath);
      
      // Update disease with local image path
      final updatedDisease = Disease(
        id: _detectedDisease!.id,
        name: _detectedDisease!.name,
        scientificName: _detectedDisease!.scientificName,
        cropType: _detectedDisease!.cropType,
        symptoms: _detectedDisease!.symptoms,
        treatments: _detectedDisease!.treatments,
        preventiveMeasures: _detectedDisease!.preventiveMeasures,
        imageUrl: savedImagePath,
        severity: _detectedDisease!.severity,
        affectedCrops: _detectedDisease!.affectedCrops,
      );
      
      // Save to API (if applicable)
      await _apiService.saveDiseaseDetection(updatedDisease);
      
      // Update in local list
      final index = _diseases.indexWhere((d) => d.id == updatedDisease.id);
      if (index >= 0) {
        _diseases[index] = updatedDisease;
      } else {
        _diseases.add(updatedDisease);
      }
      
      // Update local storage
      await _localStorageService.saveDiseases(_diseases);
      
      _detectedDisease = updatedDisease;
      
      return true;
    } catch (e) {
      _error = 'Failed to save disease detection: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // For demo purposes - creates a mock disease when ML model returns a result not in our database
  Disease _createMockDisease(String name, double confidence) {
    final random = Random();
    
    // Get a random disease image
    final imageUrl = AppImages.defaultDiseaseImages[random.nextInt(AppImages.defaultDiseaseImages.length)];
    
    // Severity based on confidence
    String severity;
    if (confidence > 0.9) {
      severity = 'High';
    } else if (confidence > 0.7) {
      severity = 'Medium';
    } else {
      severity = 'Low';
    }
    
    // Create mock symptoms, treatments and preventive measures
    List<String> symptoms = [];
    List<String> treatments = [];
    List<String> preventiveMeasures = [];
    
    if (name.toLowerCase().contains('blight')) {
      symptoms = [
        'Brown spots on leaves',
        'Yellowing of foliage',
        'Wilting of plant parts',
        'Stunted growth'
      ];
      treatments = [
        'Apply copper-based fungicides',
        'Remove and destroy infected plant parts',
        'Ensure proper spacing between plants',
        'Use disease-resistant varieties for next planting'
      ];
      preventiveMeasures = [
        'Rotate crops every 2-3 years',
        'Avoid overhead irrigation',
        'Clean tools and equipment regularly',
        'Use disease-free seeds'
      ];
    } else if (name.toLowerCase().contains('rust')) {
      symptoms = [
        'Rusty orange spots on leaves',
        'Powdery spores on leaf undersides',
        'Premature leaf drop',
        'Reduced crop yield'
      ];
      treatments = [
        'Apply sulfur-based fungicides',
        'Remove severely infected plants',
        'Increase air circulation around plants',
        'Balance soil nutrients'
      ];
      preventiveMeasures = [
        'Plant resistant varieties',
        'Avoid working with plants when wet',
        'Space plants properly',
        'Control related weeds that may host the fungus'
      ];
    } else if (name.toLowerCase().contains('mildew')) {
      symptoms = [
        'White powdery coating on leaves',
        'Distorted leaves and shoots',
        'Reduced photosynthesis',
        'Decreased fruit quality'
      ];
      treatments = [
        'Apply potassium bicarbonate',
        'Use neem oil spray',
        'Introduce beneficial organisms',
        'Improve air circulation'
      ];
      preventiveMeasures = [
        'Avoid overcrowding plants',
        'Ensure proper drainage',
        'Water at base of plants',
        'Remove plant debris after harvest'
      ];
    } else {
      // Generic symptoms and treatments
      symptoms = [
        'Discoloration of leaves',
        'Abnormal growth patterns',
        'Spots or lesions on plant tissues',
        'Reduced vigor and yield'
      ];
      treatments = [
        'Remove and destroy infected parts',
        'Apply appropriate fungicides or pesticides',
        'Improve plant nutrition',
        'Correct environmental conditions'
      ];
      preventiveMeasures = [
        'Practice crop rotation',
        'Maintain proper plant spacing',
        'Use disease-resistant varieties',
        'Implement good field sanitation'
      ];
    }
    
    return Disease(
      id: _uuid.v4(),
      name: name,
      scientificName: 'Scientific name pending identification',
      cropType: 'Multiple crops',
      symptoms: symptoms,
      treatments: treatments,
      preventiveMeasures: preventiveMeasures,
      imageUrl: imageUrl,
      severity: severity,
      affectedCrops: ['Rice', 'Wheat', 'Maize', 'Potato', 'Tomato'],
    );
  }
  
  void clearDetection() {
    _selectedImage = null;
    _detectedDisease = null;
    notifyListeners();
  }
}
