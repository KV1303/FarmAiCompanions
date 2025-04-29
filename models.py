import os
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship

db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(100))
    phone = Column(String(20))
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
    profile_image = Column(String(255))
    
    # Relationships
    fields = relationship('Field', back_populates='user', cascade='all, delete-orphan')
    disease_reports = relationship('DiseaseReport', back_populates='user', cascade='all, delete-orphan')
    market_favorites = relationship('MarketFavorite', back_populates='user', cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<User {self.username}>'

class Field(db.Model):
    __tablename__ = 'fields'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    name = Column(String(100), nullable=False)
    location = Column(String(255))  # Coordinates or address
    area = Column(Float)  # Size in hectares
    crop_type = Column(String(50))
    planting_date = Column(DateTime)
    soil_type = Column(String(50))
    created_at = Column(DateTime, default=datetime.utcnow)
    last_updated = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    notes = Column(Text)
    
    # JSON fields for additional data
    satellite_data = Column(JSON)  # For storing NDVI and other satellite data
    weather_data = Column(JSON)  # For storing weather history
    
    # Relationships
    user = relationship('User', back_populates='fields')
    disease_reports = relationship('DiseaseReport', back_populates='field', cascade='all, delete-orphan')
    irrigation_records = relationship('IrrigationRecord', back_populates='field', cascade='all, delete-orphan')
    fertilizer_records = relationship('FertilizerRecord', back_populates='field', cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<Field {self.name}>'

class DiseaseReport(db.Model):
    __tablename__ = 'disease_reports'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    field_id = Column(Integer, ForeignKey('fields.id'), nullable=False)
    disease_name = Column(String(100), nullable=False)
    detection_date = Column(DateTime, default=datetime.utcnow)
    confidence_score = Column(Float)  # AI detection confidence 0-1
    image_path = Column(String(255))  # Path to uploaded image
    symptoms = Column(Text)
    treatment_recommendations = Column(Text)
    status = Column(String(20), default='detected')  # detected, treating, resolved
    notes = Column(Text)
    
    # Relationships
    user = relationship('User', back_populates='disease_reports')
    field = relationship('Field', back_populates='disease_reports')
    
    def __repr__(self):
        return f'<DiseaseReport {self.disease_name}>'

class IrrigationRecord(db.Model):
    __tablename__ = 'irrigation_records'
    
    id = Column(Integer, primary_key=True)
    field_id = Column(Integer, ForeignKey('fields.id'), nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    amount = Column(Float)  # Amount in mm or liters
    method = Column(String(50))  # drip, sprinkler, flood, etc.
    duration = Column(Integer)  # Duration in minutes
    notes = Column(Text)
    
    # Relationships
    field = relationship('Field', back_populates='irrigation_records')
    
    def __repr__(self):
        return f'<IrrigationRecord {self.date}>'

class FertilizerRecord(db.Model):
    __tablename__ = 'fertilizer_records'
    
    id = Column(Integer, primary_key=True)
    field_id = Column(Integer, ForeignKey('fields.id'), nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    fertilizer_type = Column(String(100))  # NPK ratio or organic type
    application_rate = Column(Float)  # kg/ha
    method = Column(String(50))  # broadcast, foliar, etc.
    notes = Column(Text)
    
    # Relationships
    field = relationship('Field', back_populates='fertilizer_records')
    
    def __repr__(self):
        return f'<FertilizerRecord {self.date}>'

class MarketPrice(db.Model):
    __tablename__ = 'market_prices'
    
    id = Column(Integer, primary_key=True)
    crop_type = Column(String(50), nullable=False)
    market_name = Column(String(100), nullable=False)
    price = Column(Float, nullable=False)  # Price per quintal
    min_price = Column(Float)
    max_price = Column(Float)
    date = Column(DateTime, default=datetime.utcnow)
    source = Column(String(100))  # eNAM, local market, etc.
    
    def __repr__(self):
        return f'<MarketPrice {self.crop_type} {self.market_name}>'

class MarketFavorite(db.Model):
    __tablename__ = 'market_favorites'
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    crop_type = Column(String(50), nullable=False)
    market_name = Column(String(100))
    price_alert_min = Column(Float)  # Optional min price alert
    price_alert_max = Column(Float)  # Optional max price alert
    
    # Relationships
    user = relationship('User', back_populates='market_favorites')
    
    def __repr__(self):
        return f'<MarketFavorite {self.crop_type}>'

class WeatherForecast(db.Model):
    __tablename__ = 'weather_forecasts'
    
    id = Column(Integer, primary_key=True)
    location = Column(String(100), nullable=False)
    forecast_date = Column(DateTime, nullable=False)
    temperature_min = Column(Float)
    temperature_max = Column(Float)
    humidity = Column(Float)
    precipitation = Column(Float)
    wind_speed = Column(Float)
    weather_description = Column(String(100))
    updated_at = Column(DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<WeatherForecast {self.location} {self.forecast_date}>'