class MarketPrice {
  final int id;
  final String cropType;
  final String marketName;
  final double price;
  final double? minPrice;
  final double? maxPrice;
  final DateTime date;
  final String? source;

  MarketPrice({
    required this.id,
    required this.cropType,
    required this.marketName,
    required this.price,
    this.minPrice,
    this.maxPrice,
    required this.date,
    this.source,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      id: json['id'],
      cropType: json['crop_type'],
      marketName: json['market_name'],
      price: json['price'].toDouble(),
      minPrice: json['min_price'] != null ? json['min_price'].toDouble() : null,
      maxPrice: json['max_price'] != null ? json['max_price'].toDouble() : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_type': cropType,
      'market_name': marketName,
      'price': price,
      'min_price': minPrice,
      'max_price': maxPrice,
      'date': date.toIso8601String(),
      'source': source,
    };
  }
}