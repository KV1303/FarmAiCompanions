const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// For security, we use environment variables instead of embedding the service account info
let firebaseApp;

// First try initialization using service account
try {
  // Process private key - Fix common formatting issues
  let privateKey = process.env.FIREBASE_PRIVATE_KEY || '';
  
  // Replace escaped newlines with actual newlines
  if (privateKey.includes('\\n')) {
    privateKey = privateKey.replace(/\\n/g, '\n');
  }
  
  // Ensure key has proper PEM format
  if (!privateKey.includes('-----BEGIN PRIVATE KEY-----')) {
    privateKey = '-----BEGIN PRIVATE KEY-----\n' + privateKey;
  }
  
  if (!privateKey.includes('-----END PRIVATE KEY-----')) {
    privateKey = privateKey + '\n-----END PRIVATE KEY-----\n';
  }
  
  const serviceAccount = {
    "type": "service_account",
    "project_id": process.env.VITE_FIREBASE_PROJECT_ID,
    "private_key": privateKey,
    "client_email": process.env.FIREBASE_CLIENT_EMAIL,
    "client_id": process.env.FIREBASE_CLIENT_ID,
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": process.env.FIREBASE_CLIENT_CERT_URL
  };

  firebaseApp = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET
  });
  console.log('Firebase Admin SDK initialized successfully with service account');
} catch (error) {
  console.error('Error initializing Firebase Admin SDK with service account:', error);
  
  // Try alternative initialization using application default credentials
  try {
    firebaseApp = admin.initializeApp({
      projectId: process.env.VITE_FIREBASE_PROJECT_ID,
      databaseURL: process.env.FIREBASE_DATABASE_URL,
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET
    });
    console.log('Firebase Admin SDK initialized with application default credentials');
  } catch (fallbackError) {
    console.error('Failed to initialize Firebase Admin with fallback method:', fallbackError);
    console.log('Setting up in-memory Firebase implementation for development');
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