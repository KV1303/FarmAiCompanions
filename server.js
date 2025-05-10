const express = require('express');
const path = require('path');
const { spawn } = require('child_process');
const cors = require('cors');
const fetch = require('node-fetch');
const fs = require('fs');
const multer = require('multer');
const FormData = require('form-data');

// Import Firebase configurations
const firebaseAdmin = require('./firebase_admin');
const firebaseClient = require('./firebase_client');

const app = express();
const PORT = 5000;
const API_PORT = 5004;

// Create uploads directory if it doesn't exist
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

// Configure middleware
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Configure file uploads
const upload = multer({ dest: 'uploads/' });

// Serve the main HTML file
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Handle file uploads
app.post('/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  
  res.json({
    filename: req.file.filename,
    originalname: req.file.originalname,
    path: req.file.path
  });
});

// Start Python API server
function startPythonAPI() {
  console.log('Starting Python API server...');
  
  // Get current environment (production or development)
  const isProduction = process.env.NODE_ENV === 'production';
  console.log(`Running in ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'} mode`);
  
  // Check and update the API port in the Python file
  try {
    let apiContent = fs.readFileSync('api.py', 'utf8');
    if (!apiContent.includes(`port=${API_PORT}`)) {
      apiContent = apiContent.replace(
        /app\.run\(host=['"]0\.0\.0\.0['"], port=\d+/,
        `app.run(host='0.0.0.0', port=${API_PORT}`
      );
      fs.writeFileSync('api.py', apiContent);
    }
  } catch (err) {
    console.error('Failed to update API port:', err);
  }
  
  // Start the Python process with appropriate flags for the environment
  const pythonArgs = isProduction 
    ? ['api.py'] // In production mode, debug is already disabled via env var
    : ['api.py', '--debug'];
    
  console.log(`Starting Python API with args: ${pythonArgs.join(' ')}`);
  const pythonProcess = spawn('python3', pythonArgs);
  
  pythonProcess.stdout.on('data', (data) => {
    console.log(`Python API: ${data}`);
  });
  
  pythonProcess.stderr.on('data', (data) => {
    console.error(`Python API error: ${data}`);
  });
  
  pythonProcess.on('close', (code) => {
    console.log(`Python API exited with code ${code}`);
    if (code !== 0) {
      setTimeout(startPythonAPI, 5000);
    }
  });
  
  return pythonProcess;
}

// Handle image uploads for disease detection with Firebase Storage integration
const apiUpload = multer({ dest: 'uploads/' });
app.post('/api/disease_detect', apiUpload.single('image'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No image uploaded' });
  }
  
  try {
    console.log(`[Disease Detection] Processing image from ${req.file.path}`);
    
    // Upload the image to Firebase Storage
    let imageUrl = req.file.path;
    let firebaseImageUrl = null;
    
    try {
      // Read the file
      const fileBuffer = fs.readFileSync(req.file.path);
      
      // Upload to Firebase Storage
      const fileMetadata = {
        contentType: req.file.mimetype,
      };
      
      const fileRef = firebaseAdmin.storage.bucket().file(`disease_images/${req.file.filename}`);
      await fileRef.save(fileBuffer, {
        metadata: fileMetadata,
        public: true,
      });
      
      // Get the public URL
      firebaseImageUrl = `https://storage.googleapis.com/${process.env.FIREBASE_STORAGE_BUCKET}/disease_images/${req.file.filename}`;
      console.log(`[Firebase] Uploaded image to: ${firebaseImageUrl}`);
      
      // Use Firebase URL if available
      if (firebaseImageUrl) {
        imageUrl = firebaseImageUrl;
      }
    } catch (uploadError) {
      console.error('[Firebase] Error uploading to storage:', uploadError);
      // Continue with local path if Firebase upload fails
    }
    
    // Save to Firebase Firestore
    try {
      if (req.body.user_id && req.body.field_id) {
        const reportData = {
          user_id: req.body.user_id,
          field_id: req.body.field_id,
          disease_name: "Unknown Disease", // Will be updated by AI
          detection_date: new Date(),
          confidence_score: 0,
          image_path: imageUrl,
          status: "detected"
        };
        
        const reportRef = await firebaseAdmin.db.collection('disease_reports').add(reportData);
        console.log(`[Firebase] Disease report saved with ID: ${reportRef.id}`);
      }
    } catch (dbError) {
      console.error('[Firebase] Error saving to Firestore:', dbError);
    }
    
    // Process with AI (or use placeholder for now)
    const diseaseResponse = {
      disease_name: "Leaf Blight",
      confidence: 0.85,
      symptoms: "Yellow to brown spots on leaves, dried leaf edges, and wilting. The infected areas often develop characteristic patterns spreading from the edges inward.",
      treatment: "1. Remove and destroy infected plant material\n2. Apply copper-based fungicide every 7-10 days\n3. Improve air circulation around plants\n4. Avoid overhead watering to prevent spread",
      image_path: imageUrl
    };
    
    return res.json(diseaseResponse);
  } catch (err) {
    console.error('Disease Detection Error:', err);
    return res.status(500).json({
      error: 'Failed to process image',
      details: err.message
    });
  }
});

// Add Firebase Auth routes
app.post('/api/firebase/register', async (req, res) => {
  try {
    const { email, password, username, fullName } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    
    // Create user in Firebase Auth
    const userRecord = await firebaseAdmin.auth.createUser({
      email,
      password,
      displayName: username || fullName || email.split('@')[0]
    });
    
    // Create user profile in Firestore
    const userData = {
      uid: userRecord.uid,
      email: email,
      username: username || email.split('@')[0],
      fullName: fullName || '',
      createdAt: new Date(),
      isActive: true
    };
    
    await firebaseAdmin.db.collection('users').doc(userRecord.uid).set(userData);
    
    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName
      }
    });
  } catch (error) {
    console.error('Firebase registration error:', error);
    res.status(400).json({
      error: 'Registration failed',
      message: error.message
    });
  }
});

