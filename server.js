const express = require('express');
const path = require('path');
const { spawn } = require('child_process');
const cors = require('cors');
const fetch = require('node-fetch');
const fs = require('fs');
const multer = require('multer');
const FormData = require('form-data');

const app = express();
const PORT = 5000;
const API_PORT = 5002;

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
  
  // Start the Python process
  const pythonProcess = spawn('python3', ['api.py']);
  
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

// Handle image uploads directly
const apiUpload = multer({ dest: 'uploads/' });
app.post('/api/disease_detect', apiUpload.single('image'), async (req, res) => {
  const url = `http://localhost:${API_PORT}/api/disease_detect`;
  try {
    // Create formData with the file path
    const formData = new FormData();
    formData.append('image_path', req.file.path);
    
    // Add other form fields
    for (const key in req.body) {
      formData.append(key, req.body[key]);
    }
    
    console.log(`[Proxy] POST ${url} with image from ${req.file.path}`);
    
    // Forward to Python API
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        image_path: req.file.path,
        crop_type: req.body.crop_type || 'unknown',
        user_id: req.body.user_id,
        field_id: req.body.field_id
      })
    });
    
    // Check if response is ok
    if (!response.ok) {
      console.error(`[Proxy] API request failed with status ${response.status}`);
      const errorText = await response.text();
      let errorData;
      try {
        errorData = JSON.parse(errorText);
      } catch(e) {
        errorData = { error: errorText };
      }
      return res.status(response.status).json(errorData);
    }
    
    const data = await response.json();
    console.log(`[Proxy] Response from ${url}:`, typeof data === 'object' ? 'object' : data);
    return res.json(data);
  } catch (err) {
    console.error('Disease Detection API Proxy Error:', err);
    return res.status(500).json({
      error: 'Failed to connect to API server',
      details: err.message
    });
  }
});

// API proxy middleware for other endpoints
app.use('/api', async (req, res) => {
  // Skip the disease_detect endpoint as it's handled separately
  if (req.path === '/disease_detect' && req.method.toLowerCase() === 'post') {
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
  console.log(`FarmAssist AI server running at http://0.0.0.0:${PORT}`);
});