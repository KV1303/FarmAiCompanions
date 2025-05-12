import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/ad_service.dart';
import '../models/disease_report_model.dart';
import '../widgets/crop_selector_dialog.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  Map<String, dynamic>? _detectionResult;
  String? _selectedCrop;
  List<DiseaseReportModel> _diseaseHistory = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadDiseaseHistory();
  }

  Future<void> _loadDiseaseHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      // TODO: Implement API call to load disease history
      // For now, using empty list
      if (mounted) {
        setState(() {
          _diseaseHistory = [];
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
        print('Error loading disease history: $e');
      }
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _hasAnalyzed = false;
          _detectionResult = null;
        });

        // Show crop selection dialog
        _showCropSelectionDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('छवि लोड करने में त्रुटि: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCropSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CropSelectorDialog(
          onCropSelected: (crop) {
            setState(() {
              _selectedCrop = crop;
            });
            _analyzeImage();
          },
        );
      },
    );
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null || _selectedCrop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया फसल का चयन करें और फिर से प्रयास करें'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.detectDisease(_imageFile!, _selectedCrop!);

      if (mounted) {
        setState(() {
          _detectionResult = result;
          _hasAnalyzed = true;
          _isAnalyzing = false;
        });

        // Show interstitial ad after analysis
        final adService = Provider.of<AdService>(context, listen: false);
        await adService.showInterstitialAd(context);

        // Reload disease history
        _loadDiseaseHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('बीमारी का विश्लेषण करने में त्रुटि: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adService = Provider.of<AdService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('रोग पहचान'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show disease detection history
              _loadDiseaseHistory();
              _showDiseaseHistoryBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner ad at the top
          FutureBuilder<Widget>(
            future: adService.loadBanner(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              } else {
                return const SizedBox(height: 50);
              }
            },
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image selection card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'फसल की छवि अपलोड करें',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_imageFile != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedCrop != null)
                              Text(
                                'चयनित फसल: $_selectedCrop',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 8),
                          ] else
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'फोटो अपलोड करें या कैमरा से लें',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _isAnalyzing
                                    ? null
                                    : () => _getImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('गैलरी'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isAnalyzing
                                    ? null
                                    : () => _getImage(ImageSource.camera),
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('कैमरा'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Analysis button
                  if (_imageFile != null && !_hasAnalyzed)
                    ElevatedButton(
                      onPressed: _isAnalyzing
                          ? null
                          : () {
                              if (_selectedCrop == null) {
                                _showCropSelectionDialog();
                              } else {
                                _analyzeImage();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isAnalyzing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('विश्लेषण हो रहा है...'),
                              ],
                            )
                          : const Text('विश्लेषण करें'),
                    ),

                  const SizedBox(height: 16),

                  // Detection results
                  if (_hasAnalyzed && _detectionResult != null)
                    _buildDetectionResults(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionResults() {
    final confidence = (_detectionResult?['confidence_score'] as num?)?.toDouble() ?? 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'विश्लेषण परिणाम',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(confidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(confidence * 100).toStringAsFixed(0)}% विश्वास',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'बीमारी: ${_detectionResult?['disease_name'] ?? 'अज्ञात'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _detectionResult?['description'] ?? 'कोई विवरण उपलब्ध नहीं है',
            ),
            const SizedBox(height: 16),
            _buildSection(
              'लक्षण',
              _detectionResult?['symptoms'] as List<dynamic>? ?? [],
            ),
            _buildSection(
              'उपचार',
              _detectionResult?['treatments'] as List<dynamic>? ?? [],
            ),
            _buildSection(
              'रोकथाम',
              _detectionResult?['preventions'] as List<dynamic>? ?? [],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Save detection report
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('रिपोर्ट सहेजी गई'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('रिपोर्ट सहेजें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('कोई जानकारी उपलब्ध नहीं है')
        else
          Column(
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(item.toString())),
                        ],
                      ),
                    ))
                .toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showDiseaseHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => _isLoadingHistory
            ? const Center(child: CircularProgressIndicator())
            : _diseaseHistory.isEmpty
                ? const Center(child: Text('कोई रोग रिपोर्ट इतिहास नहीं है'))
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _diseaseHistory.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'रोग विश्लेषण इतिहास',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      final report = _diseaseHistory[index - 1];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(report.diseaseName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('फसल: ${report.cropType}'),
                              Text(
                                'दिनांक: ${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                              ),
                            ],
                          ),
                          leading: report.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    report.imageUrl!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                ),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Navigate to detailed report view
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}