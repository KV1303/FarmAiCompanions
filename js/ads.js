// FarmAssist AI - AdMob Integration

// Ad Units
const AD_UNITS = {
  BANNER: 'ca-app-pub-3734294344200337/3068736185',
  INTERSTITIAL: 'ca-app-pub-3734294344200337/5398170069'
};

// AdMob initialization
let interstitialAd = null;
let isAdMobInitialized = false;
let interstitialAdLoaded = false;
let lastInterstitialShownTime = 0; // Timestamp of the last interstitial shown
const INTERSTITIAL_COOLDOWN = 30000; // 30 seconds cooldown between interstitial ads to increase ad views
let bannerAdsCreated = false; // Track if banner ads have been created
let adMobAvailable = false; // Track if AdMob is available

// Initialize AdMob
function initializeAdMob() {
  if (isAdMobInitialized) return;
  
  // Check if running in Cordova environment with AdMob plugin
  if (typeof admob === 'undefined') {
    console.log('AdMob not available, using placeholder ads');
    // Show placeholders instead of real ads
    adMobAvailable = false;
    showPlaceholderAds();
    return;
  }
  
  console.log('Initializing AdMob with units:', AD_UNITS);
  adMobAvailable = true;
  
  // Add device-ready event listener for Cordova
  document.addEventListener('deviceready', function() {
    // Initialize AdMob with necessary options
    admob.initialize({
      // Optional options for better UX
      bannerAtTop: false,
      overlap: false,
      offsetTopBar: false,
      isTesting: false // Set to true during development
    }).then(() => {
      console.log('AdMob initialization complete');
      isAdMobInitialized = true;
      
      // Start preloading interstitial
      preloadInterstitial();
      
      // Create banner ads in designated containers
      createBannerAds();
    }).catch(error => {
      console.error('AdMob initialization error:', error);
      // Show placeholders if AdMob fails to initialize
      showPlaceholderAds();
    });
  }, false);
}

// Show placeholder ads when AdMob is not available
function showPlaceholderAds() {
  console.log('Showing placeholder ads');
  document.querySelectorAll('.ad-banner-container .ad-placeholder').forEach(placeholder => {
    placeholder.style.display = 'block';
    placeholder.textContent = 'विज्ञापन स्थान'; // Advertisement space in Hindi
  });
}

// Preload interstitial ad
function preloadInterstitial() {
  if (!isAdMobInitialized) return;
  
  console.log('Preloading interstitial ad...');
  
  admob.prepareInterstitial({
    adId: AD_UNITS.INTERSTITIAL,
    autoShow: false
  }).then(() => {
    console.log('Interstitial ad loaded');
    interstitialAdLoaded = true;
  }).catch(error => {
    console.error('Error loading interstitial ad:', error);
    interstitialAdLoaded = false;
  });
}

// Create banner ads in designated containers
function createBannerAds() {
  if (!isAdMobInitialized) return;
  
  const bannerContainers = document.querySelectorAll('.ad-banner-container');
  
  bannerContainers.forEach((container, index) => {
    console.log(`Creating banner ad #${index + 1} in container ${container.id}`);
    
    // Clear placeholder text when showing real ad
    const placeholder = container.querySelector('.ad-placeholder');
    if (placeholder) {
      placeholder.style.display = 'none';
    }
    
    // Create a banner ad for this container
    admob.createBannerView({
      adId: AD_UNITS.BANNER,
      adSize: 'SMART_BANNER',
      position: container.id, // Use container ID as position
      autoShow: true
    }).then(() => {
      console.log(`Banner ad #${index + 1} created successfully in ${container.id}`);
      container.classList.add('ad-loaded');
    }).catch(error => {
      console.error(`Error creating banner ad #${index + 1} in ${container.id}:`, error);
      // Show placeholder again if ad fails to load
      if (placeholder) {
        placeholder.style.display = 'block';
      }
    });
  });
}

// Show interstitial ad with rate limiting
function showInterstitialAd() {
  // If AdMob isn't available or initialized, we just return without showing an ad
  if (!adMobAvailable || !isAdMobInitialized) {
    console.log('AdMob not available or not initialized, skipping interstitial ad');
    return;
  }
  
  // If an interstitial ad isn't loaded yet, skip showing
  if (!interstitialAdLoaded) {
    console.log('Interstitial ad not ready to show');
    return;
  }
  
  // Rate limiting to prevent too many ads from showing
  const now = Date.now();
  if (now - lastInterstitialShownTime < INTERSTITIAL_COOLDOWN) {
    console.log('Interstitial ad on cooldown, skipping');
    return;
  }
  
  console.log('Showing interstitial ad...');
  
  // Show the interstitial ad
  admob.showInterstitial().then(() => {
    console.log('Interstitial ad shown successfully');
    interstitialAdLoaded = false;
    lastInterstitialShownTime = now;
    
    // Preload the next interstitial
    setTimeout(preloadInterstitial, 1000);
  }).catch(error => {
    console.error('Error showing interstitial ad:', error);
    // If showing fails, reset the cooldown to allow another attempt sooner
    lastInterstitialShownTime = now - (INTERSTITIAL_COOLDOWN / 2);
  });
}

