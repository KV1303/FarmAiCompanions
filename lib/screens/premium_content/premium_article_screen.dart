import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/premium_article.dart';
import '../../providers/ad_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_content_dialog.dart';
import '../../widgets/ad_scaffold.dart';
import '../../utils/common_utils.dart';

class PremiumArticleScreen extends StatefulWidget {
  final PremiumArticle article;
  
  const PremiumArticleScreen({
    Key? key,
    required this.article,
  }) : super(key: key);
  
  @override
  State<PremiumArticleScreen> createState() => _PremiumArticleScreenState();
}

class _PremiumArticleScreenState extends State<PremiumArticleScreen> {
  bool _contentUnlocked = false;
  
  @override
  void initState() {
    super.initState();
    _checkIfContentUnlocked();
  }
  
  void _checkIfContentUnlocked() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    // Content is automatically unlocked for premium users
    if (adProvider.isPremium) {
      setState(() {
        _contentUnlocked = true;
      });
    }
  }
  
  void _unlockContent() {
    setState(() {
      _contentUnlocked = true;
    });
    
    // Save this article as unlocked in local storage for this user
    CommonUtils.saveUnlockedArticle(widget.article.id);
  }
  
  void _showUnlockOptions() {
    PremiumContentDialog.show(
      context: context,
      title: 'प्रीमियम ${widget.article.topic} आलेख',
      description: 'इस विशेषज्ञ द्वारा तैयार किए गए मूल्यवान कृषि आलेख को अनलॉक करें जो आपकी फसल की उपज बढ़ाने में मदद करेगा।',
      icon: Icon(
        Icons.article_rounded,
        color: Theme.of(context).primaryColor,
        size: 60,
      ),
      onWatchAd: _unlockContent,
      onSubscribe: () {
        Navigator.pushNamed(context, '/subscription');
      },
      watchAdButtonText: 'विज्ञापन देखें और आलेख अनलॉक करें',
      subscribeButtonText: 'सदस्यता लें और सभी सामग्री अनलॉक करें',
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AdScaffold(
      screenName: 'premium_article_screen',
      appBar: AppBar(
        title: Text(widget.article.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Save article to bookmarks
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('आलेख बुकमार्क में सहेजा गया'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share article
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('शेयरिंग विकल्प दिखाएँ'),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article header
            Text(
              widget.article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Author and date
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.article.author,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.article.date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Featured image
            if (widget.article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.article.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 24),
            
            // Introduction
            Text(
              widget.article.introduction,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            
            // Content preview or full content
            if (_contentUnlocked) 
              ..._buildFullContent()
            else
              _buildLockedContent(),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildFullContent() {
    return [
      // Main content sections
      ...widget.article.sections.map((section) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            section.heading,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.content,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],
      )).toList(),
      
      const SizedBox(height: 24),
      
      // Conclusion
      const Text(
        'निष्कर्ष',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        widget.article.conclusion,
        style: const TextStyle(fontSize: 16),
      ),
      
      const SizedBox(height: 32),
      
      // References
      if (widget.article.references.isNotEmpty) ...[
        const Text(
          'संदर्भ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.article.references.map((reference) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '• $reference',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        )).toList(),
      ],
    ];
  }
  
  Widget _buildLockedContent() {
    return Column(
      children: [
        // Blurred preview text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'यह सामग्री प्रीमियम सदस्यों के लिए उपलब्ध है या विज्ञापन देखकर अनलॉक की जा सकती है...',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 32),
        
        // Unlock options
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.lock,
                  size: 48,
                  color: AppColors.accentColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'प्रीमियम सामग्री',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'इस मूल्यवान जानकारी को अनलॉक करने के लिए एक छोटा विज्ञापन देखें या प्रीमियम सदस्य बनें।',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('विज्ञापन देखें और अनलॉक करें'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _showUnlockOptions,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('प्रीमियम सदस्य बनें'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/subscription');
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}