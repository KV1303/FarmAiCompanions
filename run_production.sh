#!/bin/bash

echo "==============================================="
echo "FarmAssistAI Production Startup Script"
echo "==============================================="

# Check for required environment variables
echo "Checking Firebase credentials..."
node check_firebase_credentials.js

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "Installing Node.js dependencies..."
  npm install --production
fi

# All Python dependencies should be installed using the package manager
echo "Python dependencies should already be installed"

# Set production environment variables
export NODE_ENV=production
export FLASK_ENV=production
export FLASK_DEBUG=0

# Start the server in production mode
echo "Starting FarmAssistAI in production mode..."
node server.js