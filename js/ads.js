// AdMob implementation for FarmAssistAI web version
// This will connect with the Flutter AdMob implementation later

/**
 * Ad Manager for handling all ad-related functionality
 * - Controls ad loading, display, and frequency
 * - Manages premium status to hide ads for subscribers
 * - Implements frequency capping for better user experience
 */
class AdManager {
  constructor() {
    // Ad state
    this.isPremium = false;
    this.adsInitialized = false;
    this.consentGiven = false;
    
    // Banner ad elements
    this.topBannerContainer = null;
    this.bottomBannerContainer = null;
    
    // Frequency capping
    this.pageViewCount = 0;
    this.interstitialShownTimestamp = 0;
    this.minSecondsBetweenInterstitials = 60; // 1 minute minimum
    this.minPagesBetweenInterstitials = 3;
    this.actionCount = 0;
    
    // Load saved preferences
    this._loadPreferences();
    
    // Initialize ads if not premium
    if (!this.isPremium) {
      this._initializeAds();
    }
  }
  
  /**
   * Initialize the ad system
   * @private
   */
  _initializeAds() {
    // In a real implementation, this would initialize the AdMob SDK
    console.log("Initializing AdMob...");
    
    // Create banner containers if they don't exist
    this._createBannerContainers();
    
    // Show GDPR consent dialog if needed
    if (!this.consentGiven) {
      this._showConsentDialog();
    } else {
      this._loadAds();
    }
    
    this.adsInitialized = true;
  }
  
  /**
   * Load ad preferences from localStorage
   * @private
   */
  _loadPreferences() {
    try {
      this.isPremium = localStorage.getItem('isPremium') === 'true';
      this.consentGiven = localStorage.getItem('adConsentGiven') === 'true';
      this.pageViewCount = parseInt(localStorage.getItem('pageViewCount') || '0');
      this.actionCount = parseInt(localStorage.getItem('actionCount') || '0');
    } catch (e) {
      console.error("Error loading ad preferences:", e);
      // Default to non-premium, requiring consent
      this.isPremium = false;
      this.consentGiven = false;
      this.pageViewCount = 0;
      this.actionCount = 0;
    }
  }
  
  /**
   * Save preferences to localStorage
   * @private
   */
  _savePreferences() {
    try {
      localStorage.setItem('isPremium', this.isPremium);
      localStorage.setItem('adConsentGiven', this.consentGiven);
      localStorage.setItem('pageViewCount', this.pageViewCount);
      localStorage.setItem('actionCount', this.actionCount);
    } catch (e) {
      console.error("Error saving ad preferences:", e);
    }
  }
  
  /**
   * Create banner containers for top and bottom banners
   * @private
   */
  _createBannerContainers() {
    // Create top banner container if it doesn't exist
    if (!document.getElementById('top-banner-container')) {
      const topContainer = document.createElement('div');
      topContainer.id = 'top-banner-container';
      topContainer.className = 'ad-banner-container top';
      topContainer.style.display = 'none'; // Hidden initially
      
      // Insert at the top of the main content area
      const mainContent = document.getElementById('main-content');
      if (mainContent) {
        mainContent.insertBefore(topContainer, mainContent.firstChild);
      } else {
        document.body.insertBefore(topContainer, document.body.firstChild);
      }
      
      this.topBannerContainer = topContainer;
    } else {
      this.topBannerContainer = document.getElementById('top-banner-container');
    }
    
    // Create bottom banner container if it doesn't exist
    if (!document.getElementById('bottom-banner-container')) {
      const bottomContainer = document.createElement('div');
      bottomContainer.id = 'bottom-banner-container';
      bottomContainer.className = 'ad-banner-container bottom';
      bottomContainer.style.display = 'none'; // Hidden initially
      
      // Insert before the footer
      const footer = document.querySelector('footer');
      if (footer) {
        document.body.insertBefore(bottomContainer, footer);
      } else {
        document.body.appendChild(bottomContainer);
      }
      
      this.bottomBannerContainer = bottomContainer;
    } else {
      this.bottomBannerContainer = document.getElementById('bottom-banner-container');
    }
    
    // Add styles for ad containers
    this._addAdStyles();
  }
  
