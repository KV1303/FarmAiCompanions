class DiseaseReport {
  final int id;
  final int userId;
  final int fieldId;
  final String diseaseName;
  final DateTime detectionDate;
  final double? confidenceScore;
  final String? imagePath;
  final String? symptoms;
  final String? treatmentRecommendations;
  final String status;
  final String? notes;

  DiseaseReport({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.diseaseName,
    required this.detectionDate,
    this.confidenceScore,
    this.imagePath,
    this.symptoms,
    this.treatmentRecommendations,
    required this.status,
    this.notes,
  });

  factory DiseaseReport.fromJson(Map<String, dynamic> json) {
    return DiseaseReport(
      id: json['id'],
      userId: json['user_id'],
      fieldId: json['field_id'],
      diseaseName: json['disease_name'],
      detectionDate: json['detection_date'] != null 
          ? DateTime.parse(json['detection_date']) 
          : DateTime.now(),
      confidenceScore: json['confidence_score'] != null 
          ? json['confidence_score'].toDouble() 
          : null,
      imagePath: json['image_path'],
      symptoms: json['symptoms'],
      treatmentRecommendations: json['treatment_recommendations'],
      status: json['status'] ?? 'detected',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'field_id': fieldId,
      'disease_name': diseaseName,
      'detection_date': detectionDate.toIso8601String(),
      'confidence_score': confidenceScore,
      'image_path': imagePath,
      'symptoms': symptoms,
      'treatment_recommendations': treatmentRecommendations,
      'status': status,
      'notes': notes,
    };
  }
}