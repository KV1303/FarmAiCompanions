class Field {
  final int id;
  final int userId;
  final String name;
  final String? location;
  final double? area;
  final String? cropType;
  final DateTime? plantingDate;
  final String? soilType;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String? notes;
  final Map<String, dynamic>? satelliteData;
  final Map<String, dynamic>? weatherData;

  Field({
    required this.id,
    required this.userId,
    required this.name,
    this.location,
    this.area,
    this.cropType,
    this.plantingDate,
    this.soilType,
    required this.createdAt,
    required this.lastUpdated,
    this.notes,
    this.satelliteData,
    this.weatherData,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      location: json['location'],
      area: json['area'] != null ? json['area'].toDouble() : null,
      cropType: json['crop_type'],
      plantingDate: json['planting_date'] != null 
          ? DateTime.parse(json['planting_date']) 
          : null,
      soilType: json['soil_type'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated']) 
          : DateTime.now(),
      notes: json['notes'],
      satelliteData: json['satellite_data'],
      weatherData: json['weather_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'location': location,
      'area': area,
      'crop_type': cropType,
      'planting_date': plantingDate?.toIso8601String(),
      'soil_type': soilType,
      'created_at': createdAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'notes': notes,
      'satellite_data': satelliteData,
      'weather_data': weatherData,
    };
  }
}