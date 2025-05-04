import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/premium_article.dart';
import '../../providers/ad_provider.dart';
import '../../widgets/ad_scaffold.dart';
import '../../widgets/native_ad_widget.dart';
import 'premium_article_screen.dart';
import '../../services/content_service.dart';

class PremiumArticlesListScreen extends StatefulWidget {
  const PremiumArticlesListScreen({Key? key}) : super(key: key);

  @override
  State<PremiumArticlesListScreen> createState() => _PremiumArticlesListScreenState();
}

class _PremiumArticlesListScreenState extends State<PremiumArticlesListScreen> {
  List<PremiumArticle> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadArticles();
  }
  
  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, fetch from API
      final articles = await ContentService.getPremiumArticles(category: _selectedCategory);
      
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('लेख लोड करने में त्रुटि: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context);
    
    return AdScaffold(
      screenName: 'premium_articles_list_screen',
      appBar: AppBar(
        title: const Text('प्रीमियम कृषि सामग्री'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _articles.isEmpty 
              ? _buildEmptyState() 
              : _buildArticlesList(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'कोई लेख नहीं मिला',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'फिलहाल इस श्रेणी में कोई लेख उपलब्ध नहीं है',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('पुनः प्रयास करें'),
            onPressed: _loadArticles,
          ),
        ],
      ),
    );
  }
  
  Widget _buildArticlesList() {
    return RefreshIndicator(
      onRefresh: _loadArticles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length + (_articles.length ~/ 4), // Insert an ad after every 4 articles
        itemBuilder: (context, index) {
          // Insert a native ad after every 4 articles
          if (index > 0 && index % 5 == 4) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: NativeAdWidget(),
            );
          }
          
          // Calculate the actual article index
          final articleIndex = index - (index ~/ 5);
          final article = _articles[articleIndex];
          
          return _buildArticleCard(article);
        },
      ),
    );
  }
  
  Widget _buildArticleCard(PremiumArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToArticleDetail(article),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image if available
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'प्रीमियम',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.topic,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Author and date
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.author,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Introduction preview
                  Text(
                    article.introduction,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Read more button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _navigateToArticleDetail(article),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        child: const Text('और पढ़ें'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToArticleDetail(PremiumArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PremiumArticleScreen(article: article),
      ),
    );
  }
  
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'श्रेणी के अनुसार फ़िल्टर करें',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('all', 'सभी श्रेणियां'),
            _buildFilterOption('wheat', 'गेहूं'),
            _buildFilterOption('rice', 'चावल'),
            _buildFilterOption('cotton', 'कपास'),
            _buildFilterOption('sugarcane', 'गन्ना'),
            _buildFilterOption('vegetable', 'सब्जियां'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterOption(String value, String label) {
    final isSelected = _selectedCategory == value;
    
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (_selectedCategory != value) {
          setState(() {
            _selectedCategory = value;
          });
          _loadArticles();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}