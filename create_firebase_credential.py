#!/usr/bin/env python3

"""
Firebase Credential Manager

This script creates a Firebase service account key file from environment variables,
which can be used for applications that require a file path for authentication.
"""

import os
import json
import base64
import sys
from pathlib import Path

def fix_private_key(private_key):
    """Fix common formatting issues with Firebase private keys"""
    if not private_key:
        return None
    
    try:
        # Remove enclosing quotes if present
        if private_key.startswith('"') and private_key.endswith('"'):
            private_key = private_key[1:-1]
        
        # Replace escaped newlines with actual newlines
        if '\\n' in private_key:
            private_key = private_key.replace('\\n', '\n')
        
        # Add PEM header/footer if missing
        if '-----BEGIN PRIVATE KEY-----' not in private_key:
            private_key = '-----BEGIN PRIVATE KEY-----\n' + private_key
        
        if '-----END PRIVATE KEY-----' not in private_key:
            private_key = private_key + '\n-----END PRIVATE KEY-----'
        
        # Ensure proper PEM formatting
        if '-\n' not in private_key:
            parts = private_key.split('-----')
            if len(parts) >= 3:
                # Extract the base64 content
                base64_content = parts[2].strip()
                
                # Ensure proper line wrapping (every 64 characters)
                wrapped_content = '\n'.join([base64_content[i:i+64] for i in range(0, len(base64_content), 64)])
                
                # Reconstruct the private key
                private_key = f"-----{parts[1]}-----\n{wrapped_content}\n-----{parts[3]}-----"
        
        return private_key
    except Exception as e:
        print(f"Error fixing private key: {e}")
        return private_key

def create_service_account_file():
    """Create a Firebase service account key file from environment variables"""
    # Get environment variables
    project_id = os.environ.get('VITE_FIREBASE_PROJECT_ID')
    client_email = os.environ.get('FIREBASE_CLIENT_EMAIL')
    private_key = os.environ.get('FIREBASE_PRIVATE_KEY')
    client_id = os.environ.get('FIREBASE_CLIENT_ID')
    client_x509_cert_url = os.environ.get('FIREBASE_CLIENT_CERT_URL')
    
    # Check for required values
    if not project_id or not client_email or not private_key:
        print("Error: Missing required Firebase credentials")
        print(f"  - Project ID: {'✓' if project_id else '✗'}")
        print(f"  - Client Email: {'✓' if client_email else '✗'}")
        print(f"  - Private Key: {'✓' if private_key else '✗'}")
        return False
    
    # Fix private key formatting
    fixed_private_key = fix_private_key(private_key)
    
    # Create service account object
    service_account = {
        "type": "service_account",
        "project_id": project_id,
        "private_key": fixed_private_key,
        "client_email": client_email,
        "client_id": client_id,
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": client_x509_cert_url
    }
    
    # Create temp directory if it doesn't exist
    tmp_dir = Path('tmp')
    tmp_dir.mkdir(exist_ok=True)
    
    # Write to file
    credential_path = tmp_dir / 'firebase-service-account.json'
    with open(credential_path, 'w') as f:
        json.dump(service_account, f, indent=2)
    
    print(f"✅ Firebase service account file created at: {credential_path}")
    
    # Create environment variable pointing to this file
    print("\nTo use this file, set the following environment variable:")
    print(f"GOOGLE_APPLICATION_CREDENTIALS={os.path.abspath(credential_path)}")
    
    return True

if __name__ == "__main__":
    success = create_service_account_file()
    sys.exit(0 if success else 1)