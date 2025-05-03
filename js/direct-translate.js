// This file is now deprecated as we've moved to a browser-integrated translator
// This simply logs some information for debugging purposes

console.log("Direct translate script loaded");

document.addEventListener("DOMContentLoaded", function() {
  // The language functionality is now handled by the custom translation script in index.html
  
  // Log that the DOMContentLoaded event was triggered
  console.log("DOM content loaded - setting up language switcher");
  
  // Load previously selected language from localStorage if available
  const savedLanguage = localStorage.getItem('preferred_language');
  console.log("Loading saved language: " + (savedLanguage || 'en'));
  
  // Log the number of language selectors found
  const languageSelectors = document.querySelectorAll('.language-option');
  console.log("Found language selectors:", languageSelectors.length);
});

// This function is kept for backward compatibility but doesn't do anything now
function applyTranslations(language) {
  console.log("No translations available for", language);
}