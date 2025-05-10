import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/premium_article.dart';
import '../utils/common_utils.dart';

/// Service for handling premium content operations
class ContentService {
  /// Local cache key for storing fetched premium articles
  static const String _cacheKey = 'premium_articles_cache';
  
  /// Fetches premium articles, either from the API or from local cache
  static Future<List<PremiumArticle>> getPremiumArticles({String category = 'all'}) async {
    try {
      // Check if we have a cached version first
      final cachedData = await CommonUtils.loadDataFromLocalStorage(_cacheKey);
      
      if (cachedData != null) {
        final List<PremiumArticle> articles = (cachedData as List)
            .map((item) => PremiumArticle.fromJson(item))
            .toList();
            
        // Filter by category if needed
        if (category != 'all') {
          return articles.where((article) => article.topic.toLowerCase() == category.toLowerCase()).toList();
        }
        
        return articles;
      }
      
      // If no cache or cache expired, fetch from API
      final articles = await _fetchPremiumArticlesFromApi();
      
      // Cache the results
      await CommonUtils.saveDataToLocalStorage(
        _cacheKey, 
        articles.map((article) => article.toJson()).toList()
      );
      
      // Filter by category if needed
      if (category != 'all') {
        return articles.where((article) => article.topic.toLowerCase() == category.toLowerCase()).toList();
      }
      
      return articles;
    } catch (e) {
      // If API call fails, try to use cached data
      final cachedData = await CommonUtils.loadDataFromLocalStorage(_cacheKey);
      
      if (cachedData != null) {
        final List<PremiumArticle> articles = (cachedData as List)
            .map((item) => PremiumArticle.fromJson(item))
            .toList();
            
        // Filter by category if needed
        if (category != 'all') {
          return articles.where((article) => article.topic.toLowerCase() == category.toLowerCase()).toList();
        }
        
        return articles;
      }
      
      // If both API and cache fail, return sample data
      return _getSamplePremiumArticles();
    }
  }
  
