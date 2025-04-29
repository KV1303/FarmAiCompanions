// Direct translation script
console.log("Direct translate script loaded");

document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM content loaded - setting up language switcher");
  
  // Simple language translations for key elements
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
      "plan_irrigation": "सिंचाई की योजना बनाएं"
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
  
  // Get all language selector options
  const languageSelectors = document.querySelectorAll(".language-option");
  console.log("Found language selectors:", languageSelectors.length);
  
  // Add click handlers
  languageSelectors.forEach(selector => {
    selector.addEventListener("click", function(e) {
      e.preventDefault();
      const language = this.getAttribute("data-lang");
      console.log("Language selected:", language);
      
      // Don't do anything for English
      if (language === "en") {
        return;
      }
      
      if (!translations[language]) {
        console.log("No translations available for", language);
        return;
      }
      
      // Update the dropdown text
      document.querySelector(".language-text").textContent = 
        this.textContent.split(" ")[0];
      
      // Update all elements with data-i18n attributes
      document.querySelectorAll("[data-i18n]").forEach(element => {
        const key = element.getAttribute("data-i18n");
        if (translations[language][key]) {
          console.log(`Translating ${key} to ${translations[language][key]}`);
          
          // Special handling for buttons with icons
          if (element.tagName === "BUTTON" && element.querySelector("i")) {
            const icon = element.querySelector("i").outerHTML;
            element.innerHTML = icon + " " + translations[language][key];
          } else {
            element.textContent = translations[language][key];
          }
        }
      });
    });
  });
  
  // Direct handlers for each language (just in case)
  document.querySelector('[data-lang="hi"]').onclick = function() {
    console.log("Hindi clicked directly");
    applyTranslations("hi");
  };
  
  document.querySelector('[data-lang="ta"]').onclick = function() {
    console.log("Tamil clicked directly");
    applyTranslations("ta");
  };
  
  function applyTranslations(language) {
    if (!translations[language]) {
      console.log("No translations available for", language);
      return;
    }
    
    // Update all translatable elements
    Object.keys(translations[language]).forEach(key => {
      const elements = document.querySelectorAll(`[data-i18n="${key}"]`);
      elements.forEach(element => {
        console.log(`Direct translate: ${key} to ${translations[language][key]}`);
        
        // Special handling for buttons with icons
        if (element.tagName === "BUTTON" && element.querySelector("i")) {
          const icon = element.querySelector("i").outerHTML;
          element.innerHTML = icon + " " + translations[language][key];
        } else {
          element.textContent = translations[language][key];
        }
      });
    });
    
    // Update dropdown display
    document.querySelector(".language-text").textContent = 
      document.querySelector(`[data-lang="${language}"]`).textContent.split(" ")[0];
  }
});