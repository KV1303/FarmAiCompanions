// FarmAssist AI - Main JavaScript File

// Utility functions
function showSection(sectionId) {
  // Hide all sections
  document.querySelectorAll('main section').forEach(section => {
    section.classList.add('hidden');
  });
  
  // Show the requested section
  const section = document.getElementById(sectionId);
  if (section) {
    section.classList.remove('hidden');
  }
}

function showError(elementId, message) {
  const errorElement = document.getElementById(elementId);
  errorElement.textContent = message;
  errorElement.classList.remove('hidden');
  
  // Auto-hide after 5 seconds
  setTimeout(() => {
    errorElement.classList.add('hidden');
  }, 5000);
}

// API functions
async function fetchAPI(endpoint, method = 'GET', data = null, retries = 3) {
  const url = `/api/${endpoint}`;
  const options = {
    method: method,
    headers: {
      'Content-Type': 'application/json'
    }
  };
  
  if (data && (method === 'POST' || method === 'PUT')) {
    options.body = JSON.stringify(data);
  }
  
  try {
    console.log(`Sending ${method} request to ${url}`, data);
    const response = await fetch(url, options);
    if (!response.ok) {
      const errorData = await response.json();
      throw new Error(errorData.error || `API request failed with status ${response.status}`);
    }
    const responseData = await response.json();
    console.log(`Response from ${url}:`, responseData);
    return responseData;
  } catch (error) {
    console.error(`API Error (${endpoint}):`, error);
    
    // Implement retry logic for GET requests or when we have network errors
    if (retries > 0 && (method === 'GET' || error.message.includes('Failed to fetch'))) {
      console.log(`Retrying ${endpoint} (${retries} attempts left)...`);
      // Wait for a short time before retrying (exponential backoff)
      const delay = (3 - retries + 1) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
      return fetchAPI(endpoint, method, data, retries - 1);
    }
    
    throw error;
  }
}

// Authentication functions
function isLoggedIn() {
  return localStorage.getItem('user_id') !== null;
}

function getCurrentUserId() {
  return localStorage.getItem('user_id');
}

function login(userId, username) {
  localStorage.setItem('user_id', userId);
  localStorage.setItem('username', username);
  updateAuthUI();
}

function logout() {
  localStorage.removeItem('user_id');
  localStorage.removeItem('username');
  updateAuthUI();
  showSection('homeSection');
}

function updateAuthUI() {
  const isAuthenticated = isLoggedIn();
  
  // Update navbar
  document.getElementById('loginNav').classList.toggle('hidden', isAuthenticated);
  document.getElementById('registerNav').classList.toggle('hidden', isAuthenticated);
  document.getElementById('logoutBtn').classList.toggle('hidden', !isAuthenticated);
  
  // Enable/disable protected sections
  document.getElementById('dashboardNav').classList.toggle('disabled', !isAuthenticated);
}

// Weather functions
async function loadWeather(location = 'New Delhi') {
  try {
    const weatherData = await fetchAPI(`weather?location=${encodeURIComponent(location)}`);
    displayWeather(weatherData);
  } catch (error) {
    document.getElementById('currentWeather').innerHTML = `
      <div class="alert alert-danger">
        Failed to load weather data: ${error.message}
      </div>
    `;
    document.getElementById('forecast').innerHTML = '';
    document.getElementById('weatherRecommendations').innerHTML = 
      '<p>Weather recommendations unavailable.</p>';
  }
}