// Setup click handlers for showing interstitial ads
function setupAdClickHandlers() {
  // List of buttons that should trigger interstitial ads
  const adTriggerButtons = [
    '.track-price-btn',       // Track price buttons
    '#scanForDiseaseBtn',     // Scan for disease button
    '#getWeatherBtn',         // Get weather button
    '#applyFilterBtn',        // Apply filter button for market prices
    '#btnGenerateGuidance',   // Generate guidance button
    '#analyzeImageBtn',       // Disease detection analyze button
    '#btnAdvancedFertilizer', // Advanced fertilizer recommendations button
    '#btnIrrigation',         // Irrigation recommendations button
    '#featureChatbotBtn',     // Chatbot feature button
    '#sendChatMessageBtn',    // Send chat message button
    '#saveFieldBtn',          // Save field button
    '#saveDiseaseReportBtn',  // Save disease report button
    '.card-link',             // Various card links throughout the app
    '.nav-link'               // Navigation links
  ];
  
  // Add event listeners to all buttons matching the selectors
  adTriggerButtons.forEach(selector => {
    document.querySelectorAll(selector).forEach(button => {
      // Store original click handler
      const originalClickHandler = button.onclick;
      
      // Replace with new handler that shows ad and then calls original handler
      button.onclick = function(event) {
        // Show interstitial ad
        showInterstitialAd();
        
        // Call original handler if it exists
        if (typeof originalClickHandler === 'function') {
          // Use setTimeout to ensure ad has a chance to show first
          setTimeout(() => originalClickHandler.call(this, event), 300);
        }
      };
    });
  });
}

// Initialize ads when document is ready
document.addEventListener('DOMContentLoaded', function() {
  // Short delay to ensure page is fully loaded
  setTimeout(() => {
    initializeAdMob();
    
    // Setup click handlers after a delay to ensure other scripts have run
    setTimeout(setupAdClickHandlers, 2000);
  }, 1000);
});

// Re-setup ad click handlers after any major DOM changes
function refreshAdClickHandlers() {
  setTimeout(setupAdClickHandlers, 500);
}

// Add banner ad containers to the DOM
function createAdContainers() {
  console.log('Creating ad banner containers...');
  
  // No need to programmatically create containers that are already in the HTML
  // We now have banner ad containers for:
  // - Market prices section (market-top-ad)
  // - Weather section (weather-top-ad)
  // - Disease detection section (disease-top-ad)
  // - Testimonials section (testimonials-top-ad)
  
  // Add a few more strategic locations for banner ads
  const adLocations = [
    { selector: '#chatSection .container', position: 'afterbegin', id: 'chat-top-ad' },
    { selector: '#farmManagementSection .container', position: 'afterbegin', id: 'farmmanagement-top-ad' }, 
    { selector: '#dashboardSection .row', position: 'afterend', id: 'dashboard-bottom-ad' }
  ];
  
  adLocations.forEach((location, index) => {
    const targetElement = document.querySelector(location.selector);
    if (!targetElement) {
      console.log(`Target element not found for ${location.selector}`);
      return;
    }
    
    // Check if this container already exists
    if (document.getElementById(location.id)) {
      console.log(`Ad container ${location.id} already exists, skipping`);
      return;
    }
    
    const adContainer = document.createElement('div');
    adContainer.className = 'ad-banner-container mb-3 text-center';
    adContainer.id = location.id;
    adContainer.innerHTML = '<p class="ad-placeholder">विज्ञापन</p>';
    
    if (location.position === 'afterend') {
      targetElement.insertAdjacentElement('afterend', adContainer);
    } else if (location.position === 'afterbegin') {
      targetElement.insertAdjacentElement('afterbegin', adContainer);
    } else if (location.position === 'beforeend') {
      targetElement.insertAdjacentElement('beforeend', adContainer);
    }
    
    console.log(`Ad container #${index} created at ${location.selector}`);
  });
}

// Detect mobile platforms for AdMob integration
function detectMobilePlatform() {
  const userAgent = navigator.userAgent || navigator.vendor || window.opera;
  
  // Check if it's an Android device
  if (/android/i.test(userAgent)) {
    console.log('Android device detected');
    return 'android';
  }
  
  // Check if it's an iOS device
  if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
    console.log('iOS device detected');
    return 'ios';
  }
  
  // It's not a mobile device or not a recognized platform
  console.log('Desktop or unrecognized mobile platform detected');
  return 'web';
}

// Initialize platform-specific ad settings
function initPlatformSpecificSettings() {
  const platform = detectMobilePlatform();
  
  // Apply platform-specific settings
  if (platform === 'android' || platform === 'ios') {
    console.log(`Applying AdMob settings for ${platform}`);
    // Mobile platforms will use the Cordova AdMob plugin
    document.addEventListener('deviceready', function() {
      initializeAdMob();
    }, false);
  } else {
    // Web platform gets placeholder ads
    showPlaceholderAds();
  }
}

// Expose functions globally
window.adManager = {
  showInterstitial: showInterstitialAd,
  refreshHandlers: refreshAdClickHandlers,
  createAdContainers: createAdContainers,
  initPlatform: initPlatformSpecificSettings
};

// Create ad containers when page loads
document.addEventListener('DOMContentLoaded', function() {
  createAdContainers();
  initPlatformSpecificSettings();
});