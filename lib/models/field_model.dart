import 'package:hive/hive.dart';

part 'field_model.g.dart';

@HiveType(typeId: 1)
class Field {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String ownerId;
  
  @HiveField(3)
  final String cropType;
  
  @HiveField(4)
  final double area;
  
  @HiveField(5)
  final String areaUnit;
  
  @HiveField(6)
  final double latitude;
  
  @HiveField(7)
  final double longitude;
  
  @HiveField(8)
  final DateTime sowingDate;
  
  @HiveField(9)
  final DateTime expectedHarvestDate;
  
  @HiveField(10)
  final double ndviIndex;
  
  @HiveField(11)
  final double soilMoisture;
  
  @HiveField(12)
  final String healthStatus;
  
  @HiveField(13)
  final String imageUrl;
  
  @HiveField(14)
  final DateTime lastUpdated;
  
  @HiveField(15)
  final DateTime createdAt;

  Field({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.cropType,
    required this.area,
    this.areaUnit = 'acres',
    required this.latitude,
    required this.longitude,
    required this.sowingDate,
    required this.expectedHarvestDate,
    this.ndviIndex = 0.0,
    this.soilMoisture = 0.0,
    this.healthStatus = 'Good',
    required this.imageUrl,
    required this.lastUpdated,
    required this.createdAt,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ownerId: json['owner_id'] ?? '',
      cropType: json['crop_type'] ?? '',
      area: json['area'] != null ? double.parse(json['area'].toString()) : 0.0,
      areaUnit: json['area_unit'] ?? 'acres',
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : 0.0,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : 0.0,
      sowingDate: json['sowing_date'] != null ? DateTime.parse(json['sowing_date']) : DateTime.now(),
      expectedHarvestDate: json['expected_harvest_date'] != null 
        ? DateTime.parse(json['expected_harvest_date']) 
        : DateTime.now().add(const Duration(days: 90)),
      ndviIndex: json['ndvi_index'] != null ? double.parse(json['ndvi_index'].toString()) : 0.0,
      soilMoisture: json['soil_moisture'] != null ? double.parse(json['soil_moisture'].toString()) : 0.0,
      healthStatus: json['health_status'] ?? 'Good',
      imageUrl: json['image_url'] ?? '',
      lastUpdated: json['last_updated'] != null ? DateTime.parse(json['last_updated']) : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'crop_type': cropType,
      'area': area,
      'area_unit': areaUnit,
      'latitude': latitude,
      'longitude': longitude,
      'sowing_date': sowingDate.toIso8601String(),
      'expected_harvest_date': expectedHarvestDate.toIso8601String(),
      'ndvi_index': ndviIndex,
      'soil_moisture': soilMoisture,
      'health_status': healthStatus,
      'image_url': imageUrl,
      'last_updated': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Field copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? cropType,
    double? area,
    String? areaUnit,
    double? latitude,
    double? longitude,
    DateTime? sowingDate,
    DateTime? expectedHarvestDate,
    double? ndviIndex,
    double? soilMoisture,
    String? healthStatus,
    String? imageUrl,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return Field(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      cropType: cropType ?? this.cropType,
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sowingDate: sowingDate ?? this.sowingDate,
      expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
      ndviIndex: ndviIndex ?? this.ndviIndex,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      healthStatus: healthStatus ?? this.healthStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate growth stage based on sowing date and expected harvest date
  String get growthStage {
    final totalGrowthDays = expectedHarvestDate.difference(sowingDate).inDays;
    final daysSinceSowing = DateTime.now().difference(sowingDate).inDays;
    
    final growthPercentage = (daysSinceSowing / totalGrowthDays) * 100;
    
    if (growthPercentage < 0) {
      return 'Not Planted';
    } else if (growthPercentage < 20) {
      return 'Germination';
    } else if (growthPercentage < 40) {
      return 'Vegetative';
    } else if (growthPercentage < 60) {
      return 'Flowering';
    } else if (growthPercentage < 80) {
      return 'Fruiting';
    } else if (growthPercentage < 100) {
      return 'Maturation';
    } else {
      return 'Ready for Harvest';
    }
  }
}

// This will be generated by Hive
class FieldAdapter extends TypeAdapter<Field> {
  @override
  final int typeId = 1;

  @override
  Field read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Field(
      id: fields[0] as String,
      name: fields[1] as String,
      ownerId: fields[2] as String,
      cropType: fields[3] as String,
      area: fields[4] as double,
      areaUnit: fields[5] as String,
      latitude: fields[6] as double,
      longitude: fields[7] as double,
      sowingDate: fields[8] as DateTime,
      expectedHarvestDate: fields[9] as DateTime,
      ndviIndex: fields[10] as double,
      soilMoisture: fields[11] as double,
      healthStatus: fields[12] as String,
      imageUrl: fields[13] as String,
      lastUpdated: fields[14] as DateTime,
      createdAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Field obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.cropType)
      ..writeByte(4)
      ..write(obj.area)
      ..writeByte(5)
      ..write(obj.areaUnit)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.sowingDate)
      ..writeByte(9)
      ..write(obj.expectedHarvestDate)
      ..writeByte(10)
      ..write(obj.ndviIndex)
      ..writeByte(11)
      ..write(obj.soilMoisture)
      ..writeByte(12)
      ..write(obj.healthStatus)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.lastUpdated)
      ..writeByte(15)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
