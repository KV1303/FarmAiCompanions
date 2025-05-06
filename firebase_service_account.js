/**
 * Firebase Service Account Utility
 * 
 * This module provides a safer way to handle Firebase service account credentials,
 * particularly dealing with the challenges of private key formatting across different
 * environments.
 */

const fs = require('fs');
const path = require('path');

/**
 * Creates a properly formatted Firebase service account object from environment variables
 * @returns {Object} Firebase service account object
 */
function getServiceAccount() {
  // Get values from environment variables
  let {
    VITE_FIREBASE_PROJECT_ID: projectId,
    FIREBASE_CLIENT_EMAIL: clientEmail,
    FIREBASE_PRIVATE_KEY: privateKey,
    FIREBASE_CLIENT_ID: clientId,
    FIREBASE_CLIENT_CERT_URL: clientCertUrl
  } = process.env;

  // Log which values are available (without revealing actual values)
  console.log(`Firebase service account check:
    - Project ID: ${projectId ? '✓' : '✗'}
    - Client Email: ${clientEmail ? '✓' : '✗'}
    - Private Key: ${privateKey ? '✓' : '✗'}
    - Client ID: ${clientId ? '✓' : '✗'}
    - Client Cert URL: ${clientCertUrl ? '✓' : '✗'}`);

  // Try to properly format the private key
  if (privateKey) {
    try {
      // Remove any wrapper quotes (common when environment variables are JSON stringified)
      if (privateKey.startsWith('"') && privateKey.endsWith('"')) {
        privateKey = privateKey.substring(1, privateKey.length - 1);
      }

      // Replace literal '\n' with actual newlines
      privateKey = privateKey.replace(/\\n/g, '\n');

      // Verify PEM format
      if (!privateKey.includes('-----BEGIN PRIVATE KEY-----')) {
        privateKey = '-----BEGIN PRIVATE KEY-----\n' + privateKey;
      }
      if (!privateKey.includes('-----END PRIVATE KEY-----')) {
        privateKey = privateKey + '\n-----END PRIVATE KEY-----';
      }

      // Ensure proper PEM formatting
      const pemParts = privateKey.split('-----');
      if (pemParts.length >= 3) {
        const header = '-----' + pemParts[1] + '-----';
        const footer = '-----' + pemParts[3] + '-----';
        let content = pemParts[2].replace(/\s/g, ''); // Remove all whitespace

        // Add appropriate line breaks (every 64 characters as per PEM spec)
        const contentWithLineBreaks = content.match(/.{1,64}/g).join('\n');
        privateKey = `${header}\n${contentWithLineBreaks}\n${footer}`;
      }
    } catch (error) {
      console.error('Error formatting private key:', error.message);
    }
  } else {
    console.warn('No Firebase private key found in environment variables');
  }

  // Create the service account config
  const serviceAccount = {
    type: "service_account",
    project_id: projectId,
    private_key: privateKey,
    client_email: clientEmail,
    client_id: clientId,
    auth_uri: "https://accounts.google.com/o/oauth2/auth",
    token_uri: "https://oauth2.googleapis.com/token",
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
    client_x509_cert_url: clientCertUrl
  };

  // Check if minimum required fields are present
  const isValid = serviceAccount.project_id && 
                serviceAccount.private_key && 
                serviceAccount.client_email;

  if (!isValid) {
    console.warn('Generated service account is missing required fields');
  }

  return { serviceAccount, isValid };
}

/**
 * Create a temporary service account file for applications that require a file path
 * @returns {string|null} Path to the temporary file or null if creation failed
 */
function createServiceAccountFile() {
  try {
    const { serviceAccount, isValid } = getServiceAccount();
    
    if (!isValid) {
      console.error('Cannot create service account file: invalid credentials');
      return null;
    }

    // Create temporary directory if it doesn't exist
    const tempDir = path.join(__dirname, 'tmp');
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }

    // Write credentials to file
    const filePath = path.join(tempDir, 'firebase-service-account.json');
    fs.writeFileSync(filePath, JSON.stringify(serviceAccount, null, 2));
    
    console.log(`Service account file created at: ${filePath}`);
    return filePath;
  } catch (error) {
    console.error('Failed to create service account file:', error.message);
    return null;
  }
}

module.exports = {
  getServiceAccount,
  createServiceAccountFile
};