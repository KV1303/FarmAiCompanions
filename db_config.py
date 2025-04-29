import os
from flask import Flask
from models import db, User, Field, DiseaseReport, IrrigationRecord, FertilizerRecord, MarketPrice, MarketFavorite, WeatherForecast

def init_db(app):
    """Initialize the database connection"""
    # Get the database URL from environment variable
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    
    # Initialize the database
    db.init_app(app)
    
    # Create all tables if they don't exist
    with app.app_context():
        db.create_all()
        
    return db