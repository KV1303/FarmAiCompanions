import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_images.dart';
import '../../providers/disease_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/disease/disease_card.dart';
import '../../utils/localization.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  Future<void> _loadDiseases() async {
    final diseaseProvider = Provider.of<DiseaseProvider>(context, listen: false);
    await diseaseProvider.loadDiseases();
  }

  Future<void> _pickImage(ImageSource source) async {
    final diseaseProvider = Provider.of<DiseaseProvider>(context, listen: false);
    await diseaseProvider.pickImage(source);
  }

  Future<void> _analyzeImage() async {
    final diseaseProvider = Provider.of<DiseaseProvider>(context, listen: false);
    final success = await diseaseProvider.analyzeImage();
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(diseaseProvider.error),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diseaseProvider = Provider.of<DiseaseProvider>(context);
    final localization = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate(AppStrings.diseaseDetection) ?? AppStrings.diseaseDetection,
      ),
      body: diseaseProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image upload section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Upload Crop Image',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Take a clear photo of the affected plant part for accurate disease detection',
                            style: TextStyle(
                              color: AppColors.textLightColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          // Image preview
                          if (diseaseProvider.selectedImage != null)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    diseaseProvider.selectedImage!,
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => diseaseProvider.clearDetection(),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 20,
                                        color: AppColors.errorColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 1,
                                    style: BorderStyle.dashed,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 64,
                                      color: AppColors.primaryColor.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tap to select or capture an image',
                                      style: TextStyle(
                                        color: AppColors.textLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: localization?.translate(AppStrings.takePicture) ?? AppStrings.takePicture,
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: Icons.camera_alt,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: localization?.translate(AppStrings.selectFromGallery) ?? AppStrings.selectFromGallery,
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: Icons.photo_library,
                                  backgroundColor: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                          
                          if (diseaseProvider.selectedImage != null) ...[
                            const SizedBox(height: 16),
                            CustomButton(
                              text: diseaseProvider.isAnalyzing
                                  ? localization?.translate(AppStrings.analyzing) ?? AppStrings.analyzing
                                  : 'Analyze Disease',
                              onPressed: diseaseProvider.isAnalyzing ? null : _analyzeImage,
                              icon: Icons.search,
                              backgroundColor: AppColors.infoColor,
                              isLoading: diseaseProvider.isAnalyzing,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Detection result
                    if (diseaseProvider.detectedDisease != null) ...[
                      const SizedBox(height: 32),
                      Text(
                        localization?.translate(AppStrings.detectedDisease) ?? AppStrings.detectedDisease,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(height: 16),
                      DiseaseCard(
                        disease: diseaseProvider.detectedDisease!,
                      ),
                    ],
                    
                    // Common diseases section
                    const SizedBox(height: 32),
                    Text(
                      'Common Crop Diseases',
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    const SizedBox(height: 16),
                    
                    diseaseProvider.diseases.isEmpty
                        ? _EmptyDiseasesView()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: diseaseProvider.diseases.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DiseaseCard(
                                  disease: diseaseProvider.diseases[index],
                                  isExpanded: false,
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourceDialog,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class _EmptyDiseasesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.bug_report,
            size: 64,
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No disease information available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo of your crop to detect diseases',
            style: TextStyle(
              color: AppColors.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
