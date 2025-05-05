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
const INTERSTITIAL_COOLDOWN = 60000; // 60 seconds cooldown between interstitial ads

// Initialize AdMob
function initializeAdMob() {
  if (isAdMobInitialized) return;
  
  if (typeof admob === 'undefined') {
    console.log('AdMob not available, skipping initialization');
    return;
  }
  
  console.log('Initializing AdMob...');
  
  // Initialize with necessary options
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
    console.log(`Creating banner ad #${index + 1}`);
    
    admob.createBannerView({
      adId: AD_UNITS.BANNER,
      adSize: 'SMART_BANNER',
      position: 8, // BOTTOM_CENTER
      autoShow: true
    }).then(() => {
      console.log(`Banner ad #${index + 1} created successfully`);
    }).catch(error => {
      console.error(`Error creating banner ad #${index + 1}:`, error);
    });
  });
}

// Show interstitial ad with rate limiting
function showInterstitialAd() {
  if (!isAdMobInitialized || !interstitialAdLoaded) {
    console.log('Interstitial ad not ready to show');
    return;
  }
  
  const now = Date.now();
  if (now - lastInterstitialShownTime < INTERSTITIAL_COOLDOWN) {
    console.log('Interstitial ad on cooldown, skipping');
    return;
  }
  
  console.log('Showing interstitial ad...');
  
  admob.showInterstitial().then(() => {
    console.log('Interstitial ad shown successfully');
    interstitialAdLoaded = false;
    lastInterstitialShownTime = now;
    
    // Preload the next interstitial
    setTimeout(preloadInterstitial, 1000);
  }).catch(error => {
    console.error('Error showing interstitial ad:', error);
  });
}

// Setup click handlers for showing interstitial ads
function setupAdClickHandlers() {
  // List of buttons that should trigger interstitial ads
  const adTriggerButtons = [
    '.track-price-btn',  // Track price buttons
    '#scanForDiseaseBtn',  // Scan for disease button
    '#getWeatherBtn',     // Get weather button
    '#applyFilterBtn',    // Apply filter button for market prices
    '#btnGenerateGuidance', // Generate guidance button
    '.card-link'          // Various card links throughout the app
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
  
  // Places to insert banner ad containers
  const adLocations = [
    { selector: '#dashboardSection .row', position: 'afterend' },
    { selector: '#marketPricesSection .container', position: 'afterbegin' },
    { selector: '#diseaseDetectionSection .container', position: 'beforeend' },
    { selector: '#farmGuidanceSection .container', position: 'afterend' },
    { selector: '#settingsSection .container', position: 'afterbegin' }
  ];
  
  adLocations.forEach((location, index) => {
    const targetElement = document.querySelector(location.selector);
    if (!targetElement) return;
    
    const adContainer = document.createElement('div');
    adContainer.className = 'ad-banner-container';
    adContainer.id = `ad-container-${index}`;
    adContainer.style.cssText = 'width: 100%; height: 50px; margin: 15px 0; text-align: center; background-color: #f8f9fa; padding: 5px; border-radius: 5px;';
    adContainer.innerHTML = '<p class="ad-placeholder">Advertisement</p>';
    
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

// Expose functions globally
window.adManager = {
  showInterstitial: showInterstitialAd,
  refreshHandlers: refreshAdClickHandlers,
  createAdContainers: createAdContainers
};

// Create ad containers when page loads
document.addEventListener('DOMContentLoaded', createAdContainers);