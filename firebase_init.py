import os
import json
import datetime
from collections import defaultdict

# Create a simple in-memory implementation for development/testing
class InMemoryFirebaseCollection:
    def __init__(self, name):
        self.name = name
        self.documents = []
        self.doc_id_counter = 1
    
    def add(self, data):
        doc_id = f"doc{self.doc_id_counter}"
        self.doc_id_counter += 1
        data['id'] = doc_id
        self.documents.append(data)
        print(f"Added document to {self.name} collection with ID: {doc_id}")
        return {'id': doc_id}
    
    def where(self, field, op, value):
        # Simple filtering implementation
        if op == '==':
            matching_docs = [doc for doc in self.documents if doc.get(field) == value]
        else:
            # For other operators, return all documents (simplified)
            matching_docs = self.documents
        
        # Return a query-like object that supports chaining
        return InMemoryFirebaseQuery(matching_docs)
    
    def get(self):
        # Return all documents in this collection
        return [InMemoryDocumentSnapshot(doc) for doc in self.documents]

class InMemoryFirebaseQuery:
    def __init__(self, documents):
        self.documents = documents
    
    def where(self, field, op, value):
        # Apply additional filtering
        if op == '==':
            self.documents = [doc for doc in self.documents if doc.get(field) == value]
        return self
    
    def order_by(self, field, direction='asc'):
        # Sort documents by the specified field
        reverse = direction == 'desc'
        self.documents = sorted(
            self.documents, 
            key=lambda doc: doc.get(field, ''), 
            reverse=reverse
        )
        return self
    
    def limit(self, count):
        # Limit the number of results
        self.documents = self.documents[:count]
        return self
    
    def get(self):
        # Return document snapshots
        return [InMemoryDocumentSnapshot(doc) for doc in self.documents]

class InMemoryDocumentSnapshot:
    def __init__(self, data):
        self.data = data
        self.id = data.get('id', 'unknown')
    
    def to_dict(self):
        return self.data

class InMemoryFirebaseDB:
    def __init__(self):
        self.collections = defaultdict(lambda: InMemoryFirebaseCollection(name='unknown'))
    
    def collection(self, name):
        if name not in self.collections:
            self.collections[name] = InMemoryFirebaseCollection(name)
        return self.collections[name]

# Try to import Firebase Admin SDK, but fall back to in-memory implementation if unavailable
try:
    import firebase_admin
    from firebase_admin import credentials, firestore, storage, auth
    FIREBASE_AVAILABLE = True
except ImportError:
    print("Firebase Admin SDK not available, using in-memory implementation")
    FIREBASE_AVAILABLE = False

def initialize_firebase():
    """Initialize Firebase Admin SDK for server-side operations or use in-memory implementation"""
    if not FIREBASE_AVAILABLE:
        print("Using in-memory Firebase implementation")
        return {
            'app': None,
            'db': InMemoryFirebaseDB(),
            'bucket': None,
            'auth': None,
            'is_memory_implementation': True
        }
    
    try:
        # Create a credential configuration dict
        private_key = os.environ.get('FIREBASE_PRIVATE_KEY')
        project_id = os.environ.get('VITE_FIREBASE_PROJECT_ID')
        
        # Process private key - handle different formats
        if private_key:
            # First try to fix common encoding issues
            if '\\n' in private_key:
                private_key = private_key.replace('\\n', '\n')
            # Handle if the key is missing proper line breaks
            if not private_key.startswith('-----BEGIN PRIVATE KEY-----'):
                private_key = "-----BEGIN PRIVATE KEY-----\n" + private_key
            if not private_key.endswith("-----END PRIVATE KEY-----"):
                private_key = private_key + "\n-----END PRIVATE KEY-----\n"
        
        print(f"Setting up Firebase with project ID: {project_id}")
        
        cred_config = {
            "type": "service_account",
            "project_id": project_id,
            "private_key": private_key,
            "client_email": os.environ.get('FIREBASE_CLIENT_EMAIL'),
            "client_id": os.environ.get('FIREBASE_CLIENT_ID'),
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": os.environ.get('FIREBASE_CLIENT_CERT_URL')
        }
        
        # Check if credentials are valid
        if not cred_config["private_key"] or not cred_config["client_email"]:
            print("Warning: Missing critical Firebase credentials. Using in-memory implementation.")
            return {
                'app': None,
                'db': InMemoryFirebaseDB(),
                'bucket': None,
                'auth': None,
                'is_memory_implementation': True
            }
        
        try:
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
                'auth': auth,
                'is_memory_implementation': False
            }
        except Exception as cred_error:
            print(f"Error initializing Firebase with credentials: {cred_error}")
            
            # Fall back to in-memory implementation
            print("Falling back to in-memory Firebase implementation")
            return {
                'app': None,
                'db': InMemoryFirebaseDB(),
                'bucket': None,
                'auth': None,
                'is_memory_implementation': True
            }
    
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        
        # Use in-memory implementation
        print("Using in-memory Firebase implementation")
        return {
            'app': None,
            'db': InMemoryFirebaseDB(),
            'bucket': None,
            'auth': None,
            'is_memory_implementation': True
        }

# Initialize Firebase 
firebase = initialize_firebase()