function displayWeather(data) {
  if (!data || !data.forecasts || data.forecasts.length === 0) {
    document.getElementById('currentWeather').innerHTML = 
      '<div class="alert alert-warning">No weather data available.</div>';
    return;
  }
  
  const today = data.forecasts[0];
  
  // Display current weather
  document.getElementById('currentWeather').innerHTML = `
    <div class="row">
      <div class="col-md-6">
        <h3>${data.location}</h3>
        <div class="d-flex align-items-center">
          <div class="weather-icon">
            <i class="fas fa-sun"></i> <!-- This would be dynamic based on weather -->
          </div>
          <div class="ms-3">
            <h2>${today.temp_max}°C</h2>
            <p>${today.description}</p>
          </div>
        </div>
      </div>
      <div class="col-md-6">
        <div class="row mt-3">
          <div class="col-6">
            <p><i class="fas fa-temperature-low"></i> Min: ${today.temp_min}°C</p>
            <p><i class="fas fa-tint"></i> Humidity: ${today.humidity}%</p>
          </div>
          <div class="col-6">
            <p><i class="fas fa-temperature-high"></i> Max: ${today.temp_max}°C</p>
            <p><i class="fas fa-wind"></i> Wind: ${today.wind_speed} km/h</p>
          </div>
        </div>
      </div>
    </div>
  `;
  
  // Display forecast
  let forecastHTML = '';
  data.forecasts.forEach((day, index) => {
    if (index === 0) return; // Skip today
    
    const date = new Date(day.date);
    const dayName = date.toLocaleDateString('en-US', { weekday: 'short' });
    
    forecastHTML += `
      <div class="col">
        <div class="forecast-day">
          <p><strong>${dayName}</strong></p>
          <i class="fas fa-sun"></i>
          <p>${day.temp_min}° - ${day.temp_max}°</p>
          <small>${day.description}</small>
        </div>
      </div>
    `;
  });
  
  document.getElementById('forecast').innerHTML = forecastHTML;
  
  // Generate recommendations
  generateWeatherRecommendations(data);
}

function generateWeatherRecommendations(data) {
  const today = data.forecasts[0];
  let recommendations = '<ul class="list-group">';
  
  // Temperature-based recommendations
  if (today.temp_max > 35) {
    recommendations += '<li class="list-group-item list-group-item-warning"><i class="fas fa-thermometer-full me-2"></i> Extreme heat: Ensure adequate irrigation and consider shade for sensitive crops.</li>';
  }
  
  // Precipitation-based recommendations
  const rainyDays = data.forecasts.filter(day => day.precipitation > 0.5).length;
  if (rainyDays > 2) {
    recommendations += '<li class="list-group-item list-group-item-info"><i class="fas fa-cloud-rain me-2"></i> Heavy rainfall expected: Check drainage systems and delay fertilizer application.</li>';
  } else if (data.forecasts.every(day => day.precipitation < 0.1)) {
    recommendations += '<li class="list-group-item list-group-item-warning"><i class="fas fa-tint-slash me-2"></i> Dry conditions expected: Consider increasing irrigation frequency.</li>';
  }
  
  // Wind-based recommendations
  if (data.forecasts.some(day => day.wind_speed > 20)) {
    recommendations += '<li class="list-group-item list-group-item-warning"><i class="fas fa-wind me-2"></i> Strong winds expected: Secure young plants and postpone pesticide spraying.</li>';
  }
  
  // General recommendations
  recommendations += '<li class="list-group-item"><i class="fas fa-calendar-check me-2"></i> Update your irrigation schedule based on the forecast.</li>';
  recommendations += '</ul>';
  
  document.getElementById('weatherRecommendations').innerHTML = recommendations;
}

// Market Prices functions
async function loadMarketPrices(cropType = '') {
  try {
    const query = cropType ? `crop_type=${encodeURIComponent(cropType)}` : '';
    const data = await fetchAPI(`market_prices?${query}`);
    displayMarketPrices(data.prices);
  } catch (error) {
    document.getElementById('marketPricesTable').innerHTML = `
      <tr>
        <td colspan="7" class="text-center">
          <div class="alert alert-danger">
            Failed to load market prices: ${error.message}
          </div>
        </td>
      </tr>
    `;
  }
}