  /**
   * Add CSS styles for ad containers
   * @private
   */
  _addAdStyles() {
    if (!document.getElementById('ad-styles')) {
      const style = document.createElement('style');
      style.id = 'ad-styles';
      style.textContent = `
        .ad-banner-container {
          width: 100%;
          height: 90px;
          background-color: #f0f0f0;
          display: flex;
          justify-content: center;
          align-items: center;
          overflow: hidden;
          position: relative;
        }
        .ad-banner-container.top {
          margin-bottom: 10px;
        }
        .ad-banner-container.bottom {
          margin-top: 10px;
        }
        .ad-banner-container::before {
          content: 'विज्ञापन';
          position: absolute;
          top: 2px;
          right: 5px;
          font-size: 10px;
          background-color: #ffd700;
          color: #333;
          padding: 1px 4px;
          border-radius: 3px;
        }
        .ad-banner {
          width: 100%;
          height: 100%;
          display: flex;
          cursor: pointer;
        }
        .ad-content {
          display: flex;
          width: 100%;
          align-items: center;
        }
        .ad-icon {
          width: 50px;
          height: 50px;
          margin: 0 15px;
          display: flex;
          justify-content: center;
          align-items: center;
          background-color: rgba(0,128,0,0.1);
          border-radius: 8px;
        }
        .ad-text {
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: center;
        }
        .ad-title {
          font-weight: bold;
          font-size: 14px;
          margin-bottom: 4px;
        }
        .ad-description {
          font-size: 12px;
          color: #666;
        }
        .ad-cta {
          margin: 0 15px;
          padding: 5px 10px;
          background-color: #1b5e20;
          color: white;
          border-radius: 4px;
          font-size: 12px;
          height: fit-content;
          align-self: center;
        }
        .interstitial-overlay {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(0,0,0,0.7);
          z-index: 9999;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .interstitial-container {
          width: 90%;
          max-width: 400px;
          background-color: white;
          border-radius: 10px;
          overflow: hidden;
          position: relative;
        }
        .interstitial-close {
          position: absolute;
          top: 5px;
          right: 5px;
          width: 30px;
          height: 30px;
          background-color: rgba(0,0,0,0.3);
          color: white;
          border-radius: 15px;
          display: flex;
          justify-content: center;
          align-items: center;
          cursor: pointer;
          z-index: 1;
        }
        .interstitial-header {
          background-color: #ffd700;
          padding: 10px;
          display: flex;
          justify-content: space-between;
        }
        .interstitial-ad-label {
          font-size: 12px;
          font-weight: bold;
          color: #333;
        }
        .interstitial-app-name {
          font-size: 12px;
          color: #333;
        }
        .interstitial-banner {
          height: 200px;
          background-color: rgba(0,128,0,0.1);
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }
        .interstitial-icon {
          font-size: 60px;
          color: #1b5e20;
          margin-bottom: 10px;
        }
        .interstitial-title {
          font-size: 18px;
          font-weight: bold;
          text-align: center;
          margin-bottom: 5px;
        }
        .interstitial-subtitle {
          font-size: 14px;
          text-align: center;
        }
        .interstitial-content {
          padding: 15px;
        }
        .interstitial-content-title {
          font-size: 16px;
          font-weight: bold;
          margin-bottom: 8px;
        }
        .interstitial-content-text {
          font-size: 14px;
          margin-bottom: 15px;
        }
        .interstitial-cta {
          background-color: #ff9800;
          color: white;
          border: none;
          border-radius: 5px;
          padding: 10px;
          width: 100%;
          font-size: 16px;
          font-weight: bold;
          cursor: pointer;
          margin-top: 10px;
        }
        .rewarded-ad-overlay {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(0,0,0,0.7);
          z-index: 9999;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .rewarded-ad-container {
          width: 90%;
          max-width: 400px;
          background-color: white;
          border-radius: 10px;
          overflow: hidden;
          position: relative;
        }
        .rewarded-ad-close {
          position: absolute;
          top: 5px;
          right: 5px;
          width: 30px;
          height: 30px;
          background-color: rgba(0,0,0,0.3);
          color: white;
          border-radius: 15px;
          display: flex;
          justify-content: center;
          align-items: center;
          cursor: pointer;
          z-index: 1;
        }
        .rewarded-ad-header {
          background-color: #9c27b0;
          padding: 10px;
          display: flex;
          justify-content: space-between;
        }
        .rewarded-ad-label {
          font-size: 12px;
          font-weight: bold;
          color: white;
        }
        .rewarded-ad-app-name {
          font-size: 12px;
          color: white;
        }
        .rewarded-message {
          background-color: rgba(156,39,176,0.1);
          padding: 10px;
          display: flex;
          align-items: center;
        }
        .rewarded-message-icon {
          font-size: 20px;
          color: #9c27b0;
          margin-right: 10px;
        }
        .rewarded-message-text {
          flex: 1;
          font-size: 14px;
          font-weight: bold;
        }
        .rewarded-ad-countdown {
          position: absolute;
          left: 10px;
          bottom: 10px;
          background-color: rgba(0,0,0,0.7);
          color: white;
          padding: 5px 10px;
          border-radius: 4px;
          font-size: 14px;
        }
        .rewarded-ad-cta {
          background-color: #9c27b0;
          color: white;
          border: none;
          border-radius: 5px;
          padding: 10px;
          width: 100%;
          font-size: 16px;
          font-weight: bold;
          cursor: pointer;
          margin-top: 10px;
        }
        .native-ad-container {
          margin: 15px 0;
          padding: 10px;
          background-color: white;
          border-radius: 10px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          position: relative;
        }
        .native-ad-label {
          position: absolute;
          top: 0;
          left: 0;
          background-color: #ffd700;
          color: #333;
          font-size: 10px;
          padding: 2px 6px;
          border-top-left-radius: 10px;
        }
        .native-ad-content {
          display: flex;
          padding-top: 15px;
        }
        .native-ad-icon {
          width: 60px;
          height: 60px;
          margin-right: 10px;
          background-color: rgba(0,128,0,0.1);
          border-radius: 8px;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .native-ad-text {
          flex: 1;
        }
        .native-ad-title {
          font-weight: bold;
          font-size: 14px;
          margin-bottom: 4px;
        }
        .native-ad-desc {
          font-size: 12px;
          color: #666;
          margin-bottom: 8px;
        }
        .native-ad-price {
          font-size: 12px;
          color: #1b5e20;
          font-weight: bold;
        }
        .native-ad-cta {
          background-color: #1b5e20;
          color: white;
          border: none;
          border-radius: 4px;
          padding: 8px 12px;
          font-size: 12px;
          cursor: pointer;
          margin-top: 10px;
          float: right;
        }
        .consent-dialog {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-color: rgba(0,0,0,0.7);
          z-index: 10000;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .consent-container {
          width: 90%;
          max-width: 500px;
          background-color: white;
          border-radius: 10px;
          padding: 20px;
          box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
        .consent-title {
          font-size: 20px;
          font-weight: bold;
          margin-bottom: 15px;
          text-align: center;
        }
        .consent-content {
          font-size: 14px;
          margin-bottom: 20px;
          text-align: center;
        }
        .consent-points {
          margin-bottom: 20px;
        }
        .consent-point {
          display: flex;
          margin-bottom: 8px;
        }
        .consent-point-bullet {
          margin-right: 8px;
          font-weight: bold;
        }
        .consent-point-text {
          flex: 1;
        }
        .consent-buttons {
          display: flex;
          flex-direction: column;
        }
        .consent-accept {
          background-color: #1b5e20;
          color: white;
          border: none;
          border-radius: 5px;
          padding: 10px;
          font-size: 16px;
          font-weight: bold;
          cursor: pointer;
          margin-bottom: 10px;
        }
        .consent-decline {
          background-color: transparent;
          color: #666;
          border: none;
          padding: 10px;
          font-size: 14px;
          cursor: pointer;
          margin-bottom: 10px;
        }
        .consent-policy {
          text-align: center;
          font-size: 12px;
          color: #666;
          text-decoration: underline;
          cursor: pointer;
        }
      `;
      document.head.appendChild(style);
    }
  }
  
