const express = require('express');
const path = require('path');
const app = express();
const PORT = 5000;

// Serve static files from the root directory
app.use(express.static(path.join(__dirname)));

// Main route serves the index.html file
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Start the server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`FarmAssist AI server running at http://0.0.0.0:${PORT}`);
});