import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_images.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/market/price_chart.dart';
import '../../widgets/market/price_card.dart';
import '../../utils/localization.dart';
import '../../models/market_price_model.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({Key? key}) : super(key: key);

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCrop = '';
  String _selectedState = 'Maharashtra';
  List<String> _crops = [];
  List<String> _states = [
    'Maharashtra',
    'Karnataka',
    'Madhya Pradesh',
    'Uttar Pradesh',
    'Gujarat',
    'Punjab',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final fieldProvider = Provider.of<FieldProvider>(context, listen: false);
    
    // Get crop types from user's fields
    final fields = fieldProvider.fields;
    final cropSet = <String>{};
    for (final field in fields) {
      cropSet.add(field.cropType);
    }
    
    setState(() {
      _crops = cropSet.toList();
      if (_crops.isNotEmpty) {
        _selectedCrop = _crops.first;
      } else {
        // Use default crops if user has no fields
        _crops = AppStrings.cropTypes.take(5).toList();
        _selectedCrop = _crops.first;
      }
    });
    
    // Load market prices for the selected crop
    await _loadMarketPrices();
  }

  Future<void> _loadMarketPrices() async {
    if (_selectedCrop.isEmpty) return;
    
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);
    await marketProvider.fetchMarketPrices(_selectedCrop, _selectedState);
    
    // Load historical data if there are prices available
    if (marketProvider.marketPrices.isNotEmpty) {
      final firstPrice = marketProvider.marketPrices.first;
      await marketProvider.fetchHistoricalPrices(_selectedCrop, firstPrice.marketName);
    }
  }

  void _onCropChanged(String? value) {
    if (value != null && value != _selectedCrop) {
      setState(() {
        _selectedCrop = value;
      });
      _loadMarketPrices();
    }
  }

  void _onStateChanged(String? value) {
    if (value != null && value != _selectedState) {
      setState(() {
        _selectedState = value;
      });
      _loadMarketPrices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    final localization = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate(AppStrings.marketPriceTracker) ?? AppStrings.marketPriceTracker,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Crop & State',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLightColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Crop dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCrop,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: _crops.map((String crop) {
                              return DropdownMenuItem<String>(
                                value: crop,
                                child: Text(crop),
                              );
                            }).toList(),
                            onChanged: _onCropChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // State dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedState,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: _states.map((String state) {
                              return DropdownMenuItem<String>(
                                value: state,
                                child: Text(state),
                              );
                            }).toList(),
                            onChanged: _onStateChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textLightColor,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Current Prices'),
              Tab(text: 'Price History'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Current prices tab
                _CurrentPricesTab(
                  onRefresh: _loadMarketPrices,
                ),
                
                // Price history tab
                _PriceHistoryTab(
                  crop: _selectedCrop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPricesTab extends StatelessWidget {
  final Function onRefresh;

  const _CurrentPricesTab({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    
    if (marketProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    
    if (marketProvider.marketPrices.isEmpty) {
      return _EmptyPricesView(onRefresh: onRefresh);
    }
    
    return RefreshIndicator(
      onRefresh: () => onRefresh(),
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: marketProvider.marketPrices.length,
        itemBuilder: (context, index) {
          final price = marketProvider.marketPrices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => marketProvider.selectMarketPrice(price.id),
              child: _MarketPriceItem(price: price),
            ),
          );
        },
      ),
    );
  }
}

class _MarketPriceItem extends StatelessWidget {
  final MarketPrice price;

  const _MarketPriceItem({
    Key? key,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with market name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    price.marketName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    price.district,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Price details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop name
                Row(
                  children: [
                    const Icon(
                      Icons.grass,
                      size: 16,
                      color: AppColors.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      price.cropName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Prices
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PriceColumn(
                      label: AppStrings.minPrice,
                      price: price.minPrice,
                      color: AppColors.errorColor,
                    ),
                    _PriceColumn(
                      label: AppStrings.modalPrice,
                      price: price.modalPrice,
                      color: AppColors.primaryColor,
                      isHighlighted: true,
                    ),
                    _PriceColumn(
                      label: AppStrings.maxPrice,
                      price: price.maxPrice,
                      color: AppColors.successColor,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Date and unit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textLightColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(price.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'per ${price.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLightColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceColumn extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  final bool isHighlighted;

  const _PriceColumn({
    Key? key,
    required this.label,
    required this.price,
    required this.color,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted
            ? Border.all(color: color.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isHighlighted ? color : AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                AppStrings.rupeeSymbol,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                price.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 18,
                  color: color,
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

class _PriceHistoryTab extends StatelessWidget {
  final String crop;

  const _PriceHistoryTab({
    Key? key,
    required this.crop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketProvider>(context);
    
    if (marketProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    
    if (marketProvider.historicalPrices.isEmpty) {
      return Center(
        child: Text(
          'No historical data available for $crop',
          style: TextStyle(
            color: AppColors.textLightColor,
          ),
        ),
      );
    }
    
    // Get price trend information
    final priceTrend = marketProvider.getPriceTrend(
      crop,
      marketProvider.historicalPrices.first.marketName,
    );
    
    // Get price forecast
    final forecast = marketProvider.getPriceForecast(
      crop,
      marketProvider.historicalPrices.first.marketName,
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market info header
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.grass,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      crop,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  marketProvider.historicalPrices.first.marketName,
                  style: TextStyle(
                    color: AppColors.textLightColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Price trend
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTrendColor(priceTrend['trend']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getTrendIcon(priceTrend['trend']),
                        color: _getTrendColor(priceTrend['trend']),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Trend',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTrendColor(priceTrend['trend']),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getTrendDescription(
                                priceTrend['trend'], 
                                priceTrend['percentage'],
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Price history chart
          Text(
            'Price History (Last 30 Days)',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
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
            child: PriceChart(
              prices: marketProvider.historicalPrices,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Price forecast section
          Text(
            'Price Forecast (Next 7 Days)',
            style: Theme.of(context).textTheme.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            'Based on historical trends and seasonal patterns',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textLightColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Forecast cards
          if (forecast.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 130,
                    margin: EdgeInsets.only(right: index < forecast.length - 1 ? 12 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          DateFormat('MMM dd').format(forecast[index].date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE').format(forecast[index].date),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Price
                        const Text(
                          'Predicted Price',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              AppStrings.rupeeSymbol,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              forecast[index].modalPrice.toStringAsFixed(0),
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'per ${forecast[index].unit}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textLightColor,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Price change indicator
                        _getPriceChangeIndicator(
                          index > 0
                              ? forecast[index].modalPrice - forecast[index - 1].modalPrice
                              : forecast[index].modalPrice - 
                                  marketProvider.historicalPrices.last.modalPrice,
                        ),
                      ],
                    ),
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
                  'Insufficient data for price forecast',
                  style: TextStyle(
                    color: AppColors.textLightColor,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Disclaimer
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
                    'Market prices are indicative and may vary. Data sourced from eNAM.',
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
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up':
        return AppColors.successColor;
      case 'down':
        return AppColors.errorColor;
      default:
        return AppColors.infoColor;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.trending_up;
      case 'down':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  String _getTrendDescription(String trend, double percentage) {
    switch (trend) {
      case 'up':
        return 'Prices have increased by ${percentage.toStringAsFixed(1)}% compared to last week';
      case 'down':
        return 'Prices have decreased by ${percentage.toStringAsFixed(1)}% compared to last week';
      default:
        return 'Prices have remained stable compared to last week';
    }
  }

  Widget _getPriceChangeIndicator(double change) {
    final color = change > 0 ? AppColors.successColor : (change < 0 ? AppColors.errorColor : AppColors.infoColor);
    final icon = change > 0 ? Icons.arrow_upward : (change < 0 ? Icons.arrow_downward : Icons.arrow_forward);
    final text = change > 0 
        ? '+${change.abs().toStringAsFixed(0)}' 
        : (change < 0 ? '-${change.abs().toStringAsFixed(0)}' : '0');
    
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 12,
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _EmptyPricesView extends StatelessWidget {
  final Function onRefresh;

  const _EmptyPricesView({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              AppImages.vegetableMarket1,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.shopping_basket,
                  size: 100,
                  color: AppColors.primaryColor.withOpacity(0.5),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'No Market Prices Available',
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We couldn\'t find any market prices for the selected crop and state',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLightColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Refresh Prices',
              onPressed: () => onRefresh(),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}
