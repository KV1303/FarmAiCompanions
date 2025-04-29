import os
import time
from flask import Flask
from sqlalchemy.exc import OperationalError
from models import db, User, Field, DiseaseReport, IrrigationRecord, FertilizerRecord, MarketPrice, MarketFavorite, WeatherForecast

def init_db(app):
    """Initialize the database connection with better error handling and connection pooling"""
    # Get the database URL from environment variable
    db_url = os.environ.get('DATABASE_URL')
    print(f"Initializing database with connection URL: {db_url[:10]}...")
    
    # Configure SQLAlchemy
    app.config['SQLALCHEMY_DATABASE_URI'] = db_url
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
        'pool_recycle': 300,  # recycle connections after 5 minutes
        'pool_pre_ping': True  # test connections before using them
    }
    
    # Initialize the database
    db.init_app(app)
    
    # Set up connection retry logic with exponential backoff
    retry_count = 0
    max_retries = 3
    
    while retry_count < max_retries:
        try:
            # Create all tables if they don't exist
            with app.app_context():
                db.create_all()
                print("Database connection established and tables created successfully")
                break  # Success, exit the loop
        except OperationalError as e:
            retry_count += 1
            wait_time = 2 ** retry_count  # Exponential backoff
            print(f"Database connection error: {e}. Retrying in {wait_time} seconds (Attempt {retry_count}/{max_retries})")
            time.sleep(wait_time)
    
    if retry_count == max_retries:
        print("Failed to connect to database after multiple attempts")
    
    return db