function displayMarketPrices(prices) {
  if (!prices || prices.length === 0) {
    document.getElementById('marketPricesTable').innerHTML = `
      <tr>
        <td colspan="7" class="text-center">No market prices available</td>
      </tr>
    `;
    return;
  }
  
  // Get data source and date from the first price entry
  const dataSource = prices[0].source || 'Market Data';
  const updateDate = prices[0].date || new Date().toISOString().split('T')[0];
  
  // Update the data source info at the top of the table
  const sourceBadgeEl = document.getElementById('marketDataSource');
  if (sourceBadgeEl) {
    sourceBadgeEl.innerHTML = `
      <div class="d-flex justify-content-between align-items-center mb-2">
        <div>
          <span class="badge bg-info">Source: ${dataSource}</span>
          <span class="badge bg-secondary ms-2">Updated: ${updateDate}</span>
        </div>
        <button class="btn btn-sm btn-outline-primary refresh-prices-btn">
          <i class="fas fa-sync-alt"></i> Refresh
        </button>
      </div>
    `;
    
    // Add event listener to the refresh button
    setTimeout(() => {
      document.querySelector('.refresh-prices-btn')?.addEventListener('click', () => {
        const currentCropType = document.getElementById('cropFilter').value;
        loadMarketPrices(currentCropType);
      });
    }, 100);
  }
  
  let html = '';
  prices.forEach(price => {
    html += `
      <tr>
        <td>${price.crop_type}</td>
        <td>${price.market_name}</td>
        <td>₹${price.price.toFixed(2)}</td>
        <td>₹${price.min_price.toFixed(2)}</td>
        <td>₹${price.max_price.toFixed(2)}</td>
        <td>${price.date}</td>
        <td>
          <button class="btn btn-sm btn-primary track-price-btn" 
            data-crop="${price.crop_type}" 
            data-market="${price.market_name}">
            <i class="fas fa-bell"></i> Track
          </button>
        </td>
      </tr>
    `;
  });
  
  document.getElementById('marketPricesTable').innerHTML = html;
  
  // Add event listeners to track buttons
  document.querySelectorAll('.track-price-btn').forEach(btn => {
    btn.addEventListener('click', function() {
      if (!isLoggedIn()) {
        showSection('loginSection');
        return;
      }
      
      document.getElementById('alertCropType').value = this.dataset.crop;
      document.getElementById('alertMarket').value = this.dataset.market;
      document.getElementById('alertMinPrice').focus();
    });
  });
}

// Disease Detection
function setupDiseaseDetection() {
  const uploadArea = document.getElementById('uploadArea');
  const imageInput = document.getElementById('diseaseImageInput');
  const imagePreview = document.getElementById('imagePreview');
  const previewContainer = document.getElementById('imagePreviewContainer');
  const loadingIndicator = document.getElementById('loadingIndicator');
  const resultContainer = document.getElementById('resultContainer');
  const analyzeBtn = document.getElementById('analyzeImageBtn');
  const resetBtn = document.getElementById('resetImageBtn');
  
  // Setup upload area
  uploadArea.addEventListener('click', () => {
    imageInput.click();
  });
  
  uploadArea.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadArea.classList.add('border-primary');
  });
  
  uploadArea.addEventListener('dragleave', () => {
    uploadArea.classList.remove('border-primary');
  });
  
  uploadArea.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadArea.classList.remove('border-primary');
    
    if (e.dataTransfer.files.length) {
      handleImageFile(e.dataTransfer.files[0]);
    }
  });
  
  // Image input change
  imageInput.addEventListener('change', () => {
    if (imageInput.files.length) {
      handleImageFile(imageInput.files[0]);
    }
  });
  
  // Analyze button
  analyzeBtn.addEventListener('click', async () => {
    if (!imageInput.files.length) return;
    
    // Show loading indicator
    previewContainer.classList.add('hidden');
    loadingIndicator.classList.remove('hidden');
    resultContainer.classList.add('hidden');
    
    try {
      const result = await analyzeImage(imageInput.files[0]);
      displayDiseaseResult(result);
    } catch (error) {
      alert(`Error analyzing image: ${error.message}`);
    } finally {
      // Hide loading indicator
      loadingIndicator.classList.add('hidden');
      previewContainer.classList.remove('hidden');
    }
  });
  
  // Reset button
  resetBtn.addEventListener('click', () => {
    resetDiseaseDetection();
  });
  
  function handleImageFile(file) {
    if (!file.type.match('image.*')) {
      alert('Please select an image file');
      return;
    }
    
    // Display image preview
    const reader = new FileReader();
    reader.onload = (e) => {
      imagePreview.src = e.target.result;
      uploadArea.classList.add('hidden');
      previewContainer.classList.remove('hidden');
    };
    reader.readAsDataURL(file);
  }
  
  function resetDiseaseDetection() {
    imageInput.value = '';
    imagePreview.src = '';
    uploadArea.classList.remove('hidden');
    previewContainer.classList.add('hidden');
    resultContainer.classList.add('hidden');
  }
}