  /**
   * Show consent dialog for GDPR compliance
   * @private
   */
  _showConsentDialog() {
    const dialog = document.createElement('div');
    dialog.className = 'consent-dialog';
    dialog.innerHTML = `
      <div class="consent-container">
        <div class="consent-title">विज्ञापन और गोपनीयता सहमति</div>
        <div class="consent-content">
          FarmAssist AI आपको बिना किसी शुल्क के महत्वपूर्ण खेती से संबंधित जानकारी उपलब्ध कराती है। इसे संभव बनाने के लिए, हम आपको प्रासंगिक विज्ञापन दिखाते हैं।
          <br><br>
          हम निम्नलिखित के लिए आपकी सहमति मांगते हैं:
        </div>
        <div class="consent-points">
          <div class="consent-point">
            <div class="consent-point-bullet">•</div>
            <div class="consent-point-text">व्यक्तिगत विज्ञापन दिखाएँ</div>
          </div>
          <div class="consent-point">
            <div class="consent-point-bullet">•</div>
            <div class="consent-point-text">आपकी ऐप इंटरैक्शन जानकारी एकत्र करें</div>
          </div>
          <div class="consent-point">
            <div class="consent-point-bullet">•</div>
            <div class="consent-point-text">एप्लिकेशन उपयोग डेटा सहेजें</div>
          </div>
        </div>
        <div class="consent-buttons">
          <button class="consent-accept" id="consent-accept">सहमत हूँ</button>
          <button class="consent-decline" id="consent-decline">अस्वीकार करें</button>
          <div class="consent-policy" id="consent-policy">गोपनीयता नीति देखें</div>
        </div>
      </div>
    `;
    
    document.body.appendChild(dialog);
    
    // Add event listeners
    document.getElementById('consent-accept').addEventListener('click', () => {
      this.consentGiven = true;
      this._savePreferences();
      document.body.removeChild(dialog);
      this._loadAds();
    });
    
    document.getElementById('consent-decline').addEventListener('click', () => {
      this.consentGiven = false;
      this._savePreferences();
      document.body.removeChild(dialog);
      // Still load ads but non-personalized
      this._loadAds(false);
    });
    
    document.getElementById('consent-policy').addEventListener('click', () => {
      this._showPrivacyPolicy();
    });
  }
  
