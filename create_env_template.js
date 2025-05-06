#!/usr/bin/env node

/**
 * Environment Template Creator
 * 
 * This script creates a .env.template file with all required environment variables
 * for the FarmAssistAI application. Users can copy this to .env and fill in their values.
 */

const fs = require('fs');
const path = require('path');

// Define all required environment variables
const envVars = [
  {
    name: 'NODE_ENV',
    description: 'Node.js environment (development, production)',
    example: 'production'
  },
  {
    name: 'FLASK_ENV', 
    description: 'Flask environment (development, production)',
    example: 'production'
  },
  {
    name: 'FLASK_DEBUG',
    description: 'Flask debug mode (0, 1)',
    example: '0'
  },
  {
    name: 'VITE_FIREBASE_API_KEY',
    description: 'Firebase Web API Key (starts with "AIza")',
    example: 'AIzaSyA1bCdEfGhIjKlMnOpQrStUvWxYz'
  },
  {
    name: 'VITE_FIREBASE_PROJECT_ID',
    description: 'Firebase Project ID',
    example: 'farmassistai-12345'
  },
  {
    name: 'VITE_FIREBASE_APP_ID',
    description: 'Firebase App ID',
    example: '1:123456789012:web:abcdef123456'
  },
  {
    name: 'FIREBASE_AUTH_DOMAIN',
    description: 'Firebase Auth Domain (usually projectId.firebaseapp.com)',
    example: 'farmassistai-12345.firebaseapp.com'
  },
  {
    name: 'FIREBASE_STORAGE_BUCKET',
    description: 'Firebase Storage Bucket (usually projectId.appspot.com)',
    example: 'farmassistai-12345.appspot.com'
  },
  {
    name: 'FIREBASE_DATABASE_URL',
    description: 'Firebase Realtime Database URL (if used)',
    example: 'https://farmassistai-12345.firebaseio.com'
  },
  {
    name: 'FIREBASE_CLIENT_EMAIL',
    description: 'Firebase Admin SDK Service Account Email',
    example: 'firebase-adminsdk-abcde@farmassistai-12345.iam.gserviceaccount.com'
  },
  {
    name: 'FIREBASE_CLIENT_ID',
    description: 'Firebase Admin SDK Client ID',
    example: '123456789012345678901'
  },
  {
    name: 'FIREBASE_CLIENT_CERT_URL',
    description: 'Firebase Admin SDK Client Certificate URL',
    example: 'https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-abcde%40farmassistai-12345.iam.gserviceaccount.com'
  },
  {
    name: 'FIREBASE_PRIVATE_KEY',
    description: 'Firebase Admin SDK Private Key (keep the format with newlines as \\n)',
    example: '-----BEGIN PRIVATE KEY-----\\nMIIEvgIBADANBgkqhkiG9w0BAQEF...\\n-----END PRIVATE KEY-----\\n'
  },
  {
    name: 'GEMINI_API_KEY',
    description: 'Google Gemini AI API Key',
    example: 'AIzaSyA1bCdEfGhIjKlMnOpQrStUvWxYz'
  }
];

// Generate the template file content
let templateContent = `# FarmAssistAI Environment Variables
# Copy this file to .env and fill in your values

`;

// Add each environment variable to the template
envVars.forEach(variable => {
  templateContent += `# ${variable.description}\n${variable.name}=${variable.example}\n\n`;
});

// Write the template file
const templatePath = path.join(__dirname, '.env.template');
fs.writeFileSync(templatePath, templateContent);

console.log(`Environment template created at: ${templatePath}`);
console.log('Copy this file to .env and update it with your actual values.');