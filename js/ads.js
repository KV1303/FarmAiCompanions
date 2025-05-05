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
  
  console.log('Trying to initialize AdMob...');
  
  // For web testing, ensure we show ads in all environments by attempting to load
  // the Cordova AdMob plugin or falling back to web placeholders
  
  // First, check if we're in a compiled app with AdMob plugin
  if (window.cordova && typeof admob !== 'undefined') {
    console.log('Native AdMob plugin detected');
    adMobAvailable = true;
    
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
  } 
  // Alternative approach: Try loading web-based AdMob implementation
  else if (window.googletag || typeof googletag !== 'undefined') {
    console.log('Web AdMob/Google Publisher Tags detected');
    adMobAvailable = true;
    initializeWebAds();
  }
  // If no AdMob implementation is available, show placeholders
  else {
    console.log('No AdMob implementation available, using Hindi placeholders');
    adMobAvailable = false;
    showPlaceholderAds();
  }
}

// Initialize web-based ads using Google Publisher Tags
function initializeWebAds() {
  console.log('Initializing web-based ads');
  
  // Only initialize once
  if (isAdMobInitialized) return;
  
  try {
    // Create script tag for Google Publisher Tags if it doesn't exist
    if (!document.getElementById('gpt-script')) {
      const gptScript = document.createElement('script');
      gptScript.id = 'gpt-script';
      gptScript.async = true;
      gptScript.src = 'https://securepubads.g.doubleclick.net/tag/js/gpt.js';
      document.head.appendChild(gptScript);
      
      gptScript.onload = function() {
        console.log('Google Publisher Tags loaded');
        defineAdSlots();
      };
    } else {
      defineAdSlots();
    }
    
    isAdMobInitialized = true;
  } catch (error) {
    console.error('Error initializing web ads:', error);
    showPlaceholderAds();
  }
}

// Define ad slots for Google Publisher Tags
function defineAdSlots() {
  try {
    window.googletag = window.googletag || {cmd: []};
    googletag.cmd.push(function() {
      console.log('Defining ad slots');
      
      // Convert banner ad containers to GPT ad slots
      document.querySelectorAll('.ad-banner-container').forEach((container, index) => {
        const slotId = container.id || `ad-container-${index}`;
        console.log(`Creating GPT ad slot for ${slotId}`);
        
        // Clear placeholder text
        const placeholder = container.querySelector('.ad-placeholder');
        if (placeholder) placeholder.style.display = 'none';
        
        // Define the ad slot
        const adSlot = googletag.defineSlot(
          AD_UNITS.BANNER,
          [[320, 50], [300, 50], [300, 250]],
          slotId
        )
        .addService(googletag.pubads());
        
        // Display the ad
        googletag.display(slotId);
      });
      
      // Enable features
      googletag.pubads().enableSingleRequest();
      googletag.enableServices();
    });
  } catch (error) {
    console.error('Error defining ad slots:', error);
  }
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
  // Always respect the cooldown regardless of implementation
  const now = Date.now();
  if (now - lastInterstitialShownTime < INTERSTITIAL_COOLDOWN) {
    console.log('Interstitial ad on cooldown, skipping');
    return;
  }
  
  // Record this attempt regardless of success
  lastInterstitialShownTime = now;
  
  // If AdMob isn't available or initialized, try web based ads instead
  if (!adMobAvailable || !isAdMobInitialized) {
    console.log('Native AdMob not available, trying web-based interstitial');
    showWebInterstitialAd();
    return;
  }
  
  // For native AdMob implementation
  if (window.cordova && typeof admob !== 'undefined') {
    // If an interstitial ad isn't loaded yet, skip showing
    if (!interstitialAdLoaded) {
      console.log('Interstitial ad not ready to show');
      return;
    }
    
    console.log('Showing native interstitial ad...');
    
    // Show the interstitial ad
    admob.showInterstitial().then(() => {
      console.log('Interstitial ad shown successfully');
      interstitialAdLoaded = false;
      
      // Preload the next interstitial
      setTimeout(preloadInterstitial, 1000);
    }).catch(error => {
      console.error('Error showing interstitial ad:', error);
      // Try web-based ad as fallback
      showWebInterstitialAd();
    });
  } else {
    // For non-native environment, try web interstitial
    showWebInterstitialAd();
  }
}

// Show web-based interstitial ad using Google Publisher Tags
function showWebInterstitialAd() {
  console.log('Attempting to show web interstitial ad');
  
  // If Google Publisher Tags is available
  if (window.googletag) {
    try {
      // Create a div for the interstitial
      const interstitialDiv = document.createElement('div');
      interstitialDiv.id = 'interstitial-ad-div';
      interstitialDiv.style.cssText = 'position: fixed; top: 0; left: 0; width: 100%; height: 100%; z-index: 9999; background-color: rgba(0,0,0,0.8); display: flex; justify-content: center; align-items: center;';
      
      // Create a container for the ad content
      const adContainer = document.createElement('div');
      adContainer.style.cssText = 'width: 300px; height: 250px; background-color: #fff; position: relative; padding: 10px;';
      adContainer.id = 'interstitial-ad-container';
      
      // Add a close button
      const closeButton = document.createElement('button');
      closeButton.textContent = 'X';
      closeButton.style.cssText = 'position: absolute; top: 5px; right: 5px; cursor: pointer; background: red; color: white; border: none; border-radius: 50%; width: 25px; height: 25px;';
      closeButton.onclick = function() {
        document.body.removeChild(interstitialDiv);
      };
      
      adContainer.appendChild(closeButton);
      interstitialDiv.appendChild(adContainer);
      document.body.appendChild(interstitialDiv);
      
      // Load an ad into the container
      googletag.cmd.push(function() {
        const slot = googletag.defineSlot(
          AD_UNITS.INTERSTITIAL,
          [[300, 250]],
          'interstitial-ad-container'
        )
        .addService(googletag.pubads());
        
        googletag.pubads().refresh([slot]);
        googletag.display('interstitial-ad-container');
        
        // Auto-close after 10 seconds if user doesn't close it
        setTimeout(function() {
          if (document.getElementById('interstitial-ad-div')) {
            document.body.removeChild(interstitialDiv);
          }
        }, 10000);
      });
      
      console.log('Web interstitial ad displayed');
    } catch (error) {
      console.error('Error showing web interstitial:', error);
      // Clean up if error occurs
      const existingInterstitial = document.getElementById('interstitial-ad-div');
      if (existingInterstitial) {
        document.body.removeChild(existingInterstitial);
      }
    }
  } else {
    console.log('Google Publisher Tags not available for interstitial');
  }
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