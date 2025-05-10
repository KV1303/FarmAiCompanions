#!/bin/bash

echo "==============================================="
echo "FarmAssistAI Production Startup Script"
echo "==============================================="

# Check for required environment variables
echo "Checking Firebase credentials..."
node check_firebase_credentials.js

# Create Firebase service account file if needed
echo "Creating Firebase service account file..."
python create_firebase_credential.py

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

# Run comprehensive Firebase verification
echo "Running Firebase production verification..."
python verify_firebase_production.py
if [ $? -ne 0 ]; then
  echo "ERROR: Firebase verification failed!"
  echo "Please check your Firebase credentials and try again."
  exit 1
fi

# Verify JavaScript Firebase integration
echo "Verifying Firebase JavaScript integration..."
node verify_firebase_connection.js
if [ $? -ne 0 ]; then
  echo "ERROR: Firebase JavaScript verification failed!"
  echo "Please check your Firebase credentials and try again."
  exit 1
fi

# Start the server in production mode
echo "Starting FarmAssistAI in production mode..."
node server.js