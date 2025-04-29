// Comprehensive translation script for the entire application
console.log("Direct translate script loaded");

// Current language selected (default: English)
let currentLanguage = "en";

document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM content loaded - setting up language switcher");
  
  // Load previously selected language from localStorage if available
  const savedLanguage = localStorage.getItem('selectedLanguage');
  if (savedLanguage) {
    currentLanguage = savedLanguage;
    console.log("Loading saved language: " + currentLanguage);
    setTimeout(() => applyTranslations(currentLanguage), 500);
  }
  
  // Global translations for all UI elements
  const translations = {
    hi: {
      "home": "होम",
      "dashboard": "डैशबोर्ड",
      "disease_detection": "रोग पहचान",
      "market_prices": "बाजार भाव",
      "weather": "मौसम",
      "login": "लॉगिन",
      "register": "रजिस्टर",
      "logout": "लॉगआउट",
      "revolutionize_farming": "अपनी खेती में क्रांति लाएँ",
      "ai_companion": "आधुनिक किसानों के लिए AI-संचालित सहायक",
      "get_started": "शुरू करें",
      "ai_farm_guidance": "AI कृषि मार्गदर्शन प्रणाली",
      "personalized_recommendations": "अपनी फसल के अनुसार व्यक्तिगत सिफारिशें प्राप्त करें",
      "guidance_description": "हमारी AI-संचालित कृषि मार्गदर्शन प्रणाली आपकी विशिष्ट फसलों, मिट्टी के प्रकार और स्थान के अनुसार व्यापक सिफारिशें प्रदान करती है।",
      "crop_type": "फसल का प्रकार",
      "soil_type": "मिट्टी का प्रकार",
      "get_farm_guidance": "कृषि मार्गदर्शन प्राप्त करें",
      "select_crop": "फसल चुनें",
      "select_soil": "मिट्टी का प्रकार चुनें",
      "what_farmassist_can_do": "फार्मअसिस्ट AI आपके लिए क्या कर सकता है",
      "disease_detection_feature": "रोग पहचान",
      "disease_detection_desc": "केवल एक फोटो लेकर फसल के रोगों का पता लगाएं। हमारा AI तुरंत निदान और उपचार की सिफारिशें प्रदान करता है।",
      "try_now": "अभी आज़माएँ",
      "market_prices_feature": "बाजार भाव",
      "market_prices_desc": "अपनी फसलों के लिए रीयल-टाइम बाजार मूल्य प्राप्त करें और अपने मुनाफे को अधिकतम करने के लिए मूल्य परिवर्तनों के लिए अलर्ट सेट करें।",
      "check_prices": "भाव देखें",
      "weather_forecasts_feature": "मौसम पूर्वानुमान",
      "weather_forecasts_desc": "अपनी कृषि गतिविधियों की प्रभावी योजना बनाने के लिए अपने विशिष्ट स्थान के लिए सटीक मौसम पूर्वानुमान प्राप्त करें।",
      "view_weather": "मौसम देखें",
      "fertilizer_feature": "उन्नत उर्वरक सिफारिशें",
      "fertilizer_desc": "अपनी फसल के प्रकार, मिट्टी की स्थिति और विकास के चरण के आधार पर AI-संचालित उर्वरक सिफारिशें प्राप्त करें। सटीक पोषक तत्व प्रबंधन के साथ उपज को अधिकतम करें।",
      "get_recommendations": "सिफारिशें प्राप्त करें",
      "irrigation_feature": "सिंचाई प्रबंधन",
      "irrigation_desc": "अपनी फसलों, मिट्टी के प्रकार और स्थानीय मौसम की स्थिति के अनुसार AI-जनित सिंचाई कार्यक्रम के साथ अपने पानी के उपयोग को अनुकूलित करें। पानी बचाएं और फसल स्वास्थ्य में सुधार करें।",
      "plan_irrigation": "सिंचाई की योजना बनाएं",
      
      // Form elements
      "username": "यूजरनेम",
      "password": "पासवर्ड",
      "email": "ईमेल",
      "confirm_password": "पासवर्ड की पुष्टि करें",
      "no_account": "खाता नहीं है?",
      "register_now": "अभी रजिस्टर करें",
      "have_account": "पहले से ही खाता है?",
      
      // Testimonials
      "what_farmers_say": "किसान क्या कहते हैं",
      "testimonial_1": "\"फार्मअसिस्ट AI ने मुझे जल्दी से फंगल संक्रमण की पहचान करने में मदद की, जिससे मेरी पूरी टमाटर फसल बच गई। सिफारिशें बिल्कुल सही थीं!\"",
      "farmer_1": "- राजेश कुमार, टमाटर किसान",
      "testimonial_2": "\"मैंने बाजार मूल्य अलर्ट का उपयोग करके अपनी फसल बिक्री के समय को अनुकूलित कर अपने मुनाफे में 20% की वृद्धि की है। यह ऐप गेम-चेंजर है!\"",
      "farmer_2": "- अनन्या सिंह, चावल किसान",
      "testimonial_3": "\"मौसम पूर्वानुमान अविश्वसनीय रूप से सटीक हैं। मैं अनिश्चित मौसम के दौरान भी आत्मविश्वास के साथ सिंचाई और फसल कटाई की योजना बना सकता हूँ।\"",
      "farmer_3": "- विक्रम पटेल, गेहूँ किसान",
      
      // Disease Detection
      "crop_disease_detection": "फसल रोग पहचान",
      "upload_photo": "अपनी फसल की फोटो अपलोड करें",
      "take_clear_photo": "प्रभावित पौधे के हिस्से (पत्ती, तना, फल) की एक स्पष्ट फोटो लें और नीचे अपलोड करें।",
      "drag_drop": "खींचें और छोड़ें या अपलोड करने के लिए क्लिक करें",
      "supported_formats": "समर्थित प्रारूप: JPG, PNG",
      "reset": "रीसेट",
      "analyze_image": "छवि का विश्लेषण करें",
      "analyzing_image": "छवि का विश्लेषण किया जा रहा है... इसमें कुछ समय लग सकता है।",
      "confidence": "विश्वास:",
      "symptoms": "लक्षण:",
      "recommended_treatment": "अनुशंसित उपचार:",
      "save_report": "रिपोर्ट सहेजें",
      
      // Market Prices
      "market_prices_title": "बाजार भाव",
      "all_crops": "सभी फसलें",
      "apply": "लागू करें",
      "crop": "फसल",
      "market": "बाजार",
      "price": "मूल्य (₹/क्विंटल)",
      "min_price": "न्यूनतम मूल्य",
      "max_price": "अधिकतम मूल्य",
      "date": "दिनांक",
      "action": "कार्रवाई",
      "price_alerts": "मूल्य अलर्ट",
      "set_up_alerts": "मूल्य आपके लक्ष्य स्तर तक पहुंचने पर सूचित किए जाने के लिए अलर्ट सेट करें।",
      
      // Dashboard
      "farmer_dashboard": "किसान डैशबोर्ड",
      "fields": "खेत",
      "crops": "फसलें",
      "alerts": "अलर्ट",
      "health_index": "स्वास्थ्य सूचकांक",
      "your_fields": "आपके खेत",
      "no_fields": "अभी तक कोई खेत नहीं जोड़ा गया",
      "add_field": "नया खेत जोड़ें",
      "field_details": "खेत का विवरण",
      "select_field": "विवरण देखने के लिए एक खेत चुनें"
    },
    ta: {
      "home": "முகப்பு",
      "dashboard": "டாஷ்போர்டு",
      "disease_detection": "நோய் கண்டறிதல்",
      "market_prices": "சந்தை விலைகள்",
      "weather": "வானிலை",
      "login": "உள்நுழைக",
      "register": "பதிவு செய்க",
      "logout": "வெளியேறு",
      "revolutionize_farming": "உங்கள் விவசாயத்தில் புரட்சி செய்யுங்கள்",
      "ai_companion": "நவீன விவசாயிகளுக்கான AI-செயலாக்கப்பட்ட துணை",
      "get_started": "தொடங்குங்கள்",
      "ai_farm_guidance": "AI விவசாய வழிகாட்டும் அமைப்பு",
      "personalized_recommendations": "உங்கள் சொந்த பயிர்களுக்கான தனிப்பயனாக்கப்பட்ட பரிந்துரைகளைப் பெறுங்கள்",
      "guidance_description": "எங்களின் AI-செயலாக்கப்பட்ட விவசாய வழிகாட்டுதல் அமைப்பு உங்கள் குறிப்பிட்ட பயிர்கள், மண் வகை மற்றும் இருப்பிடத்திற்கு ஏற்ப விரிவான பரிந்துரைகளை வழங்குகிறது.",
      "crop_type": "பயிர் வகை",
      "soil_type": "மண் வகை",
      "get_farm_guidance": "விவசாய வழிகாட்டுதல் பெறுக",
      "select_crop": "பயிரைத் தேர்ந்தெடுக்கவும்",
      "select_soil": "மண் வகையைத் தேர்ந்தெடுக்கவும்",
      "what_farmassist_can_do": "FarmAssist AI உங்களுக்கு என்ன செய்ய முடியும்",
      "disease_detection_feature": "நோய் கண்டறிதல்",
      "disease_detection_desc": "ஒரு புகைப்படத்தை எடுப்பதன் மூலம் பயிர் நோய்களைக் கண்டறியுங்கள். எங்கள் AI உடனடி நோயறிதல் மற்றும் சிகிச்சை பரிந்துரைகளை வழங்குகிறது.",
      "try_now": "இப்போது முயற்சிக்கவும்",
      "market_prices_feature": "சந்தை விலைகள்",
      "market_prices_desc": "உங்கள் பயிர்களுக்கான நிகழ்நேர சந்தை விலைகளைப் பெறுங்கள் மற்றும் உங்கள் லாபத்தை அதிகரிக்க விலை மாற்றங்களுக்கான விழிப்பூட்டல்களை அமைக்கவும்.",
      "check_prices": "விலைகளைப் பார்க்கவும்",
      "weather_forecasts_feature": "வானிலை முன்னறிவிப்புகள்",
      "weather_forecasts_desc": "உங்கள் விவசாய செயல்பாடுகளை திறம்பட திட்டமிட உங்கள் குறிப்பிட்ட இருப்பிடத்திற்கான துல்லியமான வானிலை முன்னறிவிப்புகளைப் பெறுங்கள்.",
      "view_weather": "வானிலை காண",
      "fertilizer_feature": "மேம்பட்ட உர பரிந்துரைகள்",
      "fertilizer_desc": "உங்கள் பயிர் வகை, மண் நிலைமைகள் மற்றும் வளர்ச்சி நிலைகளின் அடிப்படையில் AI-செயலாக்கப்பட்ட உர பரிந்துரைகளைப் பெறுங்கள். துல்லியமான ஊட்டச்சத்து மேலாண்மையுடன் விளைச்சலை அதிகரிக்கவும்.",
      "get_recommendations": "பரிந்துரைகளைப் பெறுக",
      "irrigation_feature": "நீர்ப்பாசன மேலாண்மை",
      "irrigation_desc": "உங்கள் பயிர்கள், மண் வகை மற்றும் உள்ளூர் வானிலை நிலைகளுக்கு ஏற்ப AI-உருவாக்கப்பட்ட நீர்ப்பாசன அட்டவணைகளுடன் உங்கள் நீர் பயன்பாட்டை உகந்ததாக்குங்கள். நீரைச் சேமித்து பயிர் ஆரோக்கியத்தை மேம்படுத்துங்கள்.",
      "plan_irrigation": "நீர்ப்பாசனத் திட்டம்"
    },
    te: {
      "home": "హోమ్",
      "dashboard": "డాష్‌బోర్డ్",
      "disease_detection": "రోగ నిర్ధారణ",
      "market_prices": "మార్కెట్ ధరలు",
      "weather": "వాతావరణం",
      "login": "లాగిన్",
      "register": "రిజిస్టర్",
      "logout": "లాగౌట్",
      "revolutionize_farming": "మీ వ్యవసాయాన్ని విప్లవాత్మకంగా మార్చండి",
      "ai_companion": "ఆధునిక రైతులకు AI-ఆధారిత సహాయకుడు",
      "get_started": "ప్రారంభించండి",
      "ai_farm_guidance": "AI వ్యవసాయ మార్గదర్శక వ్యవస్థ",
      "personalized_recommendations": "మీ పంటలకు అనుగుణంగా వ్యక్తిగత సిఫార్సులను పొందండి",
      "guidance_description": "మా AI-ఆధారిత వ్యవసాయ మార్గదర్శక వ్యవస్థ మీ ప్రత్యేక పంటలు, నేల రకం మరియు ప్రాంతానికి అనుగుణంగా సమగ్ర సిఫార్సులను అందిస్తుంది.",
      "crop_type": "పంట రకం",
      "soil_type": "నేల రకం",
      "get_farm_guidance": "వ్యవసాయ మార్గదర్శకతను పొందండి",
      "select_crop": "పంటను ఎంచుకోండి",
      "select_soil": "నేల రకాన్ని ఎంచుకోండి",
      "what_farmassist_can_do": "FarmAssist AI మీకు ఏమి చేయగలదు",
      "disease_detection_feature": "రోగ నిర్ధారణ",
      "disease_detection_desc": "కేవలం ఒక ఫోటో తీయడం ద్వారా పంట వ్యాధులను గుర్తించండి. మా AI వెంటనే రోగనిర్ధారణ మరియు చికిత్స సిఫార్సులను అందిస్తుంది.",
      "try_now": "ఇప్పుడే ప్రయత్నించండి",
      "market_prices_feature": "మార్కెట్ ధరలు",
      "market_prices_desc": "మీ పంటల కోసం రియల్-టైమ్ మార్కెట్ ధరలను పొందండి మరియు మీ లాభాలను గరిష్టీకరించడానికి ధర మార్పుల కోసం అలర్ట్‌లను సెట్ చేయండి.",
      "check_prices": "ధరలను తనిఖీ చేయండి",
      "weather_forecasts_feature": "వాతావరణ సూచనలు",
      "weather_forecasts_desc": "మీ వ్యవసాయ కార్యకలాపాలను ప్రభావవంతంగా ప్రణాళిక చేయడానికి మీ నిర్దిష్ట ప్రాంతానికి ఖచ్చితమైన వాతావరణ సూచనలను పొందండి.",
      "view_weather": "వాతావరణాన్ని వీక్షించండి",
      "fertilizer_feature": "అధునాతన ఎరువుల సిఫార్సులు",
      "fertilizer_desc": "మీ పంట రకం, నేల పరిస్థితులు మరియు వృద్ధి దశ ఆధారంగా AI-ఆధారిత ఎరువుల సిఫార్సులను పొందండి. ఖచ్చితమైన పోషక నిర్వహణతో దిగుబడిని గరిష్టీకరించండి.",
      "get_recommendations": "సిఫార్సులను పొందండి",
      "irrigation_feature": "నీటిపారుదల నిర్వహణ",
      "irrigation_desc": "మీ పంటలు, నేల రకం మరియు స్థానిక వాతావరణ పరిస్థితులకు అనుగుణంగా AI-రూపొందించిన నీటిపారుదల షెడ్యూల్‌లతో మీ నీటి వినియోగాన్ని అనుకూలీకరించండి. నీటిని ఆదా చేసి పంట ఆరోగ్యాన్ని మెరుగుపరచండి.",
      "plan_irrigation": "నీటిపారుదల ప్రణాళిక"
    },
    bn: {
      "home": "হোম",
      "dashboard": "ড্যাশবোর্ড",
      "disease_detection": "রোগ সনাক্তকরণ",
      "market_prices": "বাজার দর",
      "weather": "আবহাওয়া",
      "login": "লগইন",
      "register": "নিবন্ধন",
      "logout": "লগআউট",
      "revolutionize_farming": "আপনার কৃষিকে বিপ্লব করুন",
      "ai_companion": "আধুনিক কৃষকদের জন্য AI-চালিত সহায়ক",
      "get_started": "শুরু করুন",
      "ai_farm_guidance": "AI কৃষি গাইডেন্স সিস্টেম",
      "personalized_recommendations": "আপনার ফসলের জন্য ব্যক্তিগতকৃত সুপারিশ পান",
      "guidance_description": "আমাদের AI-চালিত কৃষি গাইডেন্স সিস্টেম আপনার নির্দিষ্ট ফসল, মাটির ধরন এবং অবস্থান অনুযায়ী বিস্তৃত সুপারিশ প্রদান করে।",
      "crop_type": "ফসলের ধরন",
      "soil_type": "মাটির ধরন",
      "get_farm_guidance": "কৃষি গাইডেন্স পান",
      "select_crop": "একটি ফসল নির্বাচন করুন",
      "select_soil": "মাটির ধরন নির্বাচন করুন",
      "what_farmassist_can_do": "FarmAssist AI আপনার জন্য কী করতে পারে",
      "disease_detection_feature": "রোগ সনাক্তকরণ",
      "disease_detection_desc": "শুধুমাত্র একটি ফটো তুলে ফসলের রোগ সনাক্ত করুন। আমাদের AI তাত্ক্ষণিক রোগ নির্ণয় এবং চিকিৎসার সুপারিশ প্রদান করে।",
      "try_now": "এখনই চেষ্টা করুন",
      "market_prices_feature": "বাজার দর",
      "market_prices_desc": "আপনার ফসলের জন্য রিয়েল-টাইম বাজার দর পান এবং আপনার মুনাফা সর্বাধিক করতে মূল্য পরিবর্তনের জন্য সতর্কতা সেট করুন।",
      "check_prices": "দাম দেখুন",
      "weather_forecasts_feature": "আবহাওয়া পূর্বাভাস",
      "weather_forecasts_desc": "আপনার কৃষি কার্যক্রম কার্যকরভাবে পরিকল্পনা করতে আপনার নির্দিষ্ট অবস্থানের জন্য সঠিক আবহাওয়া পূর্বাভাস পান।",
      "view_weather": "আবহাওয়া দেখুন",
      "fertilizer_feature": "উন্নত সার সুপারিশ",
      "fertilizer_desc": "আপনার ফসলের ধরন, মাটির অবস্থা এবং বৃদ্ধির পর্যায়ের উপর ভিত্তি করে AI-চালিত সার সুপারিশ পান। সঠিক পুষ্টি ব্যবস্থাপনার মাধ্যমে ফলন সর্বাধিক করুন।",
      "get_recommendations": "সুপারিশ পান",
      "irrigation_feature": "সেচ ব্যবস্থাপনা",
      "irrigation_desc": "আপনার ফসল, মাটির ধরন এবং স্থানীয় আবহাওয়া পরিস্থিতি অনুযায়ী AI-তৈরি সেচ সূচি দিয়ে আপনার পানি ব্যবহার অপ্টিমাইজ করুন। পানি সংরক্ষণ এবং ফসলের স্বাস্থ্য উন্নত করুন।",
      "plan_irrigation": "সেচ পরিকল্পনা"
    },
    pa: {
      "home": "ਹੋਮ",
      "dashboard": "ਡੈਸ਼ਬੋਰਡ",
      "disease_detection": "ਰੋਗ ਦੀ ਪਛਾਣ",
      "market_prices": "ਮਾਰਕੀਟ ਦੀਆਂ ਕੀਮਤਾਂ",
      "weather": "ਮੌਸਮ",
      "login": "ਲੌਗਇਨ",
      "register": "ਰਜਿਸਟਰ",
      "logout": "ਲੌਗਆਊਟ",
      "revolutionize_farming": "ਆਪਣੀ ਖੇਤੀ ਵਿੱਚ ਕ੍ਰਾਂਤੀ ਲਿਆਓ",
      "ai_companion": "ਆਧੁਨਿਕ ਕਿਸਾਨਾਂ ਲਈ AI-ਸੰਚਾਲਿਤ ਸਾਥੀ",
      "get_started": "ਸ਼ੁਰੂ ਕਰੋ",
      "ai_farm_guidance": "AI ਫਾਰਮ ਗਾਈਡੈਂਸ ਸਿਸਟਮ",
      "personalized_recommendations": "ਆਪਣੀਆਂ ਫਸਲਾਂ ਲਈ ਵਿਅਕਤੀਗਤ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਾਪਤ ਕਰੋ",
      "guidance_description": "ਸਾਡਾ AI-ਸੰਚਾਲਿਤ ਖੇਤੀ ਮਾਰਗਦਰਸ਼ਨ ਸਿਸਟਮ ਤੁਹਾਡੀਆਂ ਖਾਸ ਫਸਲਾਂ, ਮਿੱਟੀ ਦੀ ਕਿਸਮ ਅਤੇ ਸਥਾਨ ਦੇ ਅਨੁਸਾਰ ਵਿਆਪਕ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਦਾਨ ਕਰਦਾ ਹੈ।",
      "crop_type": "ਫਸਲ ਦੀ ਕਿਸਮ",
      "soil_type": "ਮਿੱਟੀ ਦੀ ਕਿਸਮ",
      "get_farm_guidance": "ਖੇਤੀ ਮਾਰਗਦਰਸ਼ਨ ਪ੍ਰਾਪਤ ਕਰੋ",
      "select_crop": "ਫਸਲ ਚੁਣੋ",
      "select_soil": "ਮਿੱਟੀ ਦੀ ਕਿਸਮ ਚੁਣੋ",
      "what_farmassist_can_do": "FarmAssist AI ਤੁਹਾਡੇ ਲਈ ਕੀ ਕਰ ਸਕਦਾ ਹੈ",
      "disease_detection_feature": "ਰੋਗ ਦੀ ਪਛਾਣ",
      "disease_detection_desc": "ਸਿਰਫ਼ ਇੱਕ ਫੋਟੋ ਲੈ ਕੇ ਫਸਲ ਦੇ ਰੋਗਾਂ ਦਾ ਪਤਾ ਲਗਾਓ। ਸਾਡਾ AI ਤੁਰੰਤ ਨਿਦਾਨ ਅਤੇ ਇਲਾਜ ਦੀਆਂ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਦਾਨ ਕਰਦਾ ਹੈ।",
      "try_now": "ਹੁਣੇ ਅਜ਼ਮਾਓ",
      "market_prices_feature": "ਮਾਰਕੀਟ ਦੀਆਂ ਕੀਮਤਾਂ",
      "market_prices_desc": "ਆਪਣੀਆਂ ਫਸਲਾਂ ਲਈ ਰੀਅਲ-ਟਾਈਮ ਮਾਰਕੀਟ ਦੀਆਂ ਕੀਮਤਾਂ ਪ੍ਰਾਪਤ ਕਰੋ ਅਤੇ ਆਪਣੇ ਮੁਨਾਫੇ ਨੂੰ ਵੱਧ ਤੋਂ ਵੱਧ ਕਰਨ ਲਈ ਕੀਮਤ ਬਦਲਾਵਾਂ ਲਈ ਅਲਰਟ ਸੈੱਟ ਕਰੋ।",
      "check_prices": "ਕੀਮਤਾਂ ਦੀ ਜਾਂਚ ਕਰੋ",
      "weather_forecasts_feature": "ਮੌਸਮ ਦੀ ਭਵਿੱਖਬਾਣੀ",
      "weather_forecasts_desc": "ਆਪਣੀਆਂ ਖੇਤੀ ਗਤੀਵਿਧੀਆਂ ਦੀ ਪ੍ਰਭਾਵਸ਼ਾਲੀ ਢੰਗ ਨਾਲ ਯੋਜਨਾ ਬਣਾਉਣ ਲਈ ਆਪਣੇ ਖਾਸ ਸਥਾਨ ਲਈ ਸਹੀ ਮੌਸਮ ਭਵਿੱਖਬਾਣੀ ਪ੍ਰਾਪਤ ਕਰੋ।",
      "view_weather": "ਮੌਸਮ ਦੇਖੋ",
      "fertilizer_feature": "ਉੱਨਤ ਖਾਦ ਸਿਫਾਰਸ਼ਾਂ",
      "fertilizer_desc": "ਆਪਣੀ ਫਸਲ ਦੀ ਕਿਸਮ, ਮਿੱਟੀ ਦੀਆਂ ਸਥਿਤੀਆਂ ਅਤੇ ਵਿਕਾਸ ਪੜਾਅ ਦੇ ਆਧਾਰ ਤੇ AI-ਸੰਚਾਲਿਤ ਖਾਦ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਾਪਤ ਕਰੋ। ਸਟੀਕ ਪੋਸ਼ਕ ਪ੍ਰਬੰਧਨ ਨਾਲ ਉਪਜ ਨੂੰ ਵੱਧ ਤੋਂ ਵੱਧ ਕਰੋ।",
      "get_recommendations": "ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਾਪਤ ਕਰੋ",
      "irrigation_feature": "ਸਿੰਚਾਈ ਪ੍ਰਬੰਧਨ",
      "irrigation_desc": "ਆਪਣੀਆਂ ਫਸਲਾਂ, ਮਿੱਟੀ ਦੀ ਕਿਸਮ ਅਤੇ ਸਥਾਨਕ ਮੌਸਮ ਦੀਆਂ ਸਥਿਤੀਆਂ ਦੇ ਅਨੁਕੂਲ AI-ਤਿਆਰ ਕੀਤੇ ਸਿੰਚਾਈ ਸ਼ੈਡਿਊਲਾਂ ਨਾਲ ਆਪਣੇ ਪਾਣੀ ਦੀ ਵਰਤੋਂ ਨੂੰ ਅਨੁਕੂਲ ਬਣਾਓ। ਪਾਣੀ ਬਚਾਓ ਅਤੇ ਫਸਲ ਦੀ ਸਿਹਤ ਵਿੱਚ ਸੁਧਾਰ ਕਰੋ।",
      "plan_irrigation": "ਸਿੰਚਾਈ ਦੀ ਯੋਜਨਾ ਬਣਾਓ"
    }
  };
  
  // Translation table for crop types - will be used for dropdown options
  const cropTranslations = {
    hi: {
      "Rice": "चावल",
      "Wheat": "गेहूँ",
      "Maize": "मक्का",
      "Cotton": "कपास",
      "Sugarcane": "गन्ना",
      "Potato": "आलू",
      "Tomato": "टमाटर",
      "Onion": "प्याज",
      "Chilli": "मिर्च",
      "Soybean": "सोयाबीन",
      "Chickpea": "चना",
      "Groundnut": "मूंगफली",
      "Mustard": "सरसों",
      "Turmeric": "हल्दी",
      "Garlic": "लहसुन",
      "Okra": "भिंडी",
      "Millet": "बाजरा",
      "Barley": "जौ",
      "Sunflower": "सूरजमुखी"
    },
    ta: {
      "Rice": "அரிசி",
      "Wheat": "கோதுமை",
      "Maize": "மக்காச்சோளம்",
      "Cotton": "பருத்தி",
      "Sugarcane": "கரும்பு",
      "Potato": "உருளைக்கிழங்கு",
      "Tomato": "தக்காளி",
      "Onion": "வெங்காயம்",
      "Chilli": "மிளகாய்",
      "Soybean": "சோயாபீன்",
      "Chickpea": "கடலை",
      "Groundnut": "நிலக்கடலை",
      "Mustard": "கடுகு",
      "Turmeric": "மஞ்சள்",
      "Garlic": "பூண்டு",
      "Okra": "வெண்டைக்காய்",
      "Millet": "கம்பு",
      "Barley": "பார்லி",
      "Sunflower": "சூரியகாந்தி"
    },
    te: {
      "Rice": "వరి",
      "Wheat": "గోధుమ",
      "Maize": "మొక్కజొన్న",
      "Cotton": "పత్తి",
      "Sugarcane": "చెరకు",
      "Potato": "బంగాళాదుంప",
      "Tomato": "టమాటో",
      "Onion": "ఉల్లిపాయ",
      "Chilli": "మిరప",
      "Soybean": "సోయాబీన్",
      "Chickpea": "శనగలు",
      "Groundnut": "వేరుశెనగ",
      "Mustard": "ఆవాలు",
      "Turmeric": "పసుపు",
      "Garlic": "వెల్లుల్లి",
      "Okra": "బెండకాయ",
      "Millet": "సజ్జలు",
      "Barley": "బార్లీ",
      "Sunflower": "సూర్యకాంతం"
    },
    bn: {
      "Rice": "চাল",
      "Wheat": "গম",
      "Maize": "ভুট্টা",
      "Cotton": "তুলা",
      "Sugarcane": "আখ",
      "Potato": "আলু",
      "Tomato": "টমেটো",
      "Onion": "পেঁয়াজ",
      "Chilli": "মরিচ",
      "Soybean": "সয়াবিন",
      "Chickpea": "ছোলা",
      "Groundnut": "চিনাবাদাম",
      "Mustard": "সরিষা",
      "Turmeric": "হলুদ",
      "Garlic": "রসুন",
      "Okra": "ঢেঁড়স",
      "Millet": "বাজরা",
      "Barley": "বার্লি",
      "Sunflower": "সূর্যমুখী"
    },
    pa: {
      "Rice": "ਚਾਵਲ",
      "Wheat": "ਕਣਕ",
      "Maize": "ਮੱਕੀ",
      "Cotton": "ਕਪਾਹ",
      "Sugarcane": "ਗੰਨਾ",
      "Potato": "ਆਲੂ",
      "Tomato": "ਟਮਾਟਰ",
      "Onion": "ਪਿਆਜ਼",
      "Chilli": "ਮਿਰਚ",
      "Soybean": "ਸੋਯਾਬੀਨ",
      "Chickpea": "ਛੋਲੇ",
      "Groundnut": "ਮੂੰਗਫਲੀ",
      "Mustard": "ਸਰ੍ਹੋਂ",
      "Turmeric": "ਹਲਦੀ",
      "Garlic": "ਲਸਣ",
      "Okra": "ਭਿੰਡੀ",
      "Millet": "ਬਾਜਰਾ",
      "Barley": "ਜੌਂ",
      "Sunflower": "ਸੂਰਜਮੁਖੀ"
    }
  };

  // Translation table for soil types
  const soilTranslations = {
    hi: {
      "Sandy": "रेतीली मिट्टी",
      "Clay": "चिकनी मिट्टी",
      "Loamy": "दोमट मिट्टी",
      "Silt": "गाद मिट्टी",
      "Black": "काली मिट्टी",
      "Red": "लाल मिट्टी",
      "Alluvial": "जलोढ़ मिट्टी",
      "Laterite": "लेटराइट मिट्टी",
      "Peaty": "पीटी मिट्टी",
      "Calcareous": "चूना युक्त मिट्टी",
      "Saline": "लवणीय मिट्टी",
      "Acidic": "अम्लीय मिट्टी"
    },
    ta: {
      "Sandy": "மணல் மண்",
      "Clay": "களிமண்",
      "Loamy": "வண்டல் மண்",
      "Silt": "மென்மணல் மண்",
      "Black": "கருப்பு மண்",
      "Red": "சிவப்பு மண்",
      "Alluvial": "வண்டல் மண்",
      "Laterite": "சிவப்பு பாறை மண்",
      "Peaty": "மதகு மண்",
      "Calcareous": "சுண்ணாம்பு மண்",
      "Saline": "உப்பு மண்",
      "Acidic": "அமில மண்"
    },
    te: {
      "Sandy": "ఇసుక నేల",
      "Clay": "బంక మట్టి",
      "Loamy": "లోమీ మట్టి",
      "Silt": "పురడు మట్టి",
      "Black": "నల్ల మట్టి",
      "Red": "ఎర్ర మట్టి",
      "Alluvial": "ఒండ్రు మట్టి",
      "Laterite": "ఎర్ర రాతి మట్టి",
      "Peaty": "పీటీ మట్టి",
      "Calcareous": "సున్నపు రాయి మట్టి",
      "Saline": "ఉప్పు మట్టి",
      "Acidic": "ఆమ్ల మట్టి"
    },
    bn: {
      "Sandy": "বালুময় মাটি",
      "Clay": "কাদামাটি",
      "Loamy": "দোআঁশ মাটি",
      "Silt": "পলি মাটি",
      "Black": "কালো মাটি",
      "Red": "লাল মাটি",
      "Alluvial": "পলি মাটি",
      "Laterite": "লাল মাটি",
      "Peaty": "পিট মাটি",
      "Calcareous": "চুনযুক্ত মাটি",
      "Saline": "লবণাক্ত মাটি",
      "Acidic": "অম্লীয় মাটি"
    },
    pa: {
      "Sandy": "ਰੇਤਲੀ ਮਿੱਟੀ",
      "Clay": "ਚੀਕਣੀ ਮਿੱਟੀ",
      "Loamy": "ਦੋਮਟ ਮਿੱਟੀ",
      "Silt": "ਗਾਰਾ ਮਿੱਟੀ",
      "Black": "ਕਾਲੀ ਮਿੱਟੀ",
      "Red": "ਲਾਲ ਮਿੱਟੀ",
      "Alluvial": "ਜਲੋੜ੍ਹ ਮਿੱਟੀ",
      "Laterite": "ਲੈਟਰਾਈਟ ਮਿੱਟੀ",
      "Peaty": "ਪੀਟੀ ਮਿੱਟੀ",
      "Calcareous": "ਚੂਨਾ ਵਾਲੀ ਮਿੱਟੀ",
      "Saline": "ਲੂਣੀ ਮਿੱਟੀ",
      "Acidic": "ਤੇਜ਼ਾਬੀ ਮਿੱਟੀ"
    }
  };

  // Get all language selector options
  const languageSelectors = document.querySelectorAll(".language-option");
  console.log("Found language selectors:", languageSelectors.length);
  
  // Add click handlers to language options
  languageSelectors.forEach(selector => {
    selector.addEventListener("click", function(e) {
      e.preventDefault();
      const language = this.getAttribute("data-lang");
      console.log(`Language changed to: ${language} (${this.textContent.split(" ")[0]})`);
      
      // Save selected language
      currentLanguage = language;
      localStorage.setItem('selectedLanguage', language);
      
      // Apply translations
      if (language === "en") {
        location.reload(); // Simplest way to reset to English
        return;
      }
      
      applyTranslations(language);
    });
  });
  
  // Main function to apply translations throughout the app
  function applyTranslations(language) {
    if (!translations[language]) {
      console.log("No translations available for", language);
      return;
    }

    // 1. Update the language dropdown text
    document.querySelector(".language-text").textContent = 
      document.querySelector(`[data-lang="${language}"]`).textContent.split(" ")[0];
    
    // 2. Update all elements with data-i18n attributes
    document.querySelectorAll("[data-i18n]").forEach(element => {
      const key = element.getAttribute("data-i18n");
      if (translations[language][key]) {
        // Special handling for buttons with icons
        if (element.tagName === "BUTTON" && element.querySelector("i")) {
          const icon = element.querySelector("i").outerHTML;
          element.innerHTML = icon + " " + translations[language][key];
        } else {
          element.textContent = translations[language][key];
        }
      }
    });
    
    // 3. Translate all dropdown options for crops
    document.querySelectorAll('select[id*="Crop"] option').forEach(option => {
      const cropValue = option.value;
      if (cropValue && cropTranslations[language] && cropTranslations[language][cropValue]) {
        option.textContent = cropTranslations[language][cropValue];
      }
    });
    
    // 4. Translate all dropdown options for soil types
    document.querySelectorAll('select[id*="Soil"] option').forEach(option => {
      const soilValue = option.value;
      if (soilValue && soilTranslations[language] && soilTranslations[language][soilValue]) {
        option.textContent = soilTranslations[language][soilValue];
      }
    });
    
    // 5. Translate other specific sections that don't have data-i18n attributes
    translateLoginRegisterSections(language);
    translateDiseaseDetectionSection(language);
    translateWeatherSection(language);
    translateMarketSection(language);
    translateAIGuidanceResults(language);
    translateFooter(language);
  }
  
  // Helper functions for translating specific sections
  function translateLoginRegisterSections(language) {
    const loginSectionTranslations = {
      hi: {
        "Login": "लॉगिन",
        "Username": "यूजरनेम",
        "Password": "पासवर्ड",
        "Don't have an account?": "खाता नहीं है?",
        "Register now": "अभी रजिस्टर करें",
        "Register": "रजिस्टर",
        "Email": "ईमेल",
        "Confirm Password": "पासवर्ड की पुष्टि करें",
        "Already have an account?": "पहले से ही खाता है?",
        "Farmer Dashboard": "किसान डैशबोर्ड",
        "Fields": "खेत",
        "Crops": "फसलें",
        "Alerts": "अलर्ट",
        "Health Index": "स्वास्थ्य सूचकांक",
        "Your Fields": "आपके खेत",
        "No fields added yet": "अभी तक कोई खेत नहीं जोड़ा गया",
        "Add New Field": "नया खेत जोड़ें",
        "Weather": "मौसम",
        "Field Details": "खेत का विवरण",
        "Select a field to view details": "विवरण देखने के लिए एक खेत चुनें"
      },
      // Add other languages similarly
    };
    
    if (loginSectionTranslations[language]) {
      // Apply translations for login/register/dashboard section
      // This is just an example - you would need to fill in the actual implementation
      
      // For example:
      document.querySelectorAll("#loginSection label, #registerSection label").forEach(label => {
        const originalText = label.textContent;
        if (loginSectionTranslations[language][originalText]) {
          label.textContent = loginSectionTranslations[language][originalText];
        }
      });
    }
  }
  
  function translateDiseaseDetectionSection(language) {
    const diseaseTranslations = {
      hi: {
        "Crop Disease Detection": "फसल रोग पहचान",
        "Upload a Photo of Your Crop": "अपनी फसल की फोटो अपलोड करें",
        "Take a clear photo of the affected plant part (leaf, stem, fruit) and upload it below.": "प्रभावित पौधे के हिस्से (पत्ती, तना, फल) की एक स्पष्ट फोटो लें और नीचे अपलोड करें।",
        "Drag & Drop or Click to Upload": "खींचें और छोड़ें या अपलोड करने के लिए क्लिक करें",
        "Supported formats: JPG, PNG": "समर्थित प्रारूप: JPG, PNG",
        "Reset": "रीसेट",
        "Analyze Image": "छवि का विश्लेषण करें",
        "Analyzing image... This may take a moment.": "छवि का विश्लेषण किया जा रहा है... इसमें कुछ समय लग सकता है।",
        "Confidence:": "विश्वास:",
        "Symptoms:": "लक्षण:",
        "Recommended Treatment:": "अनुशंसित उपचार:",
        "Save Report": "रिपोर्ट सहेजें"
      },
      // Add translations for other languages
    };
    
    if (diseaseTranslations[language]) {
      // Example implementation
      const diseaseSection = document.getElementById("diseaseDetectionSection");
      if (diseaseSection) {
        diseaseSection.querySelectorAll("h2, h4, h5, p:not([id]), label, button").forEach(element => {
          const originalText = element.textContent.trim();
          if (diseaseTranslations[language][originalText]) {
            // Preserve any inner HTML for buttons with icons
            if (element.tagName === "BUTTON" && element.querySelector("i")) {
              const icon = element.querySelector("i").outerHTML;
              element.innerHTML = icon + " " + diseaseTranslations[language][originalText];
            } else {
              element.textContent = diseaseTranslations[language][originalText];
            }
          }
        });
      }
    }
  }
  
  function translateWeatherSection(language) {
    // Similar implementation for weather section
  }
  
  function translateMarketSection(language) {
    // Similar implementation for market prices section
  }
  
  function translateAIGuidanceResults(language) {
    // Check if guidance results are displayed
    const guidanceResults = document.getElementById('guidanceResults');
    if (!guidanceResults || !translations[language]) return;
    
    // Translate article headers
    guidanceResults.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(header => {
      // Get first few words to identify the section
      const headerText = header.textContent.trim();
      
      // Translate common article headers
      if (headerText.includes('Introduction') && translations[language]['introduction']) {
        header.textContent = translations[language]['introduction'];
      } else if (headerText.includes('Cultivation') && translations[language]['cultivation']) {
        header.textContent = translations[language]['cultivation'];
      } else if (headerText.includes('Fertilizer') && translations[language]['fertilizer_recommendations']) {
        header.textContent = translations[language]['fertilizer_recommendations'];
      } else if (headerText.includes('Irrigation') && translations[language]['irrigation_recommendations']) {
        header.textContent = translations[language]['irrigation_recommendations'];
      } else if (headerText.includes('Diseases') && translations[language]['diseases_and_pests']) {
        header.textContent = translations[language]['diseases_and_pests'];
      } else if (headerText.includes('Harvesting') && translations[language]['harvesting']) {
        header.textContent = translations[language]['harvesting'];
      }
    });
  }
  
  function translateFooter(language) {
    if (!translations[language]) return;
    
    // Get footer elements
    const footer = document.querySelector('footer');
    if (!footer) return;
    
    // Translate footer headings
    footer.querySelectorAll('h5').forEach(heading => {
      const originalText = heading.textContent.trim();
      if (originalText === "FarmAssist AI" && translations[language]['farmassist_ai']) {
        heading.textContent = translations[language]['farmassist_ai'];
      } else if (originalText === "Quick Links" && translations[language]['quick_links']) {
        heading.textContent = translations[language]['quick_links'];
      } else if (originalText === "Contact" && translations[language]['contact']) {
        heading.textContent = translations[language]['contact'];
      }
    });
    
    // Translate footer text
    footer.querySelectorAll('p').forEach(paragraph => {
      const originalText = paragraph.textContent.trim();
      if (originalText === "Your AI-powered farming companion" && translations[language]['ai_companion']) {
        paragraph.textContent = translations[language]['ai_companion'];
      } else if (originalText.includes("All rights reserved") && translations[language]['copyright']) {
        paragraph.textContent = translations[language]['copyright'];
      }
    });
    
    // Translate quick links
    footer.querySelectorAll('ul.list-unstyled li a').forEach(link => {
      const originalText = link.textContent.trim();
      if (originalText === "Home" && translations[language]['home']) {
        link.textContent = translations[language]['home'];
      } else if (originalText === "Disease Detection" && translations[language]['disease_detection']) {
        link.textContent = translations[language]['disease_detection'];
      } else if (originalText === "Market Prices" && translations[language]['market_prices']) {
        link.textContent = translations[language]['market_prices'];
      } else if (originalText === "Weather" && translations[language]['weather']) {
        link.textContent = translations[language]['weather'];
      }
    });
  }
  
  // Function to translate dynamic content loaded from API calls
  function translateAPIResponse(element, language) {
    if (!element || !translations[language]) return;
    
    // First, translate any data-i18n attributes
    element.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (translations[language][key]) {
        el.textContent = translations[language][key];
      }
    });
    
    // Then try to translate common elements without data-i18n attributes
    // For example, crop names and soil types in the results
    element.querySelectorAll('p, h1, h2, h3, h4, h5, h6, li, td, th, button, label').forEach(el => {
      const text = el.textContent.trim();
      
      // Check if text contains crop names
      Object.keys(cropTranslations[language] || {}).forEach(cropName => {
        if (text.includes(cropName)) {
          el.textContent = el.textContent.replace(
            cropName, 
            cropTranslations[language][cropName]
          );
        }
      });
      
      // Check if text contains soil types
      Object.keys(soilTranslations[language] || {}).forEach(soilType => {
        if (text.includes(soilType)) {
          el.textContent = el.textContent.replace(
            soilType, 
            soilTranslations[language][soilType]
          );
        }
      });
    });
    
    // Special handling for AI-generated guidance article
    if (element.id === 'guidanceResults') {
      translateAIGuidanceResults(language);
    }
  }
  
  // Export important functions for global access
  window.applyTranslations = applyTranslations;
  window.currentLanguage = currentLanguage;
  window.translateAPIResponse = translateAPIResponse;
  
  // Add event listener for dynamic content loading
  document.addEventListener("contentLoaded", function(e) {
    if (currentLanguage !== "en") {
      // Translate newly loaded content
      setTimeout(() => applyTranslations(currentLanguage), 100);
    }
  });
  
  // Modify the main.js functions for API processing
  // When API responses are processed, call translateAPIResponse on the container element
  const originalFetchAPI = window.fetchAPI;
  if (originalFetchAPI) {
    window.fetchAPI = async function(...args) {
      const response = await originalFetchAPI(...args);
      
      // After processing API response, translate content if needed
      if (currentLanguage !== "en") {
        setTimeout(() => {
          // Translate results in commonly updated containers
          const containers = [
            document.getElementById('guidanceResults'),
            document.getElementById('marketPricesTable'),
            document.getElementById('currentWeather'),
            document.getElementById('resultContainer'),
            document.getElementById('fieldDetails')
          ];
          
          containers.forEach(container => {
            if (container && !container.classList.contains('hidden')) {
              translateAPIResponse(container, currentLanguage);
            }
          });
        }, 500);
      }
      
      return response;
    };
  }
});