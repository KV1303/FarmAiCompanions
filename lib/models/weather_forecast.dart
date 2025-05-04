class WeatherForecast {
  final int id;
  final String location;
  final DateTime forecastDate;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? humidity;
  final double? precipitation;
  final double? windSpeed;
  final String? weatherDescription;
  final DateTime updatedAt;
  final String? iconUrl;

  WeatherForecast({
    required this.id,
    required this.location,
    required this.forecastDate,
    this.temperatureMin,
    this.temperatureMax,
    this.humidity,
    this.precipitation,
    this.windSpeed,
    this.weatherDescription,
    required this.updatedAt,
    this.iconUrl,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      id: json['id'],
      location: json['location'],
      forecastDate: json['forecast_date'] != null
          ? DateTime.parse(json['forecast_date'])
          : DateTime.now(),
      temperatureMin: json['temperature_min'] != null
          ? json['temperature_min'].toDouble()
          : null,
      temperatureMax: json['temperature_max'] != null
          ? json['temperature_max'].toDouble()
          : null,
      humidity: json['humidity'] != null ? json['humidity'].toDouble() : null,
      precipitation: json['precipitation'] != null
          ? json['precipitation'].toDouble()
          : null,
      windSpeed: json['wind_speed'] != null
          ? json['wind_speed'].toDouble()
          : null,
      weatherDescription: json['weather_description'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      iconUrl: json['icon_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'forecast_date': forecastDate.toIso8601String(),
      'temperature_min': temperatureMin,
      'temperature_max': temperatureMax,
      'humidity': humidity,
      'precipitation': precipitation,
      'wind_speed': windSpeed,
      'weather_description': weatherDescription,
      'updated_at': updatedAt.toIso8601String(),
      'icon_url': iconUrl,
    };
  }
}