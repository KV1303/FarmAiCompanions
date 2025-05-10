import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ad_provider.dart';

class ConsentDialog extends StatelessWidget {
  const ConsentDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'विज्ञापन और गोपनीयता सहमति',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            const Text(
              'FarmAssist AI आपको बिना किसी शुल्क के महत्वपूर्ण खेती से संबंधित जानकारी उपलब्ध कराती है। इसे संभव बनाने के लिए, हम आपको प्रासंगिक विज्ञापन दिखाते हैं।\n\nहम निम्नलिखित के लिए आपकी सहमति मांगते हैं:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Bullet points
            _buildBulletPoint(context, 'व्यक्तिगत विज्ञापन दिखाएँ'),
            _buildBulletPoint(context, 'आपकी ऐप इंटरैक्शन जानकारी एकत्र करें'),
            _buildBulletPoint(context, 'एप्लिकेशन उपयोग डेटा सहेजें'),
            
            const SizedBox(height: 24),
            
            // Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () => _accept(context),
                  child: const Text('सहमत हूँ'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _decline(context),
                  child: const Text('अस्वीकार करें'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _showPrivacyPolicy(context),
                  child: const Text(
                    'गोपनीयता नीति देखें',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _accept(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.setConsentRequested(true);
    Navigator.of(context).pop(true);
  }

  void _decline(BuildContext context) {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.setConsentRequested(true);
    Navigator.of(context).pop(false);
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Show privacy policy dialog or navigate to privacy policy page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('गोपनीयता नीति'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FarmAssist AI गोपनीयता नीति',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'हम आपकी गोपनीयता का सम्मान करते हैं और आपकी व्यक्तिगत जानकारी की सुरक्षा के लिए प्रतिबद्ध हैं। यह गोपनीयता नीति बताती है कि हम आपकी जानकारी को कैसे एकत्र, उपयोग और साझा करते हैं।\n\n'
                'हम निम्न जानकारी एकत्र करते हैं:\n'
                '• आपकी प्रोफ़ाइल जानकारी\n'
                '• आपके खेत और फसलों का विवरण\n'
                '• ऐप उपयोग डेटा\n'
                '• डिवाइस जानकारी\n\n'
                'हम इस जानकारी का उपयोग निम्नलिखित के लिए करते हैं:\n'
                '• आपको बेहतर कृषि सुझाव प्रदान करने के लिए\n'
                '• ऐप अनुभव को अनुकूलित करने के लिए\n'
                '• प्रासंगिक विज्ञापन दिखाने के लिए\n'
                '• सेवा में सुधार के लिए\n\n'
                'हम आपकी जानकारी तृतीय पक्षों के साथ तभी साझा करते हैं जब ऐसा करना आवश्यक हो या आप सहमति दें।',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('बंद करें'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ConsentDialog(),
    );
  }
}