  /// Fetches premium articles from the API
  static Future<List<PremiumArticle>> _fetchPremiumArticlesFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.farmassistai.com/premium/articles'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => PremiumArticle.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load premium articles: ${response.statusCode}');
      }
    } catch (e) {
      // For development/demo: return sample data instead of throwing
      return _getSamplePremiumArticles();
    }
  }
  
  /// Returns sample premium articles for development/demo purposes
  static List<PremiumArticle> _getSamplePremiumArticles() {
    return [
      PremiumArticle(
        id: 'premium-article-1',
        title: 'गेहूं की उन्नत खेती: आधुनिक तकनीकें और अधिक उपज',
        author: 'डॉ. राजेश सिंह',
        date: '05 अप्रैल, 2025',
        topic: 'wheat',
        introduction: 'गेहूं भारत की प्रमुख खाद्य फसलों में से एक है। इस लेख में हम आधुनिक तकनीकों के उपयोग से गेहूं की खेती में उपज बढ़ाने के तरीके बताएंगे।',
        conclusion: 'उपरोक्त आधुनिक तकनीकों और सिफारिशों का अनुसरण करके किसान गेहूं की उपज में 25-30% तक की वृद्धि कर सकते हैं। साथ ही, स्थायी कृषि पद्धतियों का उपयोग मिट्टी की उर्वरता को भी बनाए रखेगा।',
        sections: [
          ArticleSection(
            heading: 'मिट्टी की तैयारी',
            content: 'गेहूं की अच्छी फसल के लिए मिट्टी की तैयारी महत्वपूर्ण है। जुताई के समय 10-15 टन प्रति हेक्टेयर गोबर की खाद मिलाना चाहिए। 2-3 जुताई के बाद पाटा लगाकर खेत को समतल कर लें।',
          ),
          ArticleSection(
            heading: 'उन्नत किस्में',
            content: 'अपने क्षेत्र के लिए अनुशंसित उन्नत गेहूं की किस्मों का चयन करें। पीबीडब्ल्यू-343, एचडी-2967, एचडी-3086 आदि किस्में अधिक उपज देने वाली हैं और विभिन्न जलवायु में अच्छी तरह से विकसित होती हैं।',
          ),
          ArticleSection(
            heading: 'बुवाई का समय और विधि',
            content: 'उत्तर भारत में गेहूं की बुवाई का सबसे उपयुक्त समय 10 नवंबर से 25 नवंबर तक है। सीड ड्रिल से बुवाई करने पर पंक्ति से पंक्ति की दूरी 20-22 सेमी रखें। बीज की मात्रा 100-125 किलोग्राम प्रति हेक्टेयर पर्याप्त होती है।',
          ),
          ArticleSection(
            heading: 'समेकित पोषक तत्व प्रबंधन',
            content: 'नाइट्रोजन (120 किग्रा/हे), फास्फोरस (60 किग्रा/हे) और पोटाश (40 किग्रा/हे) का उपयोग करें। फास्फोरस और पोटाश की पूरी मात्रा तथा नाइट्रोजन की एक तिहाई मात्रा बुवाई के समय दें। शेष नाइट्रोजन दो बराबर भागों में पहली सिंचाई (21-25 दिन) और दूसरी सिंचाई (45-50 दिन) के बाद दें।',
          ),
          ArticleSection(
            heading: 'सिंचाई प्रबंधन',
            content: 'गेहूं की फसल में आमतौर पर 5-6 सिंचाई की आवश्यकता होती है। पहली सिंचाई बुवाई के 20-25 दिन बाद, दूसरी 45-50 दिन बाद, तीसरी 65-70 दिन बाद, चौथी 90-95 दिन बाद तथा पांचवीं 110-115 दिन बाद करें। स्प्रिंकलर या ड्रिप सिंचाई विधि अपनाकर पानी की बचत की जा सकती है।',
          ),
        ],
        references: [
          'भारतीय कृषि अनुसंधान संस्थान, नई दिल्ली',
          'कृषि विज्ञान केंद्र, भारतीय कृषि अनुसंधान परिषद',
          'राष्ट्रीय गेहूं अनुसंधान केंद्र, करनाल',
        ],
        imageUrl: 'https://example.com/wheat_farming.jpg',
      ),
      PremiumArticle(
        id: 'premium-article-2',
        title: 'धान की खेती में जल प्रबंधन: सिंचाई की आधुनिक तकनीकें',
        author: 'डॉ. अमित शर्मा',
        date: '15 अप्रैल, 2025',
        topic: 'rice',
        introduction: 'धान की खेती में पानी का उचित प्रबंधन बहुत महत्वपूर्ण है। यह लेख धान की खेती में पानी के कुशल उपयोग और आधुनिक सिंचाई तकनीकों पर विस्तृत जानकारी प्रदान करता है।',
        conclusion: 'धान की खेती में पानी का कुशल प्रबंधन न केवल उत्पादन लागत को कम करता है बल्कि पर्यावरण संरक्षण में भी सहायक होता है। आधुनिक सिंचाई तकनीकों और फसल विविधीकरण द्वारा जल संरक्षण के साथ अच्छी उपज प्राप्त की जा सकती है।',
        sections: [
          ArticleSection(
            heading: 'धान की खेती में पानी की आवश्यकता',
            content: 'पारंपरिक धान की खेती में लगभग 1500-2000 मिमी पानी की आवश्यकता होती है। हालांकि, आधुनिक तकनीकों द्वारा इस मात्रा को 1000-1200 मिमी तक कम किया जा सकता है।',
          ),
          ArticleSection(
            heading: 'सूखा सहिष्णु धान की खेती',
            content: 'सूखा सहिष्णु धान की खेती में खेत को निरंतर जलमग्न रखने की आवश्यकता नहीं होती। इसमें केवल मिट्टी को नम रखा जाता है, जिससे पानी की 30-50% बचत होती है। इसके लिए सहजन 5, सहभागी, एमटीयू-1010 जैसी किस्मों का चयन करें।',
          ),
          ArticleSection(
            heading: 'सिंचाई की आधुनिक विधियां',
            content: 'स्प्रिंकलर और ड्रिप सिंचाई: हालांकि पारंपरिक रूप से धान में ये विधियां कम प्रचलित हैं, लेकिन नई तकनीकों के साथ इनका उपयोग संभव है। ड्रिप फर्टिगेशन से पानी और उर्वरकों का कुशल उपयोग होता है।\n\nवैकल्पिक गीला और सूखा सिंचाई (AWD): इस विधि में खेत को बारी-बारी से गीला और सूखा किया जाता है, जिससे 25-30% पानी की बचत होती है।',
          ),
          ArticleSection(
            heading: 'श्री विधि (System of Rice Intensification)',
            content: 'श्री विधि में 8-12 दिन के पौधों की रोपाई 25x25 सेमी की दूरी पर की जाती है। खेत को जलमग्न न रखकर केवल नम रखा जाता है और 3-4 दिन के अंतराल पर हल्की सिंचाई की जाती है। इससे 40-50% पानी की बचत होती है और पैदावार भी बढ़ती है।',
          ),
          ArticleSection(
            heading: 'लेजर लेवलिंग और बेड प्लांटिंग',
            content: 'लेजर लेवलर से खेत को समतल करने से पानी का समान वितरण होता है और 20-25% पानी की बचत होती है। उठी हुई क्यारियों (बेड) पर धान की रोपाई करने से भी पानी की बचत होती है।',
          ),
        ],
        references: [
          'भारतीय कृषि अनुसंधान परिषद',
          'अंतर्राष्ट्रीय चावल अनुसंधान संस्थान, फिलीपींस',
          'कृषि विश्वविद्यालय, पंतनगर',
        ],
        imageUrl: 'https://example.com/rice_farming.jpg',
      ),
      // Add more sample articles as needed
    ];
  }
}