#!/usr/bin/env node

/**
 * FarmAssistAI Setup Script
 * 
 * This script helps with initial setup and configuration of the FarmAssistAI
 * application, particularly focusing on Firebase integration.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const readline = require('readline');

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m',
};

// Create a readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

/**
 * Main setup function
 */
async function setup() {
  console.log(`\n${colors.bold}=== FarmAssistAI Setup ====${colors.reset}\n`);
  
  // Check for Node.js and npm
  checkDependencies();
  
  // Create environment template
  createEnvTemplate();
  
  // Check for Firebase credentials
  checkFirebaseCredentials();
  
  // Check for secret keys
  checkSecretKeys();
  
  // Run installation
  installDependencies();
  
  console.log(`\n${colors.green}${colors.bold}Setup completed!${colors.reset}\n`);
  console.log(`To start the application in development mode:`);
  console.log(`  ${colors.cyan}npm start${colors.reset}`);
  console.log(`\nTo start the application in production mode:`);
  console.log(`  ${colors.cyan}./run_production.sh${colors.reset}`);
  console.log(`\nFor Android APK generation:`);
  console.log(`  ${colors.cyan}./quick_build_apk.sh${colors.reset}`);
  
  rl.close();
}

/**
 * Check for required dependencies
 */
function checkDependencies() {
  console.log(`${colors.bold}Checking dependencies...${colors.reset}`);
  
  try {
    // Check Node.js version
    const nodeVersion = execSync('node --version', { encoding: 'utf8' }).trim();
    console.log(`${colors.green}✓ Node.js: ${nodeVersion}${colors.reset}`);
  } catch (error) {
    console.log(`${colors.red}✗ Node.js not found or not in PATH${colors.reset}`);
    console.log(`Please install Node.js from https://nodejs.org/`);
    process.exit(1);
  }
  
  try {
    // Check npm version
    const npmVersion = execSync('npm --version', { encoding: 'utf8' }).trim();
    console.log(`${colors.green}✓ npm: ${npmVersion}${colors.reset}`);
  } catch (error) {
    console.log(`${colors.red}✗ npm not found or not in PATH${colors.reset}`);
    process.exit(1);
  }
  
  try {
    // Check Python version
    const pythonVersion = execSync('python --version', { encoding: 'utf8' }).trim();
    console.log(`${colors.green}✓ Python: ${pythonVersion}${colors.reset}`);
  } catch (error) {
    try {
      // Try python3 command
      const python3Version = execSync('python3 --version', { encoding: 'utf8' }).trim();
      console.log(`${colors.green}✓ Python: ${python3Version}${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Python not found or not in PATH${colors.reset}`);
      console.log(`Please install Python from https://www.python.org/`);
    }
  }
  
  try {
    // Check Flutter version
    const flutterVersion = execSync('flutter --version', { encoding: 'utf8' });
    console.log(`${colors.green}✓ Flutter installed${colors.reset}`);
  } catch (error) {
    console.log(`${colors.yellow}! Flutter not found${colors.reset}`);
    console.log(`Flutter is needed only for mobile app development.`);
    console.log(`If you plan to build mobile apps, install Flutter from https://flutter.dev/\n`);
  }
}

/**
 * Create environment template
 */
function createEnvTemplate() {
  console.log(`\n${colors.bold}Creating environment template...${colors.reset}`);
  
  try {
    // Run the create_env_template.js script
    execSync('node create_env_template.js', { encoding: 'utf8' });
    console.log(`${colors.green}✓ Environment template created${colors.reset}`);
  } catch (error) {
    console.log(`${colors.red}✗ Failed to create environment template${colors.reset}`);
    console.log(error.message);
  }
}

/**
 * Check for Firebase credentials
 */
function checkFirebaseCredentials() {
  console.log(`\n${colors.bold}Checking Firebase credentials...${colors.reset}`);
  
  try {
    // Run the check_firebase_credentials.js script
    execSync('node check_firebase_credentials.js', { encoding: 'utf8' });
  } catch (error) {
    console.log(`${colors.red}✗ Failed to check Firebase credentials${colors.reset}`);
    console.log(error.message);
  }
}

/**
 * Check for secret keys
 */
function checkSecretKeys() {
  console.log(`\n${colors.bold}Checking secret keys...${colors.reset}`);
  
  // List of required API keys
  const requiredKeys = [
    { name: 'GEMINI_API_KEY', description: 'Google Gemini AI API Key' },
    { name: 'VITE_STRIPE_PUBLIC_KEY', description: 'Stripe Public Key (optional, for payment processing)' },
    { name: 'STRIPE_SECRET_KEY', description: 'Stripe Secret Key (optional, for payment processing)' }
  ];
  
  // Check each key
  let missingKeys = [];
  for (const key of requiredKeys) {
    if (!process.env[key.name]) {
      missingKeys.push(key);
      console.log(`${colors.yellow}! Missing ${key.name}: ${key.description}${colors.reset}`);
    } else {
      console.log(`${colors.green}✓ ${key.name} found${colors.reset}`);
    }
  }
  
  // If keys are missing, provide guidance
  if (missingKeys.length > 0) {
    console.log(`\n${colors.yellow}Some API keys are missing or not set in environment variables.${colors.reset}`);
    console.log(`Add these to your .env file or set them as environment variables.`);
  }
}

/**
 * Install dependencies
 */
function installDependencies() {
  console.log(`\n${colors.bold}Checking for dependencies...${colors.reset}`);
  
  // Check if node_modules exists
  if (!fs.existsSync('node_modules')) {
    console.log(`Installing Node.js dependencies...`);
    try {
      execSync('npm install', { stdio: 'inherit' });
      console.log(`${colors.green}✓ Node.js dependencies installed${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Failed to install Node.js dependencies${colors.reset}`);
    }
  } else {
    console.log(`${colors.green}✓ Node.js dependencies already installed${colors.reset}`);
  }
  
  // Check for Python packages
  console.log(`\nPython dependencies are managed separately by the packager tool.`);
}

// Run the setup function
setup();