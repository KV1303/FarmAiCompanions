import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/ad_service.dart';
import '../models/market_price_model.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({Key? key}) : super(key: key);

  @override
  _MarketPricesScreenState createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  bool _isLoading = true;
  List<dynamic> _prices = [];
  List<dynamic> _favorites = [];
  String? _selectedCrop;

  // List of available crops
  final List<String> _crops = [
    'चावल', // Rice
    'गेहूं', // Wheat
    'मक्का', // Maize
    'बाजरा', // Millet
    'चना', // Chickpea
    'सोयाबीन', // Soybean
    'सरसों', // Mustard
    'कपास', // Cotton
    'गन्ना', // Sugarcane
    'प्याज', // Onion
    'आलू', // Potato
    'टमाटर', // Tomato
  ];

  // Map Hindi crop names to English for API calls
  final Map<String, String> _cropNameMap = {
    'चावल': 'Rice',
    'गेहूं': 'Wheat',
    'मक्का': 'Maize',
    'बाजरा': 'Millet',
    'चना': 'Chickpea',
    'सोयाबीन': 'Soybean',
    'सरसों': 'Mustard',
    'कपास': 'Cotton',
    'गन्ना': 'Sugarcane',
    'प्याज': 'Onion',
    'आलू': 'Potato',
    'टमाटर': 'Tomato',
  };

  @override
  void initState() {
    super.initState();
    _loadMarketPrices();
    _loadFavorites();
  }

  Future<void> _loadMarketPrices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      List<dynamic> prices;

      if (_selectedCrop != null) {
        final englishCropName = _cropNameMap[_selectedCrop] ?? _selectedCrop;
        prices = await apiService.getMarketPrices(cropType: englishCropName);
      } else {
        prices = await apiService.getMarketPrices();
      }

      if (mounted) {
        setState(() {
          _prices = prices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('मार्केट मूल्य लोड करने में त्रुटि: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final favorites = await apiService.getMarketFavorites();

      if (mounted) {
        setState(() {
          _favorites = favorites;
        });
      }
    } catch (e) {
      print('Error loading favorites: $e');
      // Don't show error to user, just fail silently for favorites
    }
  }

  @override
  Widget build(BuildContext context) {
    final adService = Provider.of<AdService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('मार्केट मूल्य'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMarketPrices();
              _loadFavorites();
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

          // Filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'फसल चुनें:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: _selectedCrop,
                      hint: const Text('सभी फसलें'),
                      onChanged: (value) {
                        setState(() {
                          _selectedCrop = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('सभी फसलें'),
                        ),
                        ..._crops.map((crop) => DropdownMenuItem<String>(
                              value: crop,
                              child: Text(crop),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show interstitial ad before applying filter
                      final adService = Provider.of<AdService>(context, listen: false);
                      await adService.showInterstitialAd(context);
                      
                      _loadMarketPrices();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('फ़िल्टर लागू करें'),
                  ),
                ),
              ],
            ),
          ),

          // Market prices list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _prices.isEmpty
                    ? const Center(
                        child: Text('कोई मार्केट मूल्य उपलब्ध नहीं है'),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMarketPrices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: _prices.length,
                          itemBuilder: (context, index) {
                            final price = _prices[index];
                            final isInWatchlist = _isCropInWatchlist(price['crop_type']);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              child: ListTile(
                                title: Text(
                                  _getHindiCropName(price['crop_type']) ?? price['crop_type'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('मंडी: ${price['market_name']}'),
                                    Text(
                                      'मूल्य: ₹${price['price']}/क्विंटल',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      'रेंज: ₹${price['min_price']} - ₹${price['max_price']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isInWatchlist
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: isInWatchlist ? Colors.amber : null,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement add/remove from watchlist
                                    _toggleWatchlist(price['crop_type']);
                                  },
                                ),
                                onTap: () {
                                  // TODO: Show detailed price view
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Helper method to check if a crop is in the user's watchlist
  bool _isCropInWatchlist(String cropType) {
    return _favorites.any((favorite) => favorite['crop_type'] == cropType);
  }

  // Helper method to toggle watchlist status
  void _toggleWatchlist(String cropType) {
    // TODO: Implement API call to add/remove from watchlist
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCropInWatchlist(cropType)
              ? '$cropType वॉचलिस्ट से हटा दिया गया'
              : '$cropType वॉचलिस्ट में जोड़ा गया',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    
    // For now, just update the UI
    setState(() {
      if (_isCropInWatchlist(cropType)) {
        _favorites.removeWhere((favorite) => favorite['crop_type'] == cropType);
      } else {
        _favorites.add({
          'crop_type': cropType,
          'isAlertEnabled': false,
        });
      }
    });
  }

  // Helper method to convert English crop name to Hindi
  String? _getHindiCropName(String englishName) {
    return _cropNameMap.entries
        .firstWhere(
          (entry) => entry.value == englishName,
          orElse: () => const MapEntry('', ''),
        )
        .key
        .isNotEmpty
        ? _cropNameMap.entries
            .firstWhere(
              (entry) => entry.value == englishName,
              orElse: () => const MapEntry('', ''),
            )
            .key
        : null;
  }
}