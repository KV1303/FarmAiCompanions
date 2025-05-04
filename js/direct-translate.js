// This file is now deprecated as we've moved to Hindi-only interface
// This simply logs some information for debugging purposes

console.log("Direct translate script loaded");

document.addEventListener("DOMContentLoaded", function() {
  // The language functionality is now removed as we're only supporting Hindi
  
  // Log that the DOMContentLoaded event was triggered
  console.log("DOM content loaded - Hindi-only interface active");
  
  // We no longer need language selection functionality
  // Set the preferred language to Hindi permanently
  localStorage.setItem('preferred_language', 'hi');
  console.log("Setting permanent language: Hindi");
  
  // Log that we no longer support language selectors
  console.log("Language selection has been disabled - Hindi only");
  
  // Safety check to avoid null references with classList
  try {
    // Apply Hindi class to body for any CSS targeting
    document.body.setAttribute('lang', 'hi');
  } catch (error) {
    console.log("Error setting Hindi language attribute:", error);
  }
});

// This function is kept for backward compatibility but doesn't do anything now
function applyTranslations(language) {
  // Ignore any language parameter, always default to Hindi
  console.log("Hindi-only interface, ignoring language selection:", language);
}