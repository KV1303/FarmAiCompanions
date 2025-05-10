# FarmAssistAI Production Deployment Guide

This guide provides step-by-step instructions to make your FarmAssistAI application ready for production deployment with Firebase integration.

## Production Mode Features

The FarmAssistAI application has been configured to enforce strict requirements in production mode:

1. **Firebase Enforcement**: In production mode, the application will refuse to start with in-memory fallback database. Proper Firebase credentials are required.
2. **Verification Tools**: Multiple verification scripts ensure all Firebase services are properly configured and accessible.
3. **Enhanced Security**: Development features like debug mode and in-memory data storage are disabled in production.
4. **Performance Optimizations**: Various optimizations are applied in production mode.

## Prerequisites

Before proceeding, ensure you have:

- Node.js v16+ installed
- Python 3.8+ installed
- A Firebase project created at [Firebase Console](https://console.firebase.google.com/)
- Required API keys (Firebase, Google Gemini)

## Step 1: Firebase Setup

1. **Create a Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the setup wizard
   - Enable Firestore Database, Authentication, and Storage

2. **Generate Service Account Key**:
   - In Firebase Console, go to Project Settings > Service accounts
   - Click "Generate new private key"
   - Save the JSON file securely

3. **Register a Web App**:
   - In Firebase Console, click on the "</>" icon
   - Register your app with a nickname
   - Copy the Firebase configuration

## Step 2: Environment Configuration

1. **Generate Environment Template**:
   ```bash
   ./create_env_template.js
   ```

2. **Create Environment File**:
   - Copy the generated `.env.template` to `.env`
   - Fill in all Firebase-related variables:
     - `VITE_FIREBASE_API_KEY`: Your web API key (starts with "AIza")
     - `VITE_FIREBASE_PROJECT_ID`: Your Firebase project ID
     - `VITE_FIREBASE_APP_ID`: Your Firebase app ID
     - `FIREBASE_AUTH_DOMAIN`: Usually `[projectId].firebaseapp.com`
     - `FIREBASE_STORAGE_BUCKET`: Usually `[projectId].appspot.com`
     - `FIREBASE_DATABASE_URL`: Your Realtime Database URL (if used)
     - `FIREBASE_CLIENT_EMAIL`: From your service account JSON
     - `FIREBASE_PRIVATE_KEY`: From your service account JSON (maintain format with \n)
     - `FIREBASE_CLIENT_ID`: From your service account JSON
     - `FIREBASE_CLIENT_CERT_URL`: From your service account JSON
     - `GEMINI_API_KEY`: Your Google Gemini AI API key

## Step 3: Dependency Installation

1. **Install Node.js Dependencies**:
   ```bash
   npm install --production
   ```

2. **Verify Python Dependencies**:
   Python dependencies are already installed through the Replit packager tool.

## Step 4: Verify Configuration

1. **Check Firebase Credentials**:
   ```bash
   ./check_firebase_credentials.js
   ```

2. **Verify Service Account**:
   ```bash
   python create_firebase_credential.py
   ```

## Step 5: Production Deployment

1. **Start in Production Mode**:
   ```bash
   ./run_production.sh
   ```

2. **For Web Deployment**:
   - Firebase Hosting:
     ```bash
     npm install -g firebase-tools
     firebase login
     firebase init hosting
     firebase deploy
     ```

3. **For Mobile Deployment**:
   - Generate Android APK:
     ```bash
     ./quick_build_apk.sh
     ```
   - The APK will be available in the `releases` directory

## Troubleshooting

### Firebase Connection Issues

If you face issues with Firebase credentials:

1. **Verify Environment Variables**:
   - Check that all Firebase-related variables are correctly set in your environment
   - Pay special attention to the `FIREBASE_PRIVATE_KEY` format
   - Run `node check_production_mode.js` to verify environment configuration

2. **Check Service Account Key Format**:
   - Run `./create_firebase_credential.py` to create a properly formatted key file
   - Set the path to this file in the `GOOGLE_APPLICATION_CREDENTIALS` environment variable

3. **Use Verification Tools**:
   - Run `node verify_firebase_connection.js` to check Firebase JavaScript connectivity
   - Run `python verify_firebase_production.py` to verify Python Firebase integration

### In-Memory Fallback

The application uses an in-memory Firebase implementation as a fallback when Firebase credentials are invalid or unavailable. This is useful for development but not recommended for production.

## Security Considerations

1. **Environment Variables**:
   - Never commit `.env` files to version control
   - Use environment variable management services in production

2. **API Keys**:
   - Restrict API keys in Firebase Console to specific domains
   - Set up proper authentication rules in Firebase

3. **User Data**:
   - Configure Firestore security rules to protect user data
   - Implement proper authentication flows

## Production Monitoring

1. **Firebase Console**:
   - Monitor app usage, errors, and performance in Firebase Console
   - Set up Firebase Alerts for critical issues

2. **Server Monitoring**:
   - Consider using PM2 or similar tools for Node.js process management
   - Set up health checks and automatic restarts

## Support

For additional assistance, refer to:
- [Firebase Documentation](https://firebase.google.com/docs)
- Project-specific documentation in the `docs` directory