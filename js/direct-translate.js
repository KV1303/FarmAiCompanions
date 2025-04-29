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
      "get_started": "शुरू करें"
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
      "get_started": "தொடங்குங்கள்"
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