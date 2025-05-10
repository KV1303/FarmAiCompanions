#!/usr/bin/env python3
"""
Firebase Production Verification Tool

This script ensures that Firebase is properly configured for production use
by validating connectivity and access to all required services.
"""

import os
import sys
import time
import json
from pathlib import Path

# Set production environment variables
os.environ['NODE_ENV'] = 'production'
os.environ['FLASK_ENV'] = 'production'

# Import Firebase initialization after setting environment variables
import firebase_init

def check_environment_variables():
    """Check if all required Firebase environment variables are set"""
    required_vars = [
        'VITE_FIREBASE_API_KEY',
        'VITE_FIREBASE_PROJECT_ID',
        'VITE_FIREBASE_APP_ID',
        'FIREBASE_AUTH_DOMAIN',
        'FIREBASE_STORAGE_BUCKET',
        'FIREBASE_PRIVATE_KEY',
        'FIREBASE_CLIENT_EMAIL',
        'FIREBASE_CLIENT_ID',
        'FIREBASE_CLIENT_CERT_URL',
        'GEMINI_API_KEY'
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.environ.get(var):
            missing_vars.append(var)
    
    if missing_vars:
        print("❌ Missing required environment variables:")
        for var in missing_vars:
            print(f"  - {var}")
        return False
    
    print("✅ All required environment variables are set")
    return True

def verify_firebase_services():
    """Verify Firebase services initialization and connectivity"""
    try:
        print("Initializing Firebase in production mode...")
        firebase = firebase_init.initialize_firebase()
        
        if firebase['is_memory_implementation']:
            print("❌ Firebase is using in-memory implementation in production mode!")
            print("   This indicates that Firebase credentials are invalid or missing.")
            return False
        
        print("✅ Firebase initialized successfully with real implementation")
        
        # Test a write operation to verify database access
        db = firebase['db']
        test_collection = db.collection('production_verification')
        test_doc = test_collection.document('test_doc')
        timestamp = int(time.time())
        
        print("Testing Firestore write operation...")
        test_doc.set({
            'timestamp': timestamp,
            'message': 'Production verification test',
            'verified': True
        })
        
        # Verify the write by reading it back
        print("Testing Firestore read operation...")
        read_data = test_doc.get()
        if not read_data.exists:
            print("❌ Failed to read test document")
            return False
            
        data = read_data.to_dict()
        if data.get('timestamp') != timestamp:
            print("❌ Test document data mismatch")
            return False
            
        print("✅ Firestore read/write test passed")
        
        # Clean up test document
        test_doc.delete()
        print("✅ Test document cleaned up")
        
        return True
        
    except Exception as e:
        print(f"❌ Firebase verification failed: {str(e)}")
        return False

def run_verification():
    """Run all verification checks"""
    print("=" * 60)
    print("Firebase Production Verification Tool")
    print("=" * 60)
    
    # Step 1: Check environment variables
    print("\n1. Checking environment variables...")
    env_check = check_environment_variables()
    
    # Step 2: Verify Firebase services
    print("\n2. Verifying Firebase services...")
    firebase_check = verify_firebase_services()
    
    # Final status
    print("\n" + "=" * 60)
    if env_check and firebase_check:
        print("✅ SUCCESS: Firebase is properly configured for production")
        print("=" * 60)
        return 0
    else:
        print("❌ FAILED: Firebase configuration needs attention")
        print("Please check the errors above and fix the issues before deploying to production")
        print("See PRODUCTION.md for Firebase setup instructions")
        print("=" * 60)
        return 1

if __name__ == "__main__":
    sys.exit(run_verification())