  /**
   * Show privacy policy
   * @private
   */
  _showPrivacyPolicy() {
    alert('गोपनीयता नीति यहां दिखाई जाएगी');
  }
  
  /**
   * Load ads after initialization
   * @param {boolean} personalized Whether to load personalized ads
   * @private
   */
  _loadAds(personalized = true) {
    if (this.isPremium) return;
    
    // For demo purposes, we'll just show demo ads
    this._showBannerAds();
    console.log(`Loading ${personalized ? 'personalized' : 'non-personalized'} ads...`);
  }
  
  /**
   * Show banner ads
   * @private
   */
  _showBannerAds() {
    if (this.isPremium) return;
    
    // Show top banner if needed
    if (this.topBannerContainer) {
      this.topBannerContainer.style.display = 'flex';
      this.topBannerContainer.innerHTML = this._getTestBannerHtml('खेती उपकरणों पर विशेष छूट!', 'अभी देखें');
      this._addBannerClickHandler(this.topBannerContainer);
    }
    
    // Show bottom banner if needed
    if (this.bottomBannerContainer) {
      this.bottomBannerContainer.style.display = 'flex';
      this.bottomBannerContainer.innerHTML = this._getTestBannerHtml('फ़सल बीमा - अपनी फसल सुरक्षित करें', 'और जानें');
      this._addBannerClickHandler(this.bottomBannerContainer);
    }
  }
  
  /**
   * Get HTML for a test banner ad
   * @param {string} title Ad title
   * @param {string} ctaText Call-to-action text
   * @returns {string} HTML string
   * @private
   */
  _getTestBannerHtml(title, ctaText) {
    return `
      <div class="ad-banner">
        <div class="ad-content">
          <div class="ad-icon">
            <i class="fas fa-tractor" style="color: #1b5e20; font-size: 24px;"></i>
          </div>
          <div class="ad-text">
            <div class="ad-title">${title}</div>
            <div class="ad-description">अपनी कृषि उत्पादकता बढ़ाएँ</div>
          </div>
          <div class="ad-cta">${ctaText}</div>
        </div>
      </div>
    `;
  }
  
  /**
   * Add click handler to banner ad
   * @param {HTMLElement} bannerContainer The banner container element
   * @private
   */
  _addBannerClickHandler(bannerContainer) {
    const banner = bannerContainer.querySelector('.ad-banner');
    if (banner) {
      banner.addEventListener('click', () => {
        alert('बैनर विज्ञापन पर क्लिक किया गया');
      });
    }
  }
  