app.post('/api/firebase/login', async (req, res) => {
  try {
    // For server-side token verification (custom token auth flow)
    // In a real implementation, this would validate a token from the client
    const { email, password } = req.body;
    
    // We can't directly authenticate with email/password on the server side
    // This would typically be done on the client with signInWithEmailAndPassword
    // Here we're just checking if the user exists
    
    try {
      const userRecord = await firebaseAdmin.auth.getUserByEmail(email);
      
      // Create a custom token for this user
      const customToken = await firebaseAdmin.auth.createCustomToken(userRecord.uid);
      
      // Get user data from Firestore
      const userDoc = await firebaseAdmin.db.collection('users').doc(userRecord.uid).get();
      const userData = userDoc.data();
      
      res.json({
        token: customToken,
        user: {
          id: userRecord.uid,
          email: userRecord.email,
          username: userData?.username || userRecord.displayName,
          fullName: userData?.fullName || ''
        }
      });
    } catch (error) {
      console.error('Firebase login error:', error);
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (error) {
    console.error('Firebase login error:', error);
    res.status(500).json({ error: 'Login failed', message: error.message });
  }
});

// API proxy middleware for other endpoints
app.use('/api', async (req, res) => {
  // Skip the disease_detect endpoint as it's handled separately
  if (req.path === '/disease_detect' && req.method.toLowerCase() === 'post') {
    return;
  }
  
  // Skip Firebase auth endpoints
  if (req.path.startsWith('/firebase/')) {
    return;
  }
  
  const url = `http://localhost:${API_PORT}${req.originalUrl}`;
  const method = req.method.toLowerCase();
  let retries = 3;
  
  async function attemptRequest() {
    try {
      const options = {
        method,
        headers: { 'Content-Type': 'application/json' }
      };
      
      if (['post', 'put', 'patch'].includes(method) && req.body) {
        options.body = JSON.stringify(req.body);
      }
      
      console.log(`[Proxy] ${method.toUpperCase()} ${url}`);
      const response = await fetch(url, options);
      
      // Check if response is ok
      if (!response.ok) {
        console.error(`[Proxy] API request failed with status ${response.status}`);
        const errorData = await response.json();
        return res.status(response.status).json(errorData);
      }
      
      const data = await response.json();
      console.log(`[Proxy] Response from ${url}:`, typeof data === 'object' ? 'object' : data);
      return res.json(data);
    } catch (err) {
      console.error('API Proxy Error:', err);
      
      // If there are remaining retries and it's a network error (not a server error)
      if (retries > 0 && (err.code === 'ECONNREFUSED' || err.type === 'system')) {
        retries--;
        const delay = (3 - retries) * 1000; // Exponential backoff
        console.log(`[Proxy] Connection failed, retrying in ${delay}ms (${retries} retries left)...`);
        await new Promise(resolve => setTimeout(resolve, delay));
        return attemptRequest();
      }
      
      return res.status(500).json({
        error: 'Failed to connect to API server',
        details: err.message
      });
    }
  }
  
  return attemptRequest();
});

// Start the API and web server
const pythonProcess = startPythonAPI();

// Handle clean shutdown
process.on('SIGINT', () => {
  console.log('Shutting down...');
  if (pythonProcess) {
    pythonProcess.kill();
  }
  process.exit();
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  // Get environment mode
  const isProduction = process.env.NODE_ENV === 'production';
  
  // Additional production checks
  if (isProduction) {
    console.log('=========================================');
    console.log('🚀 PRODUCTION MODE ACTIVE');
    console.log('Firebase Configuration:');
    console.log(`- Project ID: ${process.env.VITE_FIREBASE_PROJECT_ID || 'Not set'}`);
    console.log(`- Authentication Domain: ${process.env.FIREBASE_AUTH_DOMAIN || 'Not set'}`);
    console.log(`- Storage Bucket: ${process.env.FIREBASE_STORAGE_BUCKET || 'Not set'}`);
    console.log('=========================================');
  }
  
  console.log(`FarmAssist AI server running at http://0.0.0.0:${PORT}`);
});