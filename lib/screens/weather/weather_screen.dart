import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/weather/weather_card.dart';
import '../../utils/localization.dart';
import '../../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      await weatherProvider.fetchWeatherData(
        user.latitude,
        user.longitude,
        user.location,
      );
    }
  }

  Future<void> _refreshWeatherData() async {
    await _loadWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final localization = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate(AppStrings.weather) ?? AppStrings.weather,
      ),
      body: weatherProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _refreshWeatherData,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current weather
                      if (weatherProvider.currentWeather != null)
                        WeatherCard(
                          weather: weatherProvider.currentWeather!,
                          isDetailed: true,
                        )
                      else
                        _EmptyWeatherView(),
                      
                      const SizedBox(height: 24),
                      
                      // Weather forecast section
                      Text(
                        localization?.translate(AppStrings.forecast) ?? AppStrings.forecast,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Forecast cards
                      if (weatherProvider.forecastWeather.isNotEmpty)
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: weatherProvider.forecastWeather.length,
                            itemBuilder: (context, index) {
                              return _ForecastCard(
                                weather: weatherProvider.forecastWeather[index],
                              );
                            },
                          ),
                        )
                      else
                        Container(
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
                          child: Center(
                            child: Text(
                              'No forecast data available',
                              style: TextStyle(
                                color: AppColors.textLightColor,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Weather alerts section
                      if (weatherProvider.hasRainAlert || weatherProvider.hasTemperatureAlert) ...[
                        Text(
                          localization?.translate(AppStrings.alerts) ?? AppStrings.alerts,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        const SizedBox(height: 16),
                        
                        if (weatherProvider.hasRainAlert)
                          _AlertCard(
                            icon: Icons.water_drop,
                            title: 'Rain Alert',
                            message: weatherProvider.weatherAlert,
                            color: AppColors.infoColor,
                          ),
                        
                        if (weatherProvider.hasRainAlert && weatherProvider.hasTemperatureAlert)
                          const SizedBox(height: 12),
                        
                        if (weatherProvider.hasTemperatureAlert)
                          _AlertCard(
                            icon: Icons.device_thermostat,
                            title: 'Temperature Alert',
                            message: weatherProvider.temperatureAlert,
                            color: weatherProvider.currentWeather?.temperature ?? 0 > 38.0
                                ? AppColors.errorColor
                                : AppColors.warningColor,
                          ),
                        
                        const SizedBox(height: 24),
                      ],
                      
                      // Agricultural advisory section
                      Text(
                        'Agricultural Advisory',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      const SizedBox(height: 16),
                      
                      _AdvisoryCard(
                        weatherProvider: weatherProvider,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Data source disclaimer
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.infoColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.infoColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Weather data is provided for agricultural planning purposes only. Data is refreshed periodically.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.infoColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final Weather weather;

  const _ForecastCard({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day
          Text(
            DateFormat('E').format(weather.date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('MMM d').format(weather.date),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 12),
          
          // Weather icon
          Image.network(
            weather.getWeatherIcon(),
            height: 40,
            width: 40,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.cloud,
                size: 40,
                color: AppColors.primaryColor.withOpacity(0.5),
              );
            },
          ),
          const SizedBox(height: 8),
          
          // Description
          Text(
            weather.description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLightColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weather.minTemperature.round()}°',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLightColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${weather.maxTemperature.round()}°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _AlertCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  final WeatherProvider weatherProvider;

  const _AdvisoryCard({
    Key? key,
    required this.weatherProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Weather? currentWeather = weatherProvider.currentWeather;
    
    if (currentWeather == null) {
      return Container(
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
        child: Center(
          child: Text(
            'No advisory data available',
            style: TextStyle(
              color: AppColors.textLightColor,
            ),
          ),
        ),
      );
    }
    
    // Generate advisory based on weather conditions
    final List<Map<String, dynamic>> advisories = [];
    
    // Check for rain
    if (currentWeather.description.toLowerCase().contains('rain') || 
        currentWeather.precipitation > 0) {
      if (currentWeather.precipitation > 5) {
        advisories.add({
          'icon': Icons.water_drop,
          'title': 'Heavy Rain Expected',
          'description': 'Avoid spraying pesticides or fertilizers. Ensure proper drainage in the field.',
          'color': AppColors.infoColor,
        });
      } else {
        advisories.add({
          'icon': Icons.water_drop,
          'title': 'Light Rain Expected',
          'description': 'Good conditions for planting and transplanting. Reduce irrigation.',
          'color': AppColors.primaryColor,
        });
      }
    }
    
    // Check for temperature
    if (currentWeather.maxTemperature > 35) {
      advisories.add({
        'icon': Icons.wb_sunny,
        'title': 'High Temperature Alert',
        'description': 'Increase irrigation frequency. Provide shade for sensitive crops. Avoid field operations during peak heat.',
        'color': AppColors.errorColor,
      });
    } else if (currentWeather.minTemperature < 10) {
      advisories.add({
        'icon': Icons.ac_unit,
        'title': 'Low Temperature Alert',
        'description': 'Protect sensitive crops with covers. Delay sowing of heat-loving crops.',
        'color': AppColors.warningColor,
      });
    }
    
    // Check for humidity
    if (currentWeather.humidity > 80) {
      advisories.add({
        'icon': Icons.grain,
        'title': 'High Humidity Alert',
        'description': 'High risk of fungal diseases. Monitor crops closely and consider preventive fungicide application.',
        'color': AppColors.warningColor,
      });
    } else if (currentWeather.humidity < 30) {
      advisories.add({
        'icon': Icons.dry,
        'title': 'Low Humidity Alert',
        'description': 'Increased water evaporation. Adjust irrigation accordingly. Watch for water stress in plants.',
        'color': AppColors.warningColor,
      });
    }
    
    // General advisory based on overall conditions
    if (advisories.isEmpty) {
      if (currentWeather.description.toLowerCase().contains('clear') ||
          currentWeather.description.toLowerCase().contains('sunny')) {
        advisories.add({
          'icon': Icons.wb_sunny_outlined,
          'title': 'Favorable Conditions',
          'description': 'Good day for field operations like weeding, harvesting, and spraying.',
          'color': AppColors.successColor,
        });
      } else if (currentWeather.description.toLowerCase().contains('cloud')) {
        advisories.add({
          'icon': Icons.cloud_outlined,
          'title': 'Moderate Conditions',
          'description': 'Suitable for most field operations. Good time for transplanting.',
          'color': AppColors.primaryColor,
        });
      }
    }
    
    // If still no advisories, add a default one
    if (advisories.isEmpty) {
      advisories.add({
        'icon': Icons.eco_outlined,
        'title': 'Regular Monitoring',
        'description': 'Continue regular field monitoring and standard agricultural practices.',
        'color': AppColors.primaryColor,
      });
    }
    
    return Container(
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
          ...advisories.map((advisory) => Padding(
            padding: EdgeInsets.only(bottom: advisory != advisories.last ? 16.0 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: advisory['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    advisory['icon'],
                    color: advisory['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        advisory['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: advisory['color'],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        advisory['description'],
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

class _EmptyWeatherView extends StatelessWidget {
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
            Icons.cloud_off,
            size: 64,
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Weather data unavailable',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh or check your internet connection',
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
