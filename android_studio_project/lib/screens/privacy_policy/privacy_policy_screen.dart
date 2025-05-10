import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final bool isHindi = languageProvider.isHindi;

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.privacyPolicy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHindi ? 'अंतिम अपडेट: 6 मई, 2025' : 'Last Updated: May 6, 2025',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLightColor,
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSectionTitle(isHindi ? 'परिचय' : 'Introduction', context),
            _buildParagraph(
              isHindi
                  ? 'फार्मअसिस्ट एआई ("हम," "हमारा," या "हमें") आपकी गोपनीयता की सुरक्षा के लिए प्रतिबद्ध है। यह गोपनीयता नीति बताती है कि हम आपके द्वारा फार्मअसिस्ट एआई ("एप्लिकेशन") मोबाइल एप्लिकेशन का उपयोग करते समय आपकी जानकारी कैसे एकत्र, उपयोग, प्रकट और सुरक्षित करते हैं।'
                  : 'FarmAssist AI ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application FarmAssist AI (the "Application").',
              context,
            ),
            _buildParagraph(
              isHindi
                  ? 'कृपया इस गोपनीयता नीति को ध्यान से पढ़ें। यदि आप इस गोपनीयता नीति की शर्तों से सहमत नहीं हैं, तो कृपया एप्लिकेशन का उपयोग न करें।'
                  : 'Please read this Privacy Policy carefully. If you do not agree with the terms of this Privacy Policy, please do not access the Application.',
              context,
            ),
            const SizedBox(height: 16),

            // Information We Collect
            _buildSectionTitle(isHindi ? 'हम कौन सी जानकारी एकत्र करते हैं' : 'Information We Collect', context),

            // Personal Data
            _buildSubsectionTitle(isHindi ? 'व्यक्तिगत डेटा' : 'Personal Data', context),
            _buildParagraph(
              isHindi
                  ? 'हम व्यक्तिगत जानकारी एकत्र कर सकते हैं जिसे आप एप्लिकेशन के लिए पंजीकरण करते समय स्वेच्छा से प्रदान करते हैं, जिसमें शामिल हैं:'
                  : 'We may collect personal information that you voluntarily provide to us when you register for the Application, including:',
              context,
            ),
            _buildBulletList([
              isHindi ? 'नाम' : 'Name',
              isHindi ? 'ईमेल पता' : 'Email address',
              isHindi ? 'फोन नंबर' : 'Phone number',
              isHindi ? 'स्थान (जिला और राज्य)' : 'Location (district and state)',
              isHindi ? 'खेत का विवरण (जैसे फसल प्रकार, खेत का आकार, मिट्टी के प्रकार)' : 'Farm details (such as crop types, field sizes, soil types)',
            ], context),

            // Usage Data
            _buildSubsectionTitle(isHindi ? 'उपयोग डेटा' : 'Usage Data', context),
            _buildParagraph(
              isHindi
                  ? 'हम उस जानकारी को भी एकत्र कर सकते हैं जो आपका डिवाइस आपके द्वारा हमारे एप्लिकेशन का उपयोग करते समय भेजता है:'
                  : 'We may also collect information that your device sends whenever you use our Application:',
              context,
            ),
            _buildBulletList([
              'IP address',
              isHindi ? 'डिवाइस प्रकार और ऑपरेटिंग सिस्टम' : 'Device type and operating system',
              isHindi ? 'एप्लिकेशन संस्करण' : 'Application version',
              isHindi ? 'आपके उपयोग का समय और दिनांक' : 'Time and date of your use',
              isHindi ? 'विशिष्ट सुविधाओं पर बिताया गया समय' : 'Time spent on specific features',
              isHindi ? 'अन्य डायग्नोस्टिक डेटा' : 'Other diagnostic data',
            ], context),

            // Image Data
            _buildSubsectionTitle(isHindi ? 'छवि डेटा' : 'Image Data', context),
            _buildParagraph(
              isHindi
                  ? 'हम फसल रोग पहचान के लिए आपके द्वारा अपलोड की गई छवियों को एकत्र करते हैं। ये छवियां:'
                  : 'We collect images that you upload for crop disease detection. These images are:',
              context,
            ),
            _buildBulletList([
              isHindi ? 'रोग पहचान और विश्लेषण के लिए उपयोग की जाती हैं' : 'Used for disease detection and analysis',
              isHindi ? 'हमारे डेटाबेस में सुरक्षित रूप से संग्रहीत की जाती हैं' : 'Stored securely in our database',
              isHindi ? 'हमारे रोग पहचान एल्गोरिदम को बेहतर बनाने के लिए अनामित रूप में उपयोग की जा सकती हैं' : 'May be used in anonymized form to improve our disease detection algorithms',
            ], context),
            const SizedBox(height: 16),

            // How We Use Your Information
            _buildSectionTitle(isHindi ? 'हम आपकी जानकारी का उपयोग कैसे करते हैं' : 'How We Use Your Information', context),
            _buildParagraph(
              isHindi
                  ? 'हम जो जानकारी एकत्र करते हैं उसका उपयोग विभिन्न उद्देश्यों के लिए करते हैं, जिसमें शामिल हैं:'
                  : 'We use the information we collect for various purposes, including to:',
              context,
            ),
            _buildBulletList([
              isHindi ? 'हमारे एप्लिकेशन प्रदान करना और बनाए रखना' : 'Provide and maintain our Application',
              isHindi ? 'आपको हमारे एप्लिकेशन में परिवर्तनों के बारे में सूचित करना' : 'Notify you about changes to our Application',
              isHindi ? 'ग्राहक सहायता प्रदान करना' : 'Provide customer support',
              isHindi ? 'व्यक्तिगत कृषि सिफारिशें उत्पन्न करना' : 'Generate personalized farming recommendations',
              isHindi ? 'हमारे एप्लिकेशन के उपयोग की निगरानी करना' : 'Monitor the usage of our Application',
              isHindi ? 'तकनीकी समस्याओं का पता लगाना और उन्हें हल करना' : 'Detect and address technical issues',
              isHindi ? 'हमारे रोग पहचान एल्गोरिदम को बेहतर बनाना' : 'Improve our disease detection algorithms',
              isHindi ? 'आपकी सहमति से प्रचार संबंधी संचार भेजना' : 'Send you promotional communications (with your consent)',
            ], context),
            const SizedBox(height: 16),

            // Data Storage and Security
            _buildSectionTitle(isHindi ? 'डेटा स्टोरेज और सुरक्षा' : 'Data Storage and Security', context),
            _buildParagraph(
              isHindi
                  ? 'आपका डेटा भारत के सुरक्षित सर्वरों पर संग्रहित किया जाता है। हम अनधिकृत या अवैध प्रसंस्करण, आकस्मिक हानि, विनाश या क्षति के खिलाफ आपके व्यक्तिगत डेटा की सुरक्षा के लिए उपयुक्त तकनीकी और संगठनात्मक उपाय लागू करते हैं।'
                  : 'Your data is stored on secure servers in India. We implement appropriate technical and organizational measures to protect your personal data against unauthorized or unlawful processing, accidental loss, destruction, or damage.',
              context,
            ),
            const SizedBox(height: 16),

            // Data Sharing and Disclosure
            _buildSectionTitle(isHindi ? 'डेटा शेयरिंग और प्रकटीकरण' : 'Data Sharing and Disclosure', context),
            _buildParagraph(
              isHindi
                  ? 'हम आपकी जानकारी निम्नलिखित के साथ साझा कर सकते हैं:'
                  : 'We may share your information with:',
              context,
            ),
            _buildBulletList([
              isHindi ? 'सेवा प्रदाता: तृतीय-पक्ष विक्रेता जो हमारी ओर से सेवाएं प्रदान करते हैं (जैसे मौसम डेटा प्रदाता, बाजार मूल्य डेटा प्रदाता)' : 'Service Providers: Third-party vendors who provide services on our behalf (such as weather data providers, market price data providers)',
              isHindi ? 'व्यावसायिक भागीदार: कृषि सेवाएं या उत्पाद प्रदाता जो प्रासंगिक सेवाएं प्रदान कर सकते हैं' : 'Business Partners: Agricultural services or product providers that may offer relevant services',
              isHindi ? 'कानूनी आवश्यकताएं: जब कानून द्वारा आवश्यक हो या हमारे अधिकारों की रक्षा के लिए' : 'Legal Requirements: When required by law or to protect our rights',
            ], context),
            _buildParagraph(
              isHindi
                  ? 'हम आपके व्यक्तिगत डेटा को तीसरे पक्ष को नहीं बेचते हैं।'
                  : 'We do NOT sell your personal data to third parties.',
              context,
            ),
            const SizedBox(height: 16),

            // Your Data Rights
            _buildSectionTitle(isHindi ? 'आपके डेटा अधिकार' : 'Your Data Rights', context),
            _buildParagraph(
              isHindi
                  ? 'आपको निम्न अधिकार हैं:'
                  : 'You have the right to:',
              context,
            ),
            _buildBulletList([
              isHindi ? 'हमारे पास आपके बारे में जो व्यक्तिगत डेटा है उसे एक्सेस करना' : 'Access the personal data we have about you',
              isHindi ? 'अपने व्यक्तिगत डेटा में अशुद्धियों को सही करना' : 'Correct inaccuracies in your personal data',
              isHindi ? 'अपना व्यक्तिगत डेटा हटाना' : 'Delete your personal data',
              isHindi ? 'डेटा प्रसंस्करण के लिए सहमति वापस लेना' : 'Withdraw consent for data processing',
              isHindi ? 'मार्केटिंग संचार से ऑप्ट-आउट करना' : 'Opt-out of marketing communications',
            ], context),
            _buildParagraph(
              isHindi
                  ? 'इन अधिकारों का प्रयोग करने के लिए, कृपया हमसे संपर्क करें: privacy@farmassistai.com'
                  : 'To exercise these rights, please contact us at privacy@farmassistai.com',
              context,
            ),
            const SizedBox(height: 16),

            // Children's Privacy
            _buildSectionTitle(isHindi ? 'बच्चों की गोपनीयता' : 'Children\'s Privacy', context),
            _buildParagraph(
              isHindi
                  ? 'हमारा एप्लिकेशन 13 वर्ष से कम उम्र के बच्चों के लिए नहीं है। हम जानबूझकर 13 वर्ष से कम उम्र के बच्चों से व्यक्तिगत जानकारी एकत्र नहीं करते हैं।'
                  : 'Our Application is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
              context,
            ),
            const SizedBox(height: 16),

            // Changes to This Privacy Policy
            _buildSectionTitle(isHindi ? 'इस गोपनीयता नीति में परिवर्तन' : 'Changes to This Privacy Policy', context),
            _buildParagraph(
              isHindi
                  ? 'हम समय-समय पर अपनी गोपनीयता नीति को अपडेट कर सकते हैं। हम आपको इस पृष्ठ पर नई गोपनीयता नीति पोस्ट करके और "अंतिम अपडेट" तिथि को अपडेट करके किसी भी परिवर्तन के बारे में सूचित करेंगे।'
                  : 'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date.',
              context,
            ),
            const SizedBox(height: 16),

            // Contact Us
            _buildSectionTitle(isHindi ? 'हमसे संपर्क करें' : 'Contact Us', context),
            _buildParagraph(
              isHindi
                  ? 'यदि आपके इस गोपनीयता नीति के बारे में कोई प्रश्न हैं, तो कृपया हमसे संपर्क करें:'
                  : 'If you have questions about this Privacy Policy, please contact us at:',
              context,
            ),
            _buildBulletList([
              isHindi ? 'ईमेल: privacy@farmassistai.com' : 'Email: privacy@farmassistai.com',
              isHindi ? 'पता: फार्मअसिस्ट एआई, 123 एग्रीकल्चर रोड, नई दिल्ली, 110001, भारत' : 'Address: FarmAssist AI, 123 Agriculture Road, New Delhi, 110001, India',
            ], context),
            const SizedBox(height: 32),

            // Version
            Center(
              child: Text(
                isHindi ? 'गोपनीयता नीति संस्करण: 1.0' : 'Privacy Policy Version: 1.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLightColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '© 2025 FarmAssist AI',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLightColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 14)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}