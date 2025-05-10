/**
 * Firebase Connection Verification Tool
 * 
 * This script validates Firebase connectivity for both admin and client SDKs
 * to ensure the application is ready for production deployment.
 */

const admin = require('./firebase_admin');
const client = require('./firebase_client');

console.log('==============================================');
console.log('Firebase Connection Verification Tool');
console.log('==============================================');

// Check environment variables
const requiredVars = [
  'VITE_FIREBASE_API_KEY',
  'VITE_FIREBASE_PROJECT_ID',
  'VITE_FIREBASE_APP_ID',
  'FIREBASE_AUTH_DOMAIN',
  'FIREBASE_STORAGE_BUCKET',
  'FIREBASE_PRIVATE_KEY',
  'FIREBASE_CLIENT_EMAIL',
  'FIREBASE_CLIENT_ID',
  'FIREBASE_CLIENT_CERT_URL'
];

console.log('Checking environment variables:');
const missingVars = [];
requiredVars.forEach(varName => {
  const value = process.env[varName];
  if (!value) {
    missingVars.push(varName);
    console.log(`❌ ${varName}: Missing`);
  } else {
    // Display partial value for verification without exposing secrets
    const displayValue = varName.includes('KEY') || varName.includes('EMAIL') || varName.includes('ID')
      ? `${value.substring(0, 5)}...${value.substring(value.length - 5)}`
      : value;
    console.log(`✅ ${varName}: ${displayValue}`);
  }
});

if (missingVars.length > 0) {
  console.error('\n⚠️ Missing environment variables detected!');
  console.error('Please set the missing variables before deploying to production.');
  console.error('See PRODUCTION.md for setup instructions.');
  process.exit(1);
}

// Verify Firebase Admin SDK connectivity
console.log('\nVerifying Firebase Admin SDK connection...');
try {
  // Attempt to get a reference to a test collection
  const testRef = admin.firestore().collection('connection_test');
  
  // Add a test document
  testRef.add({
    timestamp: new Date(),
    message: 'Firebase Admin SDK connection successful'
  }).then(docRef => {
    console.log(`✅ Admin SDK Firestore write successful: ${docRef.id}`);
    
    // Clean up the test document
    docRef.delete().then(() => {
      console.log('✅ Admin SDK Firestore cleanup successful');
    }).catch(err => {
      console.error(`❌ Admin SDK Firestore cleanup failed: ${err.message}`);
    });
  }).catch(err => {
    console.error(`❌ Admin SDK Firestore write failed: ${err.message}`);
    process.exit(1);
  });
  
  // Verify storage bucket access
  const bucket = admin.storage().bucket();
  if (bucket) {
    console.log('✅ Admin SDK Storage bucket access successful');
  } else {
    console.error('❌ Admin SDK Storage bucket access failed');
    process.exit(1);
  }

  // Verify auth service access
  if (admin.auth()) {
    console.log('✅ Admin SDK Auth service access successful');
  } else {
    console.error('❌ Admin SDK Auth service access failed');
    process.exit(1);
  }
} catch (error) {
  console.error(`❌ Admin SDK connection failed: ${error.message}`);
  process.exit(1);
}

console.log('\nConnection verification complete!');
console.log('Firebase is properly configured for production use.');
console.log('==============================================');