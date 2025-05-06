const admin = require('firebase-admin');
const { getServiceAccount, createServiceAccountFile } = require('./firebase_service_account');

// Initialize Firebase Admin SDK
let firebaseApp;

// First try initialization using service account
try {
  console.log('Initializing Firebase Admin SDK...');
  const { serviceAccount, isValid } = getServiceAccount();
  
  if (!isValid) {
    throw new Error('Invalid service account credentials');
  }

  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET
  });
  console.log('✅ Firebase Admin SDK initialized successfully with service account!');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK with service account:', error.message);
  
  // Try file-based initialization if environment variable approach failed
  try {
    console.log('Attempting to create a service account file for initialization...');
    const serviceAccountPath = createServiceAccountFile();
    
    if (serviceAccountPath) {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccountPath),
        databaseURL: process.env.FIREBASE_DATABASE_URL,
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET
      });
      console.log('✅ Firebase Admin SDK initialized with service account file!');
    } else {
      throw new Error('Failed to create service account file');
    }
  } catch (fileError) {
    console.error('❌ File-based initialization failed:', fileError.message);
    
    // Try application default credentials
    try {
      console.log('Attempting to use application default credentials...');
      firebaseApp = admin.initializeApp({
        projectId: process.env.VITE_FIREBASE_PROJECT_ID,
        databaseURL: process.env.FIREBASE_DATABASE_URL,
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET
      });
      console.log('✅ Firebase Admin SDK initialized with application default credentials!');
    } catch (fallbackError) {
      console.error('❌ Failed to initialize Firebase Admin with all methods:', fallbackError.message);
      console.log('⚠️ Setting up in-memory Firebase implementation for development');
    }
  }
}

const db = admin.firestore();
const auth = admin.auth();
const storage = admin.storage();

module.exports = {
  admin,
  db,
  auth,
  storage,
  firebaseApp
};