  /**
   * Show an interstitial ad
   * @param {function} onClosed Callback when ad is closed
   * @param {function} onClicked Callback when ad is clicked
   * @returns {boolean} Whether ad was shown
   */
  showInterstitialAd(onClosed, onClicked) {
    if (this.isPremium) return false;
    
    // Check frequency capping
    const now = Date.now();
    const timeSinceLastInterstitial = (now - this.interstitialShownTimestamp) / 1000;
    
    if (this.pageViewCount < this.minPagesBetweenInterstitials || 
        timeSinceLastInterstitial < this.minSecondsBetweenInterstitials) {
      console.log("Interstitial frequency cap hit, not showing ad");
      return false;
    }
    
    // Create and display the interstitial
    const overlay = document.createElement('div');
    overlay.className = 'interstitial-overlay';
    overlay.innerHTML = `
      <div class="interstitial-container">
        <div class="interstitial-close">&times;</div>
        <div class="interstitial-header">
          <div class="interstitial-ad-label">विज्ञापन</div>
          <div class="interstitial-app-name">FarmAssist AI</div>
        </div>
        <div class="interstitial-banner">
          <div class="interstitial-icon"><i class="fas fa-tractor"></i></div>
          <div class="interstitial-title">उन्नत कृषि उपकरण</div>
          <div class="interstitial-subtitle">कम कीमत, उच्च उत्पादकता</div>
        </div>
        <div class="interstitial-content">
          <div class="interstitial-content-title">किसानों के लिए विशेष ऑफर</div>
          <div class="interstitial-content-text">
            हमारे उन्नत कृषि उपकरणों से अपनी खेती को आधुनिक बनाएं। 
            अभी खरीदारी करें और 20% की छूट प्राप्त करें!
          </div>
          <button class="interstitial-cta">अभी खरीदें</button>
        </div>
      </div>
    `;
    
    document.body.appendChild(overlay);
    
    // Update state
    this.interstitialShownTimestamp = now;
    this.pageViewCount = 0;
    this._savePreferences();
    
    // Add event listeners
    const closeButton = overlay.querySelector('.interstitial-close');
    closeButton.addEventListener('click', () => {
      document.body.removeChild(overlay);
      if (onClosed) onClosed();
    });
    
    const ctaButton = overlay.querySelector('.interstitial-cta');
    ctaButton.addEventListener('click', () => {
      document.body.removeChild(overlay);
      if (onClicked) onClicked();
    });
    
    return true;
  }
  
  /**
   * Show a rewarded ad
   * @param {function} onRewarded Callback when user earns reward
   * @param {function} onClosed Callback when ad is closed
   * @returns {boolean} Whether ad was shown
   */
  showRewardedAd(onRewarded, onClosed) {
    if (this.isPremium) return false;
    
    // Create and display the rewarded ad
    const overlay = document.createElement('div');
    overlay.className = 'rewarded-ad-overlay';
    overlay.innerHTML = `
      <div class="rewarded-ad-container">
        <div class="rewarded-ad-close">&times;</div>
        <div class="rewarded-ad-header">
          <div class="rewarded-ad-label">रिवॉर्ड विज्ञापन</div>
          <div class="rewarded-ad-app-name">FarmAssist AI</div>
        </div>
        <div class="rewarded-message">
          <div class="rewarded-message-icon"><i class="fas fa-gift"></i></div>
          <div class="rewarded-message-text">इस विज्ञापन को पूरा देखें और प्रीमियम सुविधा अनलॉक करें!</div>
        </div>
        <div class="interstitial-banner">
          <div class="interstitial-icon" style="color: #2196f3;"><i class="fas fa-water"></i></div>
          <div class="interstitial-title">स्मार्ट सिंचाई समाधान</div>
          <div class="interstitial-subtitle">पानी बचाएं, फसल बढ़ाएं</div>
        </div>
        <div class="interstitial-content">
          <div class="interstitial-content-title">डिजिटल सिंचाई प्रणाली</div>
          <div class="interstitial-content-text">
            हमारी स्मार्ट सिंचाई प्रणाली से 40% तक पानी बचाएं और फसल उत्पादन में 25% की वृद्धि करें। 
            एक्सपर्ट द्वारा स्थापना मुफ्त!
          </div>
          <div class="rewarded-ad-countdown">0:05</div>
          <button class="rewarded-ad-cta" disabled>रिवॉर्ड पाएं</button>
        </div>
      </div>
    `;
    
    document.body.appendChild(overlay);
    
    // Simulate ad countdown
    const countdownEl = overlay.querySelector('.rewarded-ad-countdown');
    const ctaButton = overlay.querySelector('.rewarded-ad-cta');
    let countdown = 5;
    
    const timer = setInterval(() => {
      countdown--;
      countdownEl.textContent = `0:0${countdown}`;
      
      if (countdown <= 0) {
        clearInterval(timer);
        countdownEl.style.display = 'none';
        ctaButton.disabled = false;
      }
    }, 1000);
    
    // Add event listeners
    const closeButton = overlay.querySelector('.rewarded-ad-close');
    closeButton.addEventListener('click', () => {
      clearInterval(timer);
      document.body.removeChild(overlay);
      if (onClosed) onClosed();
    });
    
    ctaButton.addEventListener('click', () => {
      clearInterval(timer);
      document.body.removeChild(overlay);
      if (onRewarded) onRewarded();
    });
    
    return true;
  }
  
