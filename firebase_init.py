import os
import json
import datetime
import subprocess
import sys
from pathlib import Path
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
    
    def document(self, doc_id=None):
        # If no doc_id is provided, generate a new one
        if doc_id is None:
            doc_id = f"doc{self.doc_id_counter}"
            self.doc_id_counter += 1
        
        # Create and return a document reference
        return InMemoryDocumentReference(self, doc_id)
    
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

class InMemoryDocumentReference:
    def __init__(self, collection, doc_id):
        self.collection = collection
        self.id = doc_id
        self.data = None
    
    def set(self, data):
        # Add ID to the data
        data['id'] = self.id
        
        # Check if document already exists
        for i, doc in enumerate(self.collection.documents):
            if doc.get('id') == self.id:
                # Update existing document
                self.collection.documents[i] = data
                self.data = data
                return self
        
        # Add new document
        self.collection.documents.append(data)
        self.data = data
        return self
    
    def get(self):
        # Find document by ID
        for doc in self.collection.documents:
            if doc.get('id') == self.id:
                snapshot = InMemoryDocumentSnapshot(doc)
                snapshot.reference = self
                return snapshot
        # Return empty snapshot for non-existent documents
        empty_snapshot = InMemoryDocumentSnapshot(None)
        empty_snapshot.reference = self
        return empty_snapshot
    
    def delete(self):
        # Remove document by ID
        self.collection.documents = [
            doc for doc in self.collection.documents 
            if doc.get('id') != self.id
        ]
        return True

class InMemoryDocumentSnapshot:
    def __init__(self, data):
        self.data = data
        self.id = data.get('id', 'unknown') if data else 'unknown'
        self.reference = None  # This will be set by the caller if needed
    
    def to_dict(self):
        return self.data if self.data else None
    
    def exists(self):
        return self.data is not None

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
            try:
                # Check if the key is JSON-encoded with quotes (common in some env platforms)
                if private_key.startswith('"') and private_key.endswith('"'):
                    private_key = private_key[1:-1]  # Remove enclosing quotes
                
                # First try to fix common encoding issues
                if '\\n' in private_key:
                    private_key = private_key.replace('\\n', '\n')
                
                # Make sure we have the BEGIN/END markers with proper formatting
                if '-----BEGIN PRIVATE KEY-----' not in private_key:
                    private_key = "-----BEGIN PRIVATE KEY-----\n" + private_key
                
                if '-----END PRIVATE KEY-----' not in private_key:
                    private_key = private_key + "\n-----END PRIVATE KEY-----\n"
                
                # Ensure proper line wrapping for PEM format
                if '-\n' not in private_key:
                    # Add line breaks every 64 characters in the base64 part
                    parts = private_key.split('-----')
                    if len(parts) >= 3:
                        base64_part = parts[2].strip()
                        wrapped_base64 = '\n'.join([base64_part[i:i+64] for i in range(0, len(base64_part), 64)])
                        private_key = "-----" + parts[1] + "-----\n" + wrapped_base64 + "\n-----" + parts[3] + "-----"
            except Exception as e:
                print(f"Error processing private key: {e}")
                # If we can't process the key, provide a clearer error
                print("Private key format may be incorrect. Please check your FIREBASE_PRIVATE_KEY environment variable.")
        
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
            
            # Try file-based approach by creating a service account file
            try:
                print("Attempting to create and use a service account file...")
                
                # Create temp directory if needed
                tmp_dir = Path('tmp')
                if not tmp_dir.exists():
                    tmp_dir.mkdir(parents=True)
                
                # Generate the service account file using our helper script
                credential_path = tmp_dir / 'firebase-service-account.json'
                
                # Check if our helper script exists and use it
                helper_script = Path('create_firebase_credential.py')
                if helper_script.exists():
                    # Run the helper script to generate the credential file
                    result = subprocess.run([sys.executable, str(helper_script)], 
                                          capture_output=True, text=True)
                    if result.returncode != 0:
                        print(f"Error running credential helper: {result.stderr}")
                        raise Exception("Failed to create service account file")
                else:
                    # Manually create the file
                    with open(credential_path, 'w') as f:
                        json.dump(cred_config, f, indent=2)
                
                # Set environment variable for the file path
                os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = str(credential_path.absolute())
                print(f"Set GOOGLE_APPLICATION_CREDENTIALS to {credential_path.absolute()}")
                
                # Try initializing with the file
                firebase_app = firebase_admin.initialize_app()
                print("Firebase Admin SDK initialized with service account file")
                
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
            except Exception as file_error:
                print(f"Service account file approach failed: {file_error}")
                
                # Final attempt with application default credentials
                try:
                    print("Attempting to use application default credentials...")
                    firebase_app = firebase_admin.initialize_app()
                    
                    # Initialize services
                    db = firestore.client()
                    bucket = storage.bucket()
                    
                    print("Firebase Admin SDK initialized with application default credentials")
                    return {
                        'app': firebase_app,
                        'db': db,
                        'bucket': bucket,
                        'auth': auth,
                        'is_memory_implementation': False
                    }
                except Exception as adc_error:
                    print(f"Application default credentials failed: {adc_error}")
                    
                    # Fall back to in-memory implementation
                    print("Falling back to in-memory Firebase implementation")
                    return {
                        'app': None,
                        'db': InMemoryFirebaseDB(),
                        'bucket': None,
                        'auth': None,
                        'is_memory_implementation': True
                    }
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