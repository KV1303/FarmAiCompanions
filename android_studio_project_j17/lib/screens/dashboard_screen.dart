import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../services/api_service.dart';
import '../services/subscription_service.dart';
import '../services/firestore_service.dart';
import '../models/field_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  List<FieldModel> _fields = [];
  Map<String, dynamic>? _subscriptionStatus;
  String? _weatherLocation;
  Map<String, dynamic>? _weatherData;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load subscription status
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      final subscriptionStatus = await subscriptionService.getSubscriptionStatus();
      
      // Load fields
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final fields = await firestoreService.getUserFields();
      
      // Update state
      if (mounted) {
        setState(() {
          _subscriptionStatus = subscriptionStatus;
          _fields = fields;
          _isLoading = false;
        });
      }
      
      // Also try to load weather if we have a location
      if (_weatherLocation != null) {
        _loadWeather();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('त्रुटि: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _loadWeather() async {
    if (_weatherLocation == null) return;
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final weatherData = await apiService.getWeatherForecast(
        location: _weatherLocation!,
      );
      
      if (mounted) {
        setState(() {
          _weatherData = weatherData;
        });
      }
    } catch (e) {
      print('Error loading weather: $e');
      // Don't show error to user, just fail silently for weather
    }
  }

  @override
  Widget build(BuildContext context) {
    final adService = Provider.of<AdService>(context, listen: false);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('डैशबोर्ड'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subscription status card (if not subscribed)
                    if (_subscriptionStatus != null &&
                        !(_subscriptionStatus!['isSubscribed'] ?? false))
                      _buildSubscriptionCard(),
                      
                    const SizedBox(height: 16),
                    
                    // Weather summary card
                    _buildWeatherCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Fields summary
                    _buildFieldsSummary(),
                    
                    const SizedBox(height: 16),
                    
                    // Quick actions
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Banner ad
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
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSubscriptionCard() {
    final bool isInTrial = _subscriptionStatus?['isInTrial'] ?? false;
    final String? trialEndDate = _subscriptionStatus?['trialEndDate'];
    final String price = _subscriptionStatus?['price'] ?? '₹99';
    
    return Card(
      color: isInTrial ? Colors.blue.shade50 : Colors.amber.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isInTrial ? Icons.access_time : Icons.star,
                  color: isInTrial ? Colors.blue : Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  isInTrial ? 'निःशुल्क परीक्षण' : 'प्रीमियम बनें',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isInTrial
                  ? 'आपका निःशुल्क परीक्षण $trialEndDate को समाप्त हो जाएगा'
                  : 'सभी उन्नत सुविधाएँ और विज्ञापन मुक्त अनुभव के लिए अपग्रेड करें',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to subscription screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isInTrial ? Colors.blue : Colors.amber,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isInTrial
                    ? 'अभी सदस्यता लें'
                    : '$price वार्षिक सदस्यता लें',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherCard() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detailed weather screen
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'मौसम',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show location picker dialog
                      _showLocationPicker();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(_weatherLocation ?? 'स्थान चुनें'),
                      ],
                    ),
                  ),
                ],
              ),
              if (_weatherData != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_weatherData!['temperature']}°C',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _weatherData!['weatherCondition'] ?? 'सामान्य',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('आर्द्रता: ${_weatherData!['humidity']}%'),
                        Text('वर्षा: ${_weatherData!['precipitation']}mm'),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'मौसम जानकारी के लिए स्थान चुनें',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFieldsSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'मेरे खेत',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // TODO: Navigate to add field screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_fields.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'अभी तक कोई खेत नहीं जोड़ा गया है',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _fields.length,
                itemBuilder: (context, index) {
                  final field = _fields[index];
                  return ListTile(
                    title: Text(field.name),
                    subtitle: Text('${field.cropType} - ${field.area} ${field.areaUnit}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Navigate to field details screen
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'त्वरित कार्य',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'फसल सलाह',
                  Icons.eco,
                  Colors.green,
                  () async {
                    // Show interstitial ad before navigating
                    final adService = Provider.of<AdService>(context, listen: false);
                    await adService.showInterstitialAd(context);
                    
                    // TODO: Navigate to crop guidance screen
                  },
                ),
                _buildActionCard(
                  'मार्केट मूल्य',
                  Icons.monetization_on,
                  Colors.amber,
                  () async {
                    // Show interstitial ad before navigating
                    final adService = Provider.of<AdService>(context, listen: false);
                    await adService.showInterstitialAd(context);
                    
                    // TODO: Navigate to market prices screen
                  },
                ),
                _buildActionCard(
                  'रोग पहचान',
                  Icons.bug_report,
                  Colors.red,
                  () async {
                    // Show interstitial ad before navigating
                    final adService = Provider.of<AdService>(context, listen: false);
                    await adService.showInterstitialAd(context);
                    
                    // TODO: Navigate to disease detection screen
                  },
                ),
                _buildActionCard(
                  'AI सहायक',
                  Icons.chat,
                  Colors.blue,
                  () async {
                    // Show interstitial ad before navigating
                    final adService = Provider.of<AdService>(context, listen: false);
                    await adService.showInterstitialAd(context);
                    
                    // TODO: Navigate to AI assistant chat screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLocationPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('स्थान चुनें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Popular locations
            ListTile(
              title: const Text('दिल्ली'),
              onTap: () {
                setState(() {
                  _weatherLocation = 'Delhi';
                });
                _loadWeather();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('मुंबई'),
              onTap: () {
                setState(() {
                  _weatherLocation = 'Mumbai';
                });
                _loadWeather();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('लखनऊ'),
              onTap: () {
                setState(() {
                  _weatherLocation = 'Lucknow';
                });
                _loadWeather();
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('बैंगलोर'),
              onTap: () {
                setState(() {
                  _weatherLocation = 'Bangalore';
                });
                _loadWeather();
                Navigator.pop(context);
              },
            ),
            // Option to use current location (would need to implement location permissions)
            ListTile(
              title: const Text('वर्तमान स्थान का उपयोग करें'),
              leading: const Icon(Icons.my_location),
              onTap: () {
                // TODO: Implement location permission request and GPS
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('रद्द करें'),
          ),
        ],
      ),
    );
  }
}