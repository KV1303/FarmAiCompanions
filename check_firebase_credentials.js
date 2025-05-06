#!/usr/bin/env node

/**
 * Firebase Credentials Checker
 * 
 * This script checks if all required Firebase credentials are set as environment variables.
 * If any are missing, it logs guidance on how to obtain them.
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Required Firebase credentials
const requiredCredentials = [
  {
    name: 'VITE_FIREBASE_API_KEY',
    description: 'Firebase Web API Key (starts with "AIza")',
    isSecret: false,
  },
  {
    name: 'VITE_FIREBASE_PROJECT_ID',
    description: 'Firebase Project ID',
    isSecret: false,
  },
  {
    name: 'VITE_FIREBASE_APP_ID',
    description: 'Firebase App ID',
    isSecret: false,
  },
  {
    name: 'FIREBASE_AUTH_DOMAIN',
    description: 'Firebase Auth Domain (usually projectId.firebaseapp.com)',
    isSecret: false,
  },
  {
    name: 'FIREBASE_STORAGE_BUCKET',
    description: 'Firebase Storage Bucket (usually projectId.appspot.com)',
    isSecret: false,
  },
  {
    name: 'FIREBASE_DATABASE_URL',
    description: 'Firebase Realtime Database URL (if used)',
    isSecret: false,
  },
  {
    name: 'FIREBASE_CLIENT_EMAIL',
    description: 'Firebase Admin SDK Service Account Email',
    isSecret: true,
  },
  {
    name: 'FIREBASE_PRIVATE_KEY',
    description: 'Firebase Admin SDK Private Key',
    isSecret: true,
  },
  {
    name: 'FIREBASE_CLIENT_ID',
    description: 'Firebase Admin SDK Client ID',
    isSecret: true,
  },
  {
    name: 'FIREBASE_CLIENT_CERT_URL',
    description: 'Firebase Admin SDK Client Certificate URL',
    isSecret: true,
  }
];

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m',
};

/**
 * Checks if all required Firebase credentials are set as environment variables
 * @returns {Object} Object containing missing and present credentials
 */
function checkCredentials() {
  const missing = [];
  const present = [];

  for (const cred of requiredCredentials) {
    if (!process.env[cred.name]) {
      missing.push(cred);
    } else {
      present.push(cred);
    }
  }

  return { missing, present };
}

/**
 * Prints guidance for obtaining missing Firebase credentials
 * @param {Array} missingCredentials List of missing credentials
 */
function printGuidance(missingCredentials) {
  console.log(`\n${colors.yellow}${colors.bold}Missing Firebase Credentials${colors.reset}\n`);
  console.log(`The following Firebase credentials are required but missing:\n`);
  
  missingCredentials.forEach((cred, index) => {
    console.log(`${index + 1}. ${colors.cyan}${cred.name}${colors.reset} - ${cred.description}`);
  });
  
  console.log(`\n${colors.bold}How to obtain Firebase credentials:${colors.reset}\n`);
  console.log(`1. Go to the Firebase Console (${colors.cyan}https://console.firebase.google.com/${colors.reset})`);
  console.log(`2. Select your project`);
  console.log(`3. For Web API credentials (VITE_FIREBASE_*), go to Project Settings > General > Your Apps > Web app`);
  console.log(`4. For Admin SDK credentials (FIREBASE_*), go to Project Settings > Service accounts > Generate new private key\n`);
  
  console.log(`Once you have these credentials, add them to your environment variables or .env file.\n`);
}

/**
 * Main function
 */
function main() {
  console.log(`\n${colors.bold}Checking Firebase Credentials...${colors.reset}\n`);
  
  const { missing, present } = checkCredentials();
  
  if (present.length > 0) {
    console.log(`${colors.green}✓ ${present.length} of ${requiredCredentials.length} credentials found${colors.reset}`);
  }
  
  if (missing.length > 0) {
    console.log(`${colors.red}✗ ${missing.length} of ${requiredCredentials.length} credentials missing${colors.reset}`);
    printGuidance(missing);
  } else {
    console.log(`${colors.green}${colors.bold}All Firebase credentials are properly configured!${colors.reset}\n`);
  }
}

// Run the main function
main();