import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_images.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/market_provider.dart';
import '../../models/field_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/field/field_card.dart';
import '../../widgets/weather/weather_card.dart';
import '../../widgets/market/price_card.dart';
import '../../utils/localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const _HomeContent(),
    const _PlaceholderScreen(icon: Icons.satellite_alt, title: 'Field Monitoring'),
    const _PlaceholderScreen(icon: Icons.bug_report, title: 'Disease Detection'),
    const _PlaceholderScreen(icon: Icons.bar_chart, title: 'Market Prices'),
    const _PlaceholderScreen(icon: Icons.person, title: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      // Load fields for this user
      await fieldProvider.fetchFields(user.id);
      
      // Load weather for user's location
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.fetchWeatherData(
        user.latitude, 
        user.longitude, 
        user.location,
      );
      
      // Load market prices for user's first field (if any)
      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
      if (fieldProvider.fields.isNotEmpty) {
        final field = fieldProvider.fields.first;
        await marketProvider.fetchMarketPrices(
          field.cropType,
          'Maharashtra', // Default state for demo
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to the corresponding screen
    if (index == 1) {
      Navigator.pushNamed(context, '/field_dashboard');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/disease_detection');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/market_prices');
    } else if (index == 4) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() {
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textLightColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.satellite_alt_outlined),
            activeIcon: Icon(Icons.satellite_alt),
            label: 'Fields',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report_outlined),
            activeIcon: Icon(Icons.bug_report),
            label: 'Diseases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({Key? key}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final fieldProvider = Provider.of<FieldProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final marketProvider = Provider.of<MarketProvider>(context);
    final localization = AppLocalizations.of(context);
    
    if (authProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    
    final user = authProvider.user;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: '${localization?.translate(AppStrings.welcome) ?? AppStrings.welcome}, ${user?.name ?? "Farmer"}!',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localization?.translate(AppStrings.noNotifications) ?? AppStrings.noNotifications),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather card
                if (weatherProvider.currentWeather != null)
                  WeatherCard(weather: weatherProvider.currentWeather!),
                
                const SizedBox(height: 24),
                
                // Fields section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization?.translate(AppStrings.yourFields) ?? AppStrings.yourFields,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/field_dashboard');
                      },
                      child: Text(
                        localization?.translate(AppStrings.viewAll) ?? AppStrings.viewAll,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Fields list
                fieldProvider.isLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: LoadingIndicator(),
                      ))
                    : fieldProvider.fields.isEmpty
                        ? _EmptyFieldsView()
                        : SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fieldProvider.fields.length + 1, // +1 for the add button
                              itemBuilder: (context, index) {
                                if (index == fieldProvider.fields.length) {
                                  // Add new field button
                                  return _AddFieldCard();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: FieldCard(
                                    field: fieldProvider.fields[index],
                                    onTap: () {
                                      fieldProvider.selectField(fieldProvider.fields[index].id);
                                      Navigator.pushNamed(context, '/field_dashboard');
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                
                const SizedBox(height: 24),
                
                // Market Price section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization?.translate(AppStrings.marketPrices) ?? AppStrings.marketPrices,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/market_prices');
                      },
                      child: Text(
                        localization?.translate(AppStrings.viewAll) ?? AppStrings.viewAll,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Market prices
                marketProvider.isLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: LoadingIndicator(),
                      ))
                    : marketProvider.marketPrices.isEmpty
                        ? _EmptyMarketView()
                        : SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: marketProvider.marketPrices.length > 3 
                                  ? 3 
                                  : marketProvider.marketPrices.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: PriceCard(
                                    price: marketProvider.marketPrices[index],
                                    onTap: () {
                                      marketProvider.selectMarketPrice(marketProvider.marketPrices[index].id);
                                      Navigator.pushNamed(context, '/market_prices');
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                
                const SizedBox(height: 24),
                
                // Quick actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headline3,
                ),
                
                const SizedBox(height: 16),
                
                // Quick action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickActionButton(
                      icon: Icons.camera_alt,
                      label: 'Detect Disease',
                      onTap: () {
                        Navigator.pushNamed(context, '/disease_detection');
                      },
                    ),
                    _QuickActionButton(
                      icon: Icons.cloud,
                      label: 'Weather',
                      onTap: () {
                        Navigator.pushNamed(context, '/weather');
                      },
                    ),
                    _QuickActionButton(
                      icon: Icons.add_chart,
                      label: 'Add Field',
                      onTap: () {
                        // Navigate to add field page
                        Navigator.pushNamed(context, '/field_dashboard');
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      // Load fields for this user
      await fieldProvider.fetchFields(user.id);
      
      // Load weather for user's location
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.fetchWeatherData(
        user.latitude, 
        user.longitude, 
        user.location,
      );
      
      // Load market prices for user's first field (if any)
      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
      if (fieldProvider.fields.isNotEmpty) {
        final field = fieldProvider.fields.first;
        await marketProvider.fetchMarketPrices(
          field.cropType,
          'Maharashtra', // Default state for demo
        );
      }
    }
  }
}

class _EmptyFieldsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grass,
              size: 40,
              color: AppColors.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No fields added yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/field_dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                localization?.translate(AppStrings.addNewField) ?? AppStrings.addNewField,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMarketView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 40,
              color: AppColors.accentColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'No market data available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add fields to see market prices',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFieldCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/field_dashboard');
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor, width: 1, style: BorderStyle.dashed),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLightColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 32,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localization?.translate(AppStrings.addNewField) ?? AppStrings.addNewField,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLightColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;

  const _PlaceholderScreen({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Navigating to $title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait...',
              style: TextStyle(
                color: AppColors.textLightColor,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
