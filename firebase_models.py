"""
Firebase data models for FarmAssistAI app.
This module handles all interactions with Firebase for data storage and retrieval.
"""
import os
import time
import datetime
import hashlib
import uuid
from typing import List, Dict, Any, Optional, Union
from firebase_init import firebase

# Constants
USERS_COLLECTION = 'users'
FIELDS_COLLECTION = 'fields'
DISEASE_REPORTS_COLLECTION = 'disease_reports'
MARKET_PRICES_COLLECTION = 'market_prices'
MARKET_FAVORITES_COLLECTION = 'market_favorites'
WEATHER_FORECASTS_COLLECTION = 'weather_forecasts'
CHAT_HISTORY_COLLECTION = 'chat_history'
IRRIGATION_RECORDS_COLLECTION = 'irrigation_records'
FERTILIZER_RECORDS_COLLECTION = 'fertilizer_records'

def generate_id() -> str:
    """Generate a unique ID for Firebase documents"""
    return str(uuid.uuid4())

class FirebaseModel:
    """Base class for Firebase models"""
    collection_name = None
    
    @classmethod
    def create(cls, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new document in the collection"""
        if 'created_at' not in data:
            data['created_at'] = datetime.datetime.utcnow().isoformat()
        
        if 'id' not in data:
            data['id'] = generate_id()
        
        doc_ref = firebase['db'].collection(cls.collection_name).document(data['id'])
        doc_ref.set(data)
        return data
    
    @classmethod
    def get(cls, doc_id: str) -> Optional[Dict[str, Any]]:
        """Get a document by ID"""
        doc_ref = firebase['db'].collection(cls.collection_name).document(doc_id)
        doc = doc_ref.get()
        return doc.to_dict() if doc.exists else None
    
    @classmethod
    def update(cls, doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Update a document by ID"""
        data['updated_at'] = datetime.datetime.utcnow().isoformat()
        doc_ref = firebase['db'].collection(cls.collection_name).document(doc_id)
        doc_ref.update(data)
        return cls.get(doc_id)
    
    @classmethod
    def delete(cls, doc_id: str) -> bool:
        """Delete a document by ID"""
        doc_ref = firebase['db'].collection(cls.collection_name).document(doc_id)
        doc_ref.delete()
        return True
    
    @classmethod
    def list(cls, filters: List[Dict[str, Any]] = None, order_by: str = None, 
             limit: int = None, direction: str = 'asc') -> List[Dict[str, Any]]:
        """List documents with optional filtering and ordering"""
        query = firebase['db'].collection(cls.collection_name)
        
        # Apply filters if provided
        if filters:
            for filter_dict in filters:
                field = filter_dict.get('field')
                op = filter_dict.get('op', '==')
                value = filter_dict.get('value')
                if field and value is not None:
                    query = query.where(field, op, value)
        
        # Apply ordering if provided
        if order_by:
            query = query.order_by(order_by, direction=direction)
        
        # Apply limit if provided
        if limit:
            query = query.limit(limit)
        
        # Execute query and convert to list of dicts
        docs = query.get()
        return [doc.to_dict() for doc in docs]

class User(FirebaseModel):
    """User model for Firebase"""
    collection_name = USERS_COLLECTION
    
    @classmethod
    def get_by_username(cls, username: str) -> Optional[Dict[str, Any]]:
        """Get a user by username"""
        query = firebase['db'].collection(cls.collection_name).where('username', '==', username)
        docs = query.get()
        return docs[0].to_dict() if docs else None
    
    @classmethod
    def get_by_email(cls, email: str) -> Optional[Dict[str, Any]]:
        """Get a user by email"""
        query = firebase['db'].collection(cls.collection_name).where('email', '==', email)
        docs = query.get()
        return docs[0].to_dict() if docs else None

class Field(FirebaseModel):
    """Field model for Firebase"""
    collection_name = FIELDS_COLLECTION
    
    @classmethod
    def get_by_user_id(cls, user_id: str) -> List[Dict[str, Any]]:
        """Get all fields for a user"""
        return cls.list([{'field': 'user_id', 'value': user_id}])

class DiseaseReport(FirebaseModel):
    """Disease report model for Firebase"""
    collection_name = DISEASE_REPORTS_COLLECTION
    
    @classmethod
    def get_by_user_id(cls, user_id: str) -> List[Dict[str, Any]]:
        """Get all disease reports for a user"""
        return cls.list([{'field': 'user_id', 'value': user_id}])
    
    @classmethod
    def get_by_field_id(cls, field_id: str) -> List[Dict[str, Any]]:
        """Get all disease reports for a field"""
        return cls.list([{'field': 'field_id', 'value': field_id}])

class MarketPrice(FirebaseModel):
    """Market price model for Firebase"""
    collection_name = MARKET_PRICES_COLLECTION
    
    @classmethod
    def get_by_crop_type(cls, crop_type: str) -> List[Dict[str, Any]]:
        """Get market prices for a crop type"""
        return cls.list([{'field': 'crop_type', 'value': crop_type}])
    
    @classmethod
    def get_latest(cls, crop_type: str = None) -> List[Dict[str, Any]]:
        """Get latest market prices, optionally filtered by crop type"""
        filters = []
        if crop_type:
            filters.append({'field': 'crop_type', 'value': crop_type})
        
        # Get today's date in ISO format
        today = datetime.datetime.utcnow().date().isoformat()
        filters.append({'field': 'date', 'op': '>=', 'value': today})
        
        return cls.list(filters=filters, order_by='date', direction='desc')

class MarketFavorite(FirebaseModel):
    """Market favorite model for Firebase"""
    collection_name = MARKET_FAVORITES_COLLECTION
    
    @classmethod
    def get_by_user_id(cls, user_id: str) -> List[Dict[str, Any]]:
        """Get all market favorites for a user"""
        return cls.list([{'field': 'user_id', 'value': user_id}])

class WeatherForecast(FirebaseModel):
    """Weather forecast model for Firebase"""
    collection_name = WEATHER_FORECASTS_COLLECTION
    
    @classmethod
    def get_by_location(cls, location: str) -> List[Dict[str, Any]]:
        """Get weather forecasts for a location"""
        today = datetime.datetime.utcnow().date().isoformat()
        filters = [
            {'field': 'location', 'value': location},
            {'field': 'forecast_date', 'op': '>=', 'value': today}
        ]
        return cls.list(filters=filters, order_by='forecast_date')
    
    @classmethod
    def delete_by_location(cls, location: str) -> bool:
        """Delete all weather forecasts for a location"""
        docs = firebase['db'].collection(cls.collection_name).where('location', '==', location).get()
        for doc in docs:
            doc.reference.delete()
        return True

class ChatHistory(FirebaseModel):
    """Chat history model for Firebase"""
    collection_name = CHAT_HISTORY_COLLECTION
    
    @classmethod
    def get_by_user_id(cls, user_id: str) -> List[Dict[str, Any]]:
        """Get all chat history for a user"""
        return cls.list([{'field': 'user_id', 'value': user_id}])
    
    @classmethod
    def get_by_session_id(cls, session_id: str) -> List[Dict[str, Any]]:
        """Get all chat history for a session"""
        return cls.list([{'field': 'session_id', 'value': session_id}])
    
    @classmethod
    def get_by_user_and_session(cls, user_id: str, session_id: str) -> List[Dict[str, Any]]:
        """Get chat history for a user and session"""
        filters = [
            {'field': 'user_id', 'value': user_id},
            {'field': 'session_id', 'value': session_id}
        ]
        return cls.list(filters=filters, order_by='timestamp')
    
    @classmethod
    def get_sessions(cls, user_id: str) -> List[Dict[str, Any]]:
        """Get unique session IDs for a user"""
        docs = firebase['db'].collection(cls.collection_name).where('user_id', '==', user_id).get()
        
        # Extract unique session IDs and their most recent timestamp
        sessions = {}
        for doc in docs:
            data = doc.to_dict()
            session_id = data.get('session_id')
            timestamp = data.get('timestamp')
            
            if session_id not in sessions or timestamp > sessions[session_id]['timestamp']:
                sessions[session_id] = {
                    'session_id': session_id,
                    'timestamp': timestamp,
                    'last_message': data.get('message', '')
                }
        
        # Convert to list and sort by timestamp (descending)
        return sorted(list(sessions.values()), key=lambda x: x['timestamp'], reverse=True)

class IrrigationRecord(FirebaseModel):
    """Irrigation record model for Firebase"""
    collection_name = IRRIGATION_RECORDS_COLLECTION
    
    @classmethod
    def get_by_field_id(cls, field_id: str) -> List[Dict[str, Any]]:
        """Get all irrigation records for a field"""
        return cls.list([{'field': 'field_id', 'value': field_id}])

class FertilizerRecord(FirebaseModel):
    """Fertilizer record model for Firebase"""
    collection_name = FERTILIZER_RECORDS_COLLECTION
    
    @classmethod
    def get_by_field_id(cls, field_id: str) -> List[Dict[str, Any]]:
        """Get all fertilizer records for a field"""
        return cls.list([{'field': 'field_id', 'value': field_id}])

# Additional utility functions for Firebase operations

def migrate_from_postgres_to_firebase():
    """Migrate all data from PostgreSQL to Firebase"""
    from models import (User as PgUser, Field as PgField, 
                        DiseaseReport as PgDiseaseReport,
                        MarketPrice as PgMarketPrice,
                        MarketFavorite as PgMarketFavorite,
                        WeatherForecast as PgWeatherForecast,
                        ChatHistory as PgChatHistory,
                        IrrigationRecord as PgIrrigationRecord,
                        FertilizerRecord as PgFertilizerRecord)
    from db_config import db
    
    # Migrate Users
    print("Migrating users to Firebase...")
    users = PgUser.query.all()
    for user in users:
        User.create({
            'id': str(user.id),
            'username': user.username,
            'email': user.email,
            'password_hash': user.password_hash,
            'full_name': user.full_name,
            'phone': user.phone,
            'created_at': user.created_at.isoformat() if user.created_at else None,
            'is_active': user.is_active,
            'profile_image': user.profile_image
        })
    
    # Migrate Fields
    print("Migrating fields to Firebase...")
    fields = PgField.query.all()
    for field in fields:
        Field.create({
            'id': str(field.id),
            'user_id': str(field.user_id),
            'name': field.name,
            'location': field.location,
            'area': field.area,
            'crop_type': field.crop_type,
            'planting_date': field.planting_date.isoformat() if field.planting_date else None,
            'soil_type': field.soil_type,
            'created_at': field.created_at.isoformat() if field.created_at else None,
            'last_updated': field.last_updated.isoformat() if field.last_updated else None,
            'notes': field.notes,
            'satellite_data': field.satellite_data,
            'weather_data': field.weather_data
        })
    
    # Migrate Disease Reports
    print("Migrating disease reports to Firebase...")
    reports = PgDiseaseReport.query.all()
    for report in reports:
        DiseaseReport.create({
            'id': str(report.id),
            'user_id': str(report.user_id),
            'field_id': str(report.field_id),
            'disease_name': report.disease_name,
            'detection_date': report.detection_date.isoformat() if report.detection_date else None,
            'confidence_score': report.confidence_score,
            'image_path': report.image_path,
            'symptoms': report.symptoms,
            'treatment_recommendations': report.treatment_recommendations,
            'status': report.status,
            'notes': report.notes
        })
    
    # Migrate Market Prices
    print("Migrating market prices to Firebase...")
    prices = PgMarketPrice.query.all()
    for price in prices:
        MarketPrice.create({
            'id': str(price.id),
            'crop_type': price.crop_type,
            'market_name': price.market_name,
            'price': price.price,
            'min_price': price.min_price,
            'max_price': price.max_price,
            'date': price.date.isoformat() if price.date else None,
            'source': price.source
        })
    
    # Migrate Market Favorites
    print("Migrating market favorites to Firebase...")
    favorites = PgMarketFavorite.query.all()
    for favorite in favorites:
        MarketFavorite.create({
            'id': str(favorite.id),
            'user_id': str(favorite.user_id),
            'crop_type': favorite.crop_type,
            'market_name': favorite.market_name,
            'price_alert_min': favorite.price_alert_min,
            'price_alert_max': favorite.price_alert_max
        })
    
    # Migrate Weather Forecasts
    print("Migrating weather forecasts to Firebase...")
    forecasts = PgWeatherForecast.query.all()
    for forecast in forecasts:
        WeatherForecast.create({
            'id': str(forecast.id),
            'location': forecast.location,
            'forecast_date': forecast.forecast_date.isoformat() if forecast.forecast_date else None,
            'temperature_min': forecast.temperature_min,
            'temperature_max': forecast.temperature_max,
            'humidity': forecast.humidity,
            'precipitation': forecast.precipitation,
            'wind_speed': forecast.wind_speed,
            'weather_description': forecast.weather_description,
            'updated_at': forecast.updated_at.isoformat() if forecast.updated_at else None
        })
    
    # Migrate Chat History
    print("Migrating chat history to Firebase...")
    chat_history = PgChatHistory.query.all()
    for chat in chat_history:
        ChatHistory.create({
            'id': str(chat.id),
            'user_id': chat.user_id,
            'session_id': chat.session_id,
            'message': chat.message,
            'sender': chat.sender,
            'timestamp': chat.timestamp.isoformat() if chat.timestamp else None,
            'context_data': chat.context_data
        })
    
    # Migrate Irrigation Records
    print("Migrating irrigation records to Firebase...")
    irrigation_records = PgIrrigationRecord.query.all()
    for record in irrigation_records:
        IrrigationRecord.create({
            'id': str(record.id),
            'field_id': str(record.field_id),
            'date': record.date.isoformat() if record.date else None,
            'amount': record.amount,
            'method': record.method,
            'duration': record.duration,
            'notes': record.notes
        })
    
    # Migrate Fertilizer Records
    print("Migrating fertilizer records to Firebase...")
    fertilizer_records = PgFertilizerRecord.query.all()
    for record in fertilizer_records:
        FertilizerRecord.create({
            'id': str(record.id),
            'field_id': str(record.field_id),
            'date': record.date.isoformat() if record.date else None,
            'fertilizer_type': record.fertilizer_type,
            'application_rate': record.application_rate,
            'method': record.method,
            'notes': record.notes
        })
    
    print("Migration to Firebase completed successfully!")