async function analyzeImage(imageFile) {
  // First, upload the image to the server
  try {
    const uploadFormData = new FormData();
    uploadFormData.append('image', imageFile);
    
    console.log("Uploading image file:", imageFile.name, imageFile.type, imageFile.size);
    
    const uploadResponse = await fetch('/upload', {
      method: 'POST',
      body: uploadFormData
    });
    
    if (!uploadResponse.ok) {
      const errorText = await uploadResponse.text();
      console.error("Upload failed:", errorText);
      throw new Error(`Upload failed: ${errorText}`);
    }
    
    const uploadResult = await uploadResponse.json();
    console.log("Upload successful:", uploadResult);
    
    // Now send the analysis request with the path to the uploaded image
    const analyzeFormData = new FormData();
    analyzeFormData.append('image_path', uploadResult.path);
    analyzeFormData.append('crop_type', document.getElementById('cropType')?.value || 'unknown');
    
    // Add user/field if logged in
    if (isLoggedIn()) {
      analyzeFormData.append('user_id', getCurrentUserId());
      // If we're in field context, add field_id
      const fieldId = localStorage.getItem('current_field_id');
      if (fieldId) {
        analyzeFormData.append('field_id', fieldId);
      }
    }
    
    // Send analysis request to API
    const analyzeResponse = await fetch('/api/disease_detect', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(Object.fromEntries(analyzeFormData))
    });
    
    if (!analyzeResponse.ok) {
      let errorMessage = 'Failed to analyze image';
      try {
        const errorData = await analyzeResponse.json();
        errorMessage = errorData.error || errorMessage;
      } catch (e) {
        // If response is not JSON
        errorMessage = await analyzeResponse.text() || errorMessage;
      }
      throw new Error(errorMessage);
    }
    
    return await analyzeResponse.json();
  } catch (error) {
    console.error("Disease detection error:", error);
    throw error;
  }
}

function displayDiseaseResult(result) {
  document.getElementById('diseaseResult').textContent = result.disease_name;
  
  // Update confidence bar
  const confidencePercent = Math.round(result.confidence * 100);
  document.getElementById('confidenceLevel').style.width = `${confidencePercent}%`;
  document.getElementById('confidenceText').textContent = `${confidencePercent}%`;
  
  // Update symptoms and treatment
  document.getElementById('symptomsText').textContent = result.symptoms || 'No symptoms information available';
  document.getElementById('treatmentText').textContent = result.treatment || 'No treatment information available';
  
  // Show result container
  document.getElementById('resultContainer').classList.remove('hidden');
  
  // Toggle save button based on login status
  document.getElementById('saveReportBtn').classList.toggle('hidden', !isLoggedIn());
}

// Field management
async function loadFields() {
  if (!isLoggedIn()) return;
  
  // Show loading indicator
  document.getElementById('fieldsList').innerHTML = `
    <li class="text-center py-4">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
      <p class="mt-2">Loading your fields...</p>
    </li>
  `;
  
  try {
    const userId = getCurrentUserId();
    console.log('Loading fields for user ID:', userId);
    
    // Use the improved fetchAPI with retry logic
    const data = await fetchAPI(`fields?user_id=${userId}`, 'GET', null, 3);
    console.log('Fields loaded:', data);
    
    if (data && Array.isArray(data.fields)) {
      displayFields(data.fields);
    } else {
      console.error('Invalid fields data:', data);
      document.getElementById('fieldsList').innerHTML = `
        <li class="text-center py-4">
          <div class="alert alert-warning">
            No fields found. Click "Add Field" to create your first field.
          </div>
        </li>
      `;
    }
  } catch (error) {
    console.error('Error loading fields:', error);
    document.getElementById('fieldsList').innerHTML = `
      <li class="text-center py-4">
        <div class="alert alert-danger">
          <p><strong>Failed to load fields:</strong> ${error.message || 'Connection error'}</p>
          <button class="btn btn-sm btn-outline-danger mt-2" onclick="loadFields()">
            <i class="fas fa-sync-alt"></i> Retry
          </button>
        </div>
      </li>
    `;
  }
}

function displayFields(fields) {
  const fieldsList = document.getElementById('fieldsList');
  
  if (!fields || fields.length === 0) {
    fieldsList.innerHTML = '<li class="text-center py-4">No fields added yet</li>';
    
    // Update counts
    document.getElementById('fieldCount').textContent = '0';
    document.getElementById('cropCount').textContent = '0';
    return;
  }
  
  // Update counts
  document.getElementById('fieldCount').textContent = fields.length;
  
  // Count unique crops
  const uniqueCrops = new Set(fields.filter(f => f.crop_type).map(f => f.crop_type));
  document.getElementById('cropCount').textContent = uniqueCrops.size;
  
  // Display fields
  let html = '';
  fields.forEach(field => {
    html += `
      <li class="field-item" data-field-id="${field.id}">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <strong>${field.name}</strong>
            ${field.crop_type ? `<span class="badge bg-success ms-2">${field.crop_type}</span>` : ''}
          </div>
          <small>${field.area ? field.area + ' ha' : 'Area not set'}</small>
        </div>
      </li>
    `;
  });
  
  fieldsList.innerHTML = html;
  
  // Add click event to fields
  document.querySelectorAll('.field-item').forEach(item => {
    item.addEventListener('click', async () => {
      const fieldId = item.dataset.fieldId;
      localStorage.setItem('current_field_id', fieldId);
      
      // Get field details and display them
      const field = fields.find(f => f.id.toString() === fieldId);
      if (field) {
        displayFieldDetails(field);
      }
    });
  });
}

