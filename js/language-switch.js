// Simple language switcher for FarmAssist AI

// This file is now only used for static translations using data-i18n attributes
// Google Translate is used for dynamic content translation

document.addEventListener('DOMContentLoaded', function() {
  // Language data for static UI elements with data-i18n attributes
  const languages = {
    en: {
      name: "English",
      home: "Home",
      dashboard: "Dashboard",
      disease_detection: "Disease Detection",
      market_prices: "Market Prices",
      weather: "Weather",
      login: "Login",
      register: "Register",
      logout: "Logout",
      revolutionize_farming: "Revolutionize Your Farming",
      ai_companion: "AI-powered companion for modern farmers",
      get_started: "Get Started",
      ai_farm_guidance: "AI Farm Guidance System",
      personalized_recommendations: "Get personalized farming recommendations",
      guidance_description: "Our AI-powered farm guidance system provides comprehensive recommendations tailored to your specific crops, soil type, and location.",
      crop_type: "Crop Type",
      soil_type: "Soil Type",
      get_farm_guidance: "Get Farm Guidance",
      select_crop: "Select a crop",
      select_soil: "Select soil type",
      what_farmassist_can_do: "What FarmAssist AI Can Do For You"
    },
    hi: {
      name: "हिन्दी",
      home: "होम",
      dashboard: "डैशबोर्ड",
      disease_detection: "रोग पहचान",
      market_prices: "बाजार भाव",
      weather: "मौसम",
      login: "लॉगिन",
      register: "रजिस्टर",
      logout: "लॉगआउट",
      revolutionize_farming: "अपनी खेती में क्रांति लाएँ",
      ai_companion: "आधुनिक किसानों के लिए AI-संचालित सहायक",
      get_started: "शुरू करें",
      ai_farm_guidance: "AI कृषि मार्गदर्शन प्रणाली",
      personalized_recommendations: "अपनी फसल के अनुसार व्यक्तिगत सिफारिशें प्राप्त करें",
      guidance_description: "हमारी AI-संचालित कृषि मार्गदर्शन प्रणाली आपकी विशिष्ट फसलों, मिट्टी के प्रकार और स्थान के अनुसार व्यापक सिफारिशें प्रदान करती है।",
      crop_type: "फसल का प्रकार",
      soil_type: "मिट्टी का प्रकार",
      get_farm_guidance: "कृषि मार्गदर्शन प्राप्त करें",
      select_crop: "फसल चुनें",
      select_soil: "मिट्टी का प्रकार चुनें",
      what_farmassist_can_do: "फार्मअसिस्ट AI आपके लिए क्या कर सकता है"
    },
    ta: {
      name: "தமிழ்",
      home: "முகப்பு",
      dashboard: "டாஷ்போர்டு",
      disease_detection: "நோய் கண்டறிதல்",
      market_prices: "சந்தை விலைகள்",
      weather: "வானிலை",
      login: "உள்நுழைக",
      register: "பதிவு செய்க",
      logout: "வெளியேறு",
      revolutionize_farming: "உங்கள் விவசாயத்தில் புரட்சி செய்யுங்கள்",
      ai_companion: "நவீன விவசாயிகளுக்கான AI-செயலாக்கப்பட்ட துணை",
      get_started: "தொடங்குங்கள்",
      ai_farm_guidance: "AI விவசாய வழிகாட்டும் அமைப்பு",
      personalized_recommendations: "உங்கள் சொந்த பயிர்களுக்கான தனிப்பயனாக்கப்பட்ட பரிந்துரைகளைப் பெறுங்கள்",
      guidance_description: "எங்களின் AI-செயலாக்கப்பட்ட விவசாய வழிகாட்டுதல் அமைப்பு உங்கள் குறிப்பிட்ட பயிர்கள், மண் வகை மற்றும் இருப்பிடத்திற்கு ஏற்ப விரிவான பரிந்துரைகளை வழங்குகிறது.",
      crop_type: "பயிர் வகை",
      soil_type: "மண் வகை",
      get_farm_guidance: "விவசாய வழிகாட்டுதல் பெறுக",
      select_crop: "பயிரைத் தேர்ந்தெடுக்கவும்",
      select_soil: "மண் வகையைத் தேர்ந்தெடுக்கவும்",
      what_farmassist_can_do: "FarmAssist AI உங்களுக்கு என்ன செய்ய முடியும்"
    },
    te: {
      name: "తెలుగు",
      home: "హోమ్",
      dashboard: "డాష్‌బోర్డ్",
      disease_detection: "రోగ నిర్ధారణ",
      market_prices: "మార్కెట్ ధరలు",
      weather: "వాతావరణం",
      login: "లాగిన్",
      register: "రిజిస్టర్",
      logout: "లాగౌట్",
      revolutionize_farming: "మీ వ్యవసాయాన్ని విప్లవాత్మకంగా మార్చండి",
      ai_companion: "ఆధునిక రైతులకు AI-ఆధారిత సహాయకుడు",
      get_started: "ప్రారంభించండి",
      ai_farm_guidance: "AI వ్యవసాయ మార్గదర్శక వ్యవస్థ",
      personalized_recommendations: "మీ పంటలకు అనుగుణంగా వ్యక్తిగత సిఫార్సులను పొందండి",
      guidance_description: "మా AI-ఆధారిత వ్యవసాయ మార్గదర్శక వ్యవస్థ మీ ప్రత్యేక పంటలు, నేల రకం మరియు ప్రాంతానికి అనుగుణంగా సమగ్ర సిఫార్సులను అందిస్తుంది.",
      crop_type: "పంట రకం",
      soil_type: "నేల రకం",
      get_farm_guidance: "వ్యవసాయ మార్గదర్శకతను పొందండి",
      select_crop: "పంటను ఎంచుకోండి",
      select_soil: "నేల రకాన్ని ఎంచుకోండి",
      what_farmassist_can_do: "FarmAssist AI మీకు ఏమి చేయగలదు"
    },
    bn: {
      name: "বাংলা",
      home: "হোম",
      dashboard: "ড্যাশবোর্ড",
      disease_detection: "রোগ সনাক্তকরণ",
      market_prices: "বাজার দর",
      weather: "আবহাওয়া",
      login: "লগইন",
      register: "নিবন্ধন",
      logout: "লগআউট",
      revolutionize_farming: "আপনার কৃষিকে বিপ্লব করুন",
      ai_companion: "আধুনিক কৃষকদের জন্য AI-চালিত সহায়ক",
      get_started: "শুরু করুন",
      ai_farm_guidance: "AI কৃষি গাইডেন্স সিস্টেম",
      personalized_recommendations: "আপনার ফসলের জন্য ব্যক্তিগতকৃত সুপারিশ পান",
      guidance_description: "আমাদের AI-চালিত কৃষি গাইডেন্স সিস্টেম আপনার নির্দিষ্ট ফসল, মাটির ধরন এবং অবস্থান অনুযায়ী বিস্তৃত সুপারিশ প্রদান করে।",
      crop_type: "ফসলের ধরন",
      soil_type: "মাটির ধরন",
      get_farm_guidance: "কৃষি গাইডেন্স পান",
      select_crop: "একটি ফসল নির্বাচন করুন",
      select_soil: "মাটির ধরন নির্বাচন করুন",
      what_farmassist_can_do: "FarmAssist AI আপনার জন্য কী করতে পারে"
    },
    pa: {
      name: "ਪੰਜਾਬੀ",
      home: "ਹੋਮ",
      dashboard: "ਡੈਸ਼ਬੋਰਡ",
      disease_detection: "ਰੋਗ ਦੀ ਪਛਾਣ",
      market_prices: "ਮਾਰਕੀਟ ਦੀਆਂ ਕੀਮਤਾਂ",
      weather: "ਮੌਸਮ",
      login: "ਲੌਗਇਨ",
      register: "ਰਜਿਸਟਰ",
      logout: "ਲੌਗਆਊਟ",
      revolutionize_farming: "ਆਪਣੀ ਖੇਤੀ ਵਿੱਚ ਕ੍ਰਾਂਤੀ ਲਿਆਓ",
      ai_companion: "ਆਧੁਨਿਕ ਕਿਸਾਨਾਂ ਲਈ AI-ਸੰਚਾਲਿਤ ਸਾਥੀ",
      get_started: "ਸ਼ੁਰੂ ਕਰੋ",
      ai_farm_guidance: "AI ਫਾਰਮ ਗਾਈਡੈਂਸ ਸਿਸਟਮ",
      personalized_recommendations: "ਆਪਣੀਆਂ ਫਸਲਾਂ ਲਈ ਵਿਅਕਤੀਗਤ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਾਪਤ ਕਰੋ",
      guidance_description: "ਸਾਡਾ AI-ਸੰਚਾਲਿਤ ਖੇਤੀ ਮਾਰਗਦਰਸ਼ਨ ਸਿਸਟਮ ਤੁਹਾਡੀਆਂ ਖਾਸ ਫਸਲਾਂ, ਮਿੱਟੀ ਦੀ ਕਿਸਮ ਅਤੇ ਸਥਾਨ ਦੇ ਅਨੁਸਾਰ ਵਿਆਪਕ ਸਿਫਾਰਸ਼ਾਂ ਪ੍ਰਦਾਨ ਕਰਦਾ ਹੈ।",
      crop_type: "ਫਸਲ ਦੀ ਕਿਸਮ",
      soil_type: "ਮਿੱਟੀ ਦੀ ਕਿਸਮ",
      get_farm_guidance: "ਖੇਤੀ ਮਾਰਗਦਰਸ਼ਨ ਪ੍ਰਾਪਤ ਕਰੋ",
      select_crop: "ਫਸਲ ਚੁਣੋ",
      select_soil: "ਮਿੱਟੀ ਦੀ ਕਿਸਮ ਚੁਣੋ",
      what_farmassist_can_do: "FarmAssist AI ਤੁਹਾਡੇ ਲਈ ਕੀ ਕਰ ਸਕਦਾ ਹੈ"
    }
  };

  // This functionality has been moved to the index.html script
  // We're keeping this file with the translations dictionary
  // for potential future use with static elements
  
  // Function to apply language translations to static elements (if needed)
  function applyLanguage(langCode) {
    if (!languages[langCode]) {
      console.error(`Language ${langCode} not found`);
      langCode = 'en'; // Fallback to English
    }
    
    console.log(`Applying static translations for ${langCode}`);
    
    // Find all elements with data-i18n attribute
    const elementsToTranslate = document.querySelectorAll('[data-i18n]');
    
    // Update each element with the appropriate translation
    elementsToTranslate.forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (languages[langCode][key]) {
        // If it's a button with an icon, preserve the icon
        if (el.tagName === 'BUTTON' && el.querySelector('i')) {
          const icon = el.querySelector('i').outerHTML;
          el.innerHTML = icon + ' ' + languages[langCode][key];
        } else {
          el.textContent = languages[langCode][key];
        }
      }
    });
  }
  
  // Make the function globally available
  window.applyStaticTranslations = applyLanguage;
});