  /**
   * Insert a native ad into a container
   * @param {string} containerId ID of container to insert ad into
   * @param {function} onClicked Callback when ad is clicked
   * @returns {boolean} Whether ad was inserted
   */
  insertNativeAd(containerId, onClicked) {
    if (this.isPremium) return false;
    
    const container = document.getElementById(containerId);
    if (!container) return false;
    
    const nativeAd = document.createElement('div');
    nativeAd.className = 'native-ad-container';
    nativeAd.innerHTML = `
      <div class="native-ad-label">विज्ञापन</div>
      <div class="native-ad-content">
        <div class="native-ad-icon">
          <i class="fas fa-seedling" style="color: #1b5e20; font-size: 30px;"></i>
        </div>
        <div class="native-ad-text">
          <div class="native-ad-title">जैविक खाद - फसल का सुपरफूड</div>
          <div class="native-ad-desc">हमारी प्रमाणित जैविक खाद से फसल की गुणवत्ता और मात्रा में वृद्धि करें</div>
          <div class="native-ad-price">₹800/बोरी - अभी ऑर्डर करें</div>
        </div>
      </div>
      <button class="native-ad-cta">अधिक जानकारी</button>
      <div style="clear: both;"></div>
    `;
    
    container.appendChild(nativeAd);
    
    // Add click handler
    const ctaButton = nativeAd.querySelector('.native-ad-cta');
    ctaButton.addEventListener('click', () => {
      if (onClicked) onClicked();
    });
    
    return true;
  }
  
  /**
   * Track a page view for frequency capping
   */
  trackPageView() {
    this.pageViewCount++;
    this._savePreferences();
  }
  
  /**
   * Track a user action for frequency capping
   */
  trackAction() {
    this.actionCount++;
    this._savePreferences();
  }
  
  /**
   * Set premium status
   * @param {boolean} isPremium Whether user has premium status
   */
  setPremiumStatus(isPremium) {
    this.isPremium = isPremium;
    this._savePreferences();
    
    // Hide ads if premium
    if (isPremium) {
      this._hideAllAds();
    } else {
      // Reinitialize ads if needed
      if (!this.adsInitialized) {
        this._initializeAds();
      } else {
        this._showBannerAds();
      }
    }
  }
  
  /**
   * Hide all ads
   * @private
   */
  _hideAllAds() {
    // Hide banner containers
    if (this.topBannerContainer) {
      this.topBannerContainer.style.display = 'none';
    }
    
    if (this.bottomBannerContainer) {
      this.bottomBannerContainer.style.display = 'none';
    }
    
    // Remove any native ads
    document.querySelectorAll('.native-ad-container').forEach(ad => {
      ad.remove();
    });
  }
}

// Initialize ad manager
let adManager;
document.addEventListener('DOMContentLoaded', () => {
  adManager = new AdManager();
  
  // Add to window for access from other scripts
  window.adManager = adManager;
  
  // Track initial page view
  adManager.trackPageView();
  
  // Add example event listeners
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      // Track page view when tab becomes active again
      adManager.trackPageView();
    }
  });
  
  // Add interstitial triggers
  document.querySelectorAll('[data-show-interstitial]').forEach(el => {
    el.addEventListener('click', (e) => {
      adManager.showInterstitialAd(
        () => console.log('Interstitial closed'),
        () => console.log('Interstitial clicked')
      );
    });
  });
  
  // Add rewarded ad triggers
  document.querySelectorAll('[data-show-rewarded]').forEach(el => {
    el.addEventListener('click', (e) => {
      adManager.showRewardedAd(
        () => {
          console.log('Reward earned');
          alert('आपको रिवॉर्ड मिल गया है!');
        },
        () => console.log('Rewarded ad closed without reward')
      );
    });
  });
});

// Export the AdManager class
export default AdManager;