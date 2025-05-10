/**
 * Quick utility to check if the application is running in production mode
 * and display current environment configuration
 */

console.log('========================================');
console.log('FarmAssistAI Environment Configuration');
console.log('========================================');

// Check Node.js environment
const nodeEnv = process.env.NODE_ENV || 'development';
console.log(`Node Environment: ${nodeEnv} ${nodeEnv === 'production' ? '✅' : '❌'}`);

// Check Flask environment
const flaskEnv = process.env.FLASK_ENV || 'development';
console.log(`Flask Environment: ${flaskEnv} ${flaskEnv === 'production' ? '✅' : '❌'}`);

// Check debug settings
const flaskDebug = process.env.FLASK_DEBUG || '1';
console.log(`Flask Debug: ${flaskDebug} ${flaskDebug === '0' ? '✅' : '❌'}`);

// Check Firebase config
console.log('\nFirebase Configuration:');
const firebaseKeys = [
  'VITE_FIREBASE_PROJECT_ID',
  'FIREBASE_AUTH_DOMAIN',
  'FIREBASE_STORAGE_BUCKET'
];

let allFirebaseKeysPresent = true;
firebaseKeys.forEach(key => {
  const value = process.env[key];
  if (!value) {
    allFirebaseKeysPresent = false;
    console.log(`- ${key}: Missing ❌`);
  } else {
    console.log(`- ${key}: ${value} ✅`);
  }
});

// Check Gemini API key
const geminiKey = process.env.GEMINI_API_KEY ? '(Set)' : 'Missing';
console.log(`\nGemini API Key: ${geminiKey} ${process.env.GEMINI_API_KEY ? '✅' : '❌'}`);

// Overall status
console.log('\n========================================');
const isProduction = nodeEnv === 'production' && flaskEnv === 'production' && flaskDebug === '0' && allFirebaseKeysPresent;
if (isProduction) {
  console.log('✅ Application is in PRODUCTION mode');
} else {
  console.log('❌ Application is in DEVELOPMENT mode');
  console.log('Run ./run_production.sh to switch to production mode');
}
console.log('========================================');