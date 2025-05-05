import os
import json
import firebase_admin
from firebase_admin import credentials, firestore, storage, auth

def initialize_firebase():
    """Initialize Firebase Admin SDK for server-side operations"""
    try:
        # Create a credential configuration dict
        cred_config = {
            "type": "service_account",
            "project_id": os.environ.get('VITE_FIREBASE_PROJECT_ID'),
            "private_key": os.environ.get('FIREBASE_PRIVATE_KEY').replace('\\n', '\n') if os.environ.get('FIREBASE_PRIVATE_KEY') else None,
            "client_email": os.environ.get('FIREBASE_CLIENT_EMAIL'),
            "client_id": os.environ.get('FIREBASE_CLIENT_ID'),
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": os.environ.get('FIREBASE_CLIENT_CERT_URL')
        }
        
        # Check if credentials are valid
        if None in [cred_config["private_key"], cred_config["client_email"]]:
            print("Warning: Missing critical Firebase credentials. Some features may not work.")
        
        # Initialize with Firebase credentials
        cred = credentials.Certificate(cred_config)
        firebase_app = firebase_admin.initialize_app(cred, {
            'storageBucket': os.environ.get('FIREBASE_STORAGE_BUCKET'),
            'databaseURL': os.environ.get('FIREBASE_DATABASE_URL')
        })
        
        print("Firebase Admin SDK initialized successfully")
        
        # Initialize services
        db = firestore.client()
        bucket = storage.bucket()
        
        return {
            'app': firebase_app,
            'db': db,
            'bucket': bucket,
            'auth': auth
        }
    
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        
        # Try minimal initialization for development/testing
        try:
            firebase_app = firebase_admin.initialize_app()
            print("Firebase initialized with minimal configuration")
            db = firestore.client()
            bucket = None
            
            return {
                'app': firebase_app,
                'db': db,
                'bucket': bucket,
                'auth': auth
            }
        except Exception as fallback_error:
            print(f"Failed to initialize Firebase with minimal config: {fallback_error}")
            return None

# Initialize Firebase 
firebase = initialize_firebase()