async function displayFieldDetails(field) {
  const fieldDetails = document.getElementById('fieldDetails');
  
  // Basic field info
  let html = `
    <div class="row mb-4">
      <div class="col-md-6">
        <h5>${field.name}</h5>
        <p><i class="fas fa-map-marker-alt me-2"></i>${field.location || 'Location not set'}</p>
        <p><i class="fas fa-ruler-combined me-2"></i>${field.area ? field.area + ' hectares' : 'Area not set'}</p>
      </div>
      <div class="col-md-6">
        <p><i class="fas fa-seedling me-2"></i><strong>Crop:</strong> ${field.crop_type || 'Not specified'}</p>
        <p><i class="fas fa-calendar me-2"></i><strong>Planted:</strong> ${field.planting_date || 'Date not set'}</p>
        <p><i class="fas fa-layer-group me-2"></i><strong>Soil:</strong> ${field.soil_type || 'Not specified'}</p>
      </div>
    </div>
    
    <ul class="nav nav-tabs" id="fieldTabs" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="monitoring-tab" data-bs-toggle="tab" data-bs-target="#monitoring" type="button" role="tab">Monitoring</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="diseases-tab" data-bs-toggle="tab" data-bs-target="#diseases" type="button" role="tab">Diseases</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="recommendations-tab" data-bs-toggle="tab" data-bs-target="#recommendations" type="button" role="tab">Recommendations</button>
      </li>
    </ul>
    
    <div class="tab-content" id="fieldTabsContent">
      <div class="tab-pane fade show active" id="monitoring" role="tabpanel">
        <div class="text-center py-3">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
      </div>
      <div class="tab-pane fade" id="diseases" role="tabpanel">
        <div class="text-center py-3">
          <p>No disease reports yet</p>
          <button class="btn btn-primary" id="scanForDiseaseBtn">Scan for Diseases</button>
        </div>
      </div>
      <div class="tab-pane fade" id="recommendations" role="tabpanel">
        <div class="text-center py-3">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
      </div>
    </div>
  `;
  
  fieldDetails.innerHTML = html;
  
  // Load monitoring data
  try {
    const monitoringData = await fetchAPI(`field_monitoring?field_id=${field.id}`);
    displayFieldMonitoring(monitoringData);
  } catch (error) {
    document.getElementById('monitoring').innerHTML = `
      <div class="alert alert-danger">
        Failed to load field monitoring data: ${error.message}
      </div>
    `;
  }
  
  // Load recommendations
  try {
    const recommendations = await fetchAPI(`fertilizer_recommendations?field_id=${field.id}`);
    displayRecommendations(recommendations);
  } catch (error) {
    document.getElementById('recommendations').innerHTML = `
      <div class="alert alert-danger">
        Failed to load recommendations: ${error.message}
      </div>
    `;
  }
  
  // Set up disease scan button
  document.getElementById('scanForDiseaseBtn')?.addEventListener('click', () => {
    showSection('diseaseDetectionSection');
  });
}

function displayFieldMonitoring(data) {
  const monitoringTab = document.getElementById('monitoring');
  
  if (!data || !data.ndvi) {
    monitoringTab.innerHTML = '<p>No monitoring data available for this field</p>';
    return;
  }
  
  // Calculate health status color
  let healthColor, healthStatus;
  if (data.ndvi > 0.7) {
    healthColor = 'success';
    healthStatus = 'Excellent';
  } else if (data.ndvi > 0.5) {
    healthColor = 'info';
    healthStatus = 'Good';
  } else if (data.ndvi > 0.3) {
    healthColor = 'warning';
    healthStatus = 'Fair';
  } else {
    healthColor = 'danger';
    healthStatus = 'Poor';
  }
  
  let html = `
    <div class="row mt-3">
      <div class="col-md-6">
        <div class="card mb-3">
          <div class="card-body">
            <h5 class="card-title">NDVI Health Index</h5>
            <div class="progress mb-3" style="height: 25px;">
              <div class="progress-bar bg-${healthColor}" role="progressbar" 
                   style="width: ${data.ndvi * 100}%;" 
                   aria-valuenow="${data.ndvi * 100}" aria-valuemin="0" aria-valuemax="100">
                ${(data.ndvi * 100).toFixed(1)}%
              </div>
            </div>
            <p>Status: <span class="badge bg-${healthColor}">${healthStatus}</span></p>
            <p>Last updated: ${data.last_updated}</p>
          </div>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card mb-3">
          <div class="card-body">
            <h5 class="card-title">Crop Information</h5>
            <p><strong>Crop Stage:</strong> ${data.crop_stage || 'Unknown'}</p>
            <p><strong>Estimated Yield:</strong> ${data.estimated_yield || 'Unknown'}</p>
          </div>
        </div>
      </div>
    </div>
  `;
  
  // Add anomalies if any
  if (data.anomalies && data.anomalies.length > 0) {
    html += '<div class="row mt-3"><div class="col-12"><div class="card border-warning">';
    html += '<div class="card-header bg-warning text-white"><h5 class="mb-0">Detected Anomalies</h5></div>';
    html += '<div class="card-body"><ul class="list-group">';
    
    data.anomalies.forEach(anomaly => {
      html += `
        <li class="list-group-item">
          <strong>${anomaly.type}</strong>
          <p><strong>Location:</strong> ${anomaly.location}</p>
          <p><strong>Severity:</strong> ${anomaly.severity}</p>
          <p><strong>Recommendation:</strong> ${anomaly.recommendation}</p>
        </li>
      `;
    });
    
    html += '</ul></div></div></div></div>';
  }
  
  // Add time series
  if (data.time_series && data.time_series.length > 0) {
    html += `
      <div class="row mt-3">
        <div class="col-12">
          <div class="card">
            <div class="card-body">
              <h5 class="card-title">NDVI Time Series</h5>
              <div class="table-responsive">
                <table class="table table-sm">
                  <thead>
                    <tr>
                      <th>Date</th>
                      <th>NDVI Value</th>
                    </tr>
                  </thead>
                  <tbody>
    `;
    
    data.time_series.forEach(point => {
      html += `
        <tr>
          <td>${point.date}</td>
          <td>${point.ndvi.toFixed(2)}</td>
        </tr>
      `;
    });
    
    html += '</tbody></table></div></div></div></div></div>';
  }
  
  monitoringTab.innerHTML = html;
  
  // Update dashboard health index
  document.getElementById('healthIndex').textContent = 
    data.ndvi ? (data.ndvi * 100).toFixed(0) + '%' : '--';
}

function displayRecommendations(data) {
  const recommendationsTab = document.getElementById('recommendations');
  
  if (!data || (!data.recommendations && !data.generated_by)) {
    recommendationsTab.innerHTML = '<p>No recommendations available for this field</p>';
    return;
  }
  
  let html = '';
  
  // Display different based on response type
  if (typeof data.recommendations === 'object') {
    // Object format
    html += `
      <div class="card mb-3">
        <div class="card-body">
          <h5 class="card-title">Fertilizer Recommendations</h5>
          <p><strong>Recommended NPK Ratio:</strong> ${data.recommendations.npk_ratio}</p>
          <p><strong>Application Rate:</strong> ${data.recommendations.rate}</p>
          <p><strong>Timing:</strong> ${data.recommendations.timing}</p>
          <p><strong>Method:</strong> ${data.recommendations.method}</p>
          <p><strong>Notes:</strong> ${data.recommendations.notes}</p>
        </div>
        <div class="card-footer text-muted">
          Generated by: ${data.generated_by}
        </div>
      </div>
    `;
  } else {
    // String format (AI-generated text)
    html += `
      <div class="card mb-3">
        <div class="card-body">
          <h5 class="card-title">AI Fertilizer Recommendations</h5>
          <div>${data.recommendations.replace(/\n/g, '<br>')}</div>
        </div>
        <div class="card-footer text-muted">
          Generated by: ${data.generated_by}
        </div>
      </div>
    `;
  }
  
  recommendationsTab.innerHTML = html;
}

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
  // Navigation links
  document.getElementById('homeNav').addEventListener('click', () => showSection('homeSection'));
  document.getElementById('dashboardNav').addEventListener('click', () => {
    if (isLoggedIn()) {
      showSection('dashboardSection');
      loadFields();
    } else {
      showSection('loginSection');
    }
  });
  document.getElementById('diseaseDetectNav').addEventListener('click', () => showSection('diseaseDetectionSection'));
  document.getElementById('marketPricesNav').addEventListener('click', () => {
    showSection('marketPricesSection');
    loadMarketPrices();
  });
  document.getElementById('weatherNav').addEventListener('click', () => {
    showSection('weatherSection');
    loadWeather();
  });
  
  // Auth links
  document.getElementById('loginNav').addEventListener('click', () => showSection('loginSection'));
  document.getElementById('registerNav').addEventListener('click', () => showSection('registerSection'));
  document.getElementById('logoutBtn').addEventListener('click', logout);
  document.getElementById('switchToRegister').addEventListener('click', () => showSection('registerSection'));
  document.getElementById('switchToLogin').addEventListener('click', () => showSection('loginSection'));
  
  // Feature links
  document.getElementById('getStartedBtn').addEventListener('click', () => {
    if (isLoggedIn()) {
      showSection('dashboardSection');
      loadFields();
    } else {
      showSection('registerSection');
    }
  });
  document.getElementById('featureDiseaseBtn').addEventListener('click', () => showSection('diseaseDetectionSection'));
  document.getElementById('featureMarketBtn').addEventListener('click', () => {
    showSection('marketPricesSection');
    loadMarketPrices();
    if (isLoggedIn()) {
      loadUserAlerts();
    }
  });
  document.getElementById('featureWeatherBtn').addEventListener('click', () => {
    showSection('weatherSection');
    loadWeather();
  });
  
  // Login form
  document.getElementById('loginForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const username = document.getElementById('loginUsername').value.trim();
    const password = document.getElementById('loginPassword').value;
    
    if (!username || !password) {
      showError('loginError', 'Username and password are required');
      return;
    }
    
    // Disable form during submission
    const loginBtn = document.querySelector('#loginForm button[type="submit"]');
    const originalBtnText = loginBtn.textContent;
    loginBtn.disabled = true;
    loginBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Logging in...';
    
    try {
      console.log('Attempting login for user:', username);
      // Use the improved fetchAPI with retry logic
      const data = await fetchAPI('users/login', 'POST', { username, password }, 3);
      console.log('Login successful:', data);
      
      if (data && data.id) {
        login(data.id, data.username);
        showSection('dashboardSection');
        loadFields();
      } else {
        showError('loginError', 'Invalid login response from server');
      }
    } catch (error) {
      console.error('Login error:', error);
      showError('loginError', error.message || 'Login failed. Please try again.');
    } finally {
      // Re-enable form
      loginBtn.disabled = false;
      loginBtn.textContent = originalBtnText;
    }
  });
  
  // Register form
  document.getElementById('registerForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const username = document.getElementById('registerUsername').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    const confirmPassword = document.getElementById('registerConfirmPassword').value;
    
    if (password !== confirmPassword) {
      showError('registerError', 'Passwords do not match');
      return;
    }
    
    try {
      const data = await fetchAPI('users/register', 'POST', { 
        username, 
        email, 
        password 
      });
      
      // Auto-login after registration
      login(data.id, data.username);
      showSection('dashboardSection');
      loadFields();
    } catch (error) {
      showError('registerError', error.message || 'Registration failed');
    }
  });
  
  // Add field modal
  document.getElementById('addFieldBtn').addEventListener('click', function() {
    const modal = new bootstrap.Modal(document.getElementById('addFieldModal'));
    modal.show();
  });
  
  // Save field
  document.getElementById('saveFieldBtn').addEventListener('click', async function() {
    // Validate required fields
    const fieldName = document.getElementById('fieldName').value.trim();
    if (!fieldName) {
      alert('Field name is required');
      document.getElementById('fieldName').focus();
      return;
    }

    // Get the form data
    const fieldData = {
      user_id: getCurrentUserId(),
      name: fieldName,
      location: document.getElementById('fieldLocation').value.trim(),
      area: parseFloat(document.getElementById('fieldArea').value) || 0,
      crop_type: document.getElementById('cropType').value,
      planting_date: document.getElementById('plantingDate').value,
      soil_type: document.getElementById('soilType').value,
      notes: document.getElementById('fieldNotes').value.trim()
    };
    
    console.log('Submitting field data:', fieldData);
    
    // Disable the save button to prevent double submission
    const saveBtn = document.getElementById('saveFieldBtn');
    const originalText = saveBtn.textContent;
    saveBtn.disabled = true;
    saveBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...';
    
    try {
      // Make API call with explicit error handling
      const response = await fetchAPI('fields', 'POST', fieldData);
      console.log('Field saved successfully:', response);
      
      // Show success message
      alert('Field saved successfully!');
      
      // Close modal and refresh fields
      bootstrap.Modal.getInstance(document.getElementById('addFieldModal')).hide();
      document.getElementById('addFieldForm').reset();
      
      // Reload the fields list
      loadFields();
    } catch (error) {
      console.error('Error saving field:', error);
      alert(`Failed to save field: ${error.message || 'Connection error'}`);
    } finally {
      // Re-enable the save button
      saveBtn.disabled = false;
      saveBtn.textContent = originalText;
    }
  });
  
  // Market price filter
  document.getElementById('applyFilterBtn').addEventListener('click', function() {
    const cropType = document.getElementById('cropFilter').value;
    loadMarketPrices(cropType);
  });
  
  // Price alert form
  document.getElementById('priceAlertForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    if (!isLoggedIn()) {
      showSection('loginSection');
      return;
    }
    
    // Validate crop type
    const cropType = document.getElementById('alertCropType').value;
    if (!cropType) {
      alert('Please select a crop type');
      return;
    }
    
    // Form data
    const alertData = {
      user_id: getCurrentUserId(),
      crop_type: cropType,
      market_name: document.getElementById('alertMarket').value,
      price_alert_min: document.getElementById('alertMinPrice').value || null,
      price_alert_max: document.getElementById('alertMaxPrice').value || null
    };
    
    console.log('Setting price alert:', alertData);
    
    // Disable form during submission
    const submitBtn = document.querySelector('#priceAlertForm button[type="submit"]');
    const originalBtnText = submitBtn.textContent;
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Setting alert...';
    
    try {
      const response = await fetchAPI('market_favorites', 'POST', alertData, 3);
      console.log('Price alert set successfully:', response);
      
      // Success message
      alert('Price alert set successfully!');
      document.getElementById('priceAlertForm').reset();
      
      // Reload user alerts
      loadUserAlerts();
    } catch (error) {
      console.error('Error setting price alert:', error);
      alert(`Failed to set price alert: ${error.message || 'Connection error'}`);
    } finally {
      // Re-enable form
      submitBtn.disabled = false;
      submitBtn.textContent = originalBtnText;
    }
  });
  
  // Function to load user's price alerts
  async function loadUserAlerts() {
    if (!isLoggedIn()) return;
    
    const alertsList = document.getElementById('alertsList');
    
    // Show loading indicator
    alertsList.innerHTML = `
      <li class="list-group-item text-center">
        <div class="spinner-border spinner-border-sm text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
        <span class="ms-2">Loading alerts...</span>
      </li>
    `;
    
    try {
      const userId = getCurrentUserId();
      const data = await fetchAPI(`market_favorites?user_id=${userId}`, 'GET', null, 3);
      console.log('User alerts loaded:', data);
      
      if (data && Array.isArray(data.favorites) && data.favorites.length > 0) {
        let html = '';
        data.favorites.forEach(alert => {
          html += `
            <li class="list-group-item">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <strong>${alert.crop_type}</strong>
                  ${alert.market_name ? `<span class="badge bg-secondary ms-2">${alert.market_name}</span>` : ''}
                </div>
                <div>
                  ${alert.price_alert_min ? `<span class="badge bg-success">Min: ₹${alert.price_alert_min}</span>` : ''}
                  ${alert.price_alert_max ? `<span class="badge bg-danger ms-1">Max: ₹${alert.price_alert_max}</span>` : ''}
                </div>
              </div>
            </li>
          `;
        });
        alertsList.innerHTML = html;
      } else {
        alertsList.innerHTML = '<li class="list-group-item text-center">No alerts set</li>';
      }
    } catch (error) {
      console.error('Error loading user alerts:', error);
      alertsList.innerHTML = `
        <li class="list-group-item text-center text-danger">
          Failed to load alerts: ${error.message || 'Connection error'}
        </li>
      `;
    }
  }
  
  // Weather location
  document.getElementById('getWeatherBtn').addEventListener('click', function() {
    const location = document.getElementById('locationInput').value.trim();
    if (location) {
      loadWeather(location);
    }
  });
  
  // Initialize disease detection
  setupDiseaseDetection();
  
  // Update auth UI
  updateAuthUI();
});