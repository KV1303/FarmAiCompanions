import os
import json
import requests
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai

from db_config import init_db
from models import db, User, Field, DiseaseReport, IrrigationRecord, FertilizerRecord, MarketPrice, MarketFavorite, WeatherForecast

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS

# Initialize database
db = init_db(app)

# Configure Google Gemini API if API key is available
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

# ------ API Routes ------

@app.route('/api/weather', methods=['GET'])
def get_weather():
    """Get weather forecast for a location"""
    location = request.args.get('location', 'New Delhi')
    
    # Try to fetch from database first
    today = datetime.utcnow().date()
    forecasts = WeatherForecast.query.filter(
        WeatherForecast.location == location,
        WeatherForecast.forecast_date >= today
    ).order_by(WeatherForecast.forecast_date).all()
    
    # If we have forecasts and they're recent, return them
    if forecasts and (datetime.utcnow() - forecasts[0].updated_at).total_seconds() < 86400:  # 24 hours
        return jsonify({
            'location': location,
            'forecasts': [{
                'date': f.forecast_date.strftime('%Y-%m-%d'),
                'temp_min': f.temperature_min,
                'temp_max': f.temperature_max,
                'humidity': f.humidity,
                'precipitation': f.precipitation,
                'wind_speed': f.wind_speed,
                'description': f.weather_description
            } for f in forecasts]
        })
    
    # Otherwise, try to fetch from a weather API (placeholder for now)
    # In a real app, you would use OpenWeatherMap, Weather.gov, etc.
    try:
        # Simulated API call response
        forecasts_data = [
            {
                'date': (today + timedelta(days=i)).strftime('%Y-%m-%d'),
                'temp_min': 20 + i,
                'temp_max': 30 + i,
                'humidity': 65 - i,
                'precipitation': 0.1 * i,
                'wind_speed': 10 + (i % 5),
                'description': 'Partly cloudy'
            } for i in range(7)
        ]
        
        # Store in database
        for forecast in forecasts_data:
            forecast_date = datetime.strptime(forecast['date'], '%Y-%m-%d')
            db_forecast = WeatherForecast.query.filter_by(
                location=location, 
                forecast_date=forecast_date
            ).first()
            
            if not db_forecast:
                db_forecast = WeatherForecast(
                    location=location,
                    forecast_date=forecast_date
                )
                
            db_forecast.temperature_min = forecast['temp_min']
            db_forecast.temperature_max = forecast['temp_max']
            db_forecast.humidity = forecast['humidity']
            db_forecast.precipitation = forecast['precipitation']
            db_forecast.wind_speed = forecast['wind_speed']
            db_forecast.weather_description = forecast['description']
            db_forecast.updated_at = datetime.utcnow()
            
            db.session.add(db_forecast)
        
        db.session.commit()
        
        return jsonify({
            'location': location,
            'forecasts': forecasts_data
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/market_prices', methods=['GET'])
def get_market_prices():
    """Get market prices for crops"""
    crop_type = request.args.get('crop_type')
    
    # Query from database
    query = MarketPrice.query
    if crop_type:
        query = query.filter_by(crop_type=crop_type)
    
    # Get today's data, or latest if none today
    today = datetime.utcnow().date()
    prices = query.filter(MarketPrice.date >= today).all()
    
    if not prices:
        # Get latest records
        latest_date = db.session.query(db.func.max(MarketPrice.date)).scalar()
        if latest_date:
            prices = query.filter(MarketPrice.date == latest_date).all()
    
    # If still no data, try to fetch from external API
    if not prices:
        try:
            # Placeholder for eNAM API call
            # In a real app, you would call the official eNAM API
            dummy_crops = ['Rice', 'Wheat', 'Cotton', 'Sugarcane', 'Maize']
            dummy_markets = ['Delhi', 'Mumbai', 'Kolkata', 'Chennai', 'Lucknow']
            
            for crop in dummy_crops:
                if crop_type and crop != crop_type:
                    continue
                    
                for market in dummy_markets:
                    base_price = 1500 + (hash(crop) % 1000)  # Simulate different base prices
                    price = MarketPrice(
                        crop_type=crop,
                        market_name=market,
                        price=base_price + (hash(market) % 200),
                        min_price=base_price - 100,
                        max_price=base_price + 300,
                        date=datetime.utcnow(),
                        source='eNAM (simulated)'
                    )
                    db.session.add(price)
                    prices.append(price)
            
            db.session.commit()
            
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    # Return JSON response
    return jsonify({
        'prices': [{
            'id': p.id,
            'crop_type': p.crop_type,
            'market_name': p.market_name,
            'price': p.price,
            'min_price': p.min_price,
            'max_price': p.max_price,
            'date': p.date.strftime('%Y-%m-%d'),
            'source': p.source
        } for p in prices]
    })

@app.route('/api/disease_detect', methods=['POST'])
def detect_disease():
    """Detect crop disease from image using AI"""
    # Check how the image is provided
    data = request.get_json() if request.is_json else None
    
    if data and 'image_path' in data:
        # Image already uploaded, use the provided path
        image_path = data['image_path']
        crop_type = data.get('crop_type', 'unknown')
        field_id = data.get('field_id')
        user_id = data.get('user_id')
        
        print(f"Using pre-uploaded image: {image_path}")
        
        if not os.path.exists(image_path):
            return jsonify({'error': f'Image file not found at path: {image_path}'}), 400
    
    elif 'image' in request.files:
        # Direct image upload
        image = request.files['image']
        crop_type = request.form.get('crop_type', 'unknown')
        field_id = request.form.get('field_id')
        user_id = request.form.get('user_id')
        
        if not image.filename:
            return jsonify({'error': 'Empty image file'}), 400
            
        # Save the image to a temporary location
        image_path = f"uploads/{datetime.utcnow().strftime('%Y%m%d%H%M%S')}_{image.filename}"
        os.makedirs('uploads', exist_ok=True)
        image.save(image_path)
        
        print(f"Image uploaded and saved to: {image_path}")
    
    else:
        # No image provided
        return jsonify({'error': 'No image provided. Send either an image file or an image_path.'}), 400
    
    # AI detection logic - using Gemini API if available
    disease_name = "Unknown Disease"
    confidence = 0.0
    symptoms = ""
    treatment = ""
    
    try:
        if GEMINI_API_KEY:
            # Use Gemini for image analysis
            model = genai.GenerativeModel('gemini-pro-vision')
            
            with open(image_path, 'rb') as f:
                image_data = f.read()
            
            response = model.generate_content([
                "Analyze this crop image and identify any diseases. If a disease is present, provide:\n"
                "1. Disease name\n"
                "2. Confidence level (as a decimal between 0.0 and 1.0)\n"
                "3. Symptoms visible in the image\n"
                "4. Recommended treatments\n\n"
                f"Crop type: {crop_type}",
                {"mime_type": "image/jpeg", "data": image_data}
            ])
            
            # Parse the response
            analysis = response.text
            
            # Simple parsing - in a real app you'd want more robust extraction
            if "Disease name:" in analysis:
                disease_name = analysis.split("Disease name:")[1].split("\n")[0].strip()
                confidence = 0.85  # Default high confidence
                
                if "Confidence level:" in analysis:
                    conf_text = analysis.split("Confidence level:")[1].split("\n")[0].strip()
                    try:
                        # Try to extract a decimal confidence
                        conf_text = conf_text.replace("%", "").strip()
                        if "/" in conf_text:
                            num, denom = conf_text.split("/")
                            confidence = float(num) / float(denom)
                        else:
                            confidence = float(conf_text)
                            if confidence > 1:  # If it's a percentage
                                confidence /= 100
                    except:
                        pass  # Keep default confidence
                
                if "Symptoms:" in analysis:
                    symptoms = analysis.split("Symptoms:")[1].split("Recommended treatments:")[0].strip()
                    
                if "Recommended treatments:" in analysis:
                    treatment = analysis.split("Recommended treatments:")[1].strip()
        else:
            # Fallback detection
            # This is a simple simulation - in a real app without AI, you would
            # use computer vision or other detection methods
            common_diseases = {
                "rice": ["Rice Blast", "Brown Spot", "Bacterial Leaf Blight"],
                "wheat": ["Wheat Rust", "Powdery Mildew", "Septoria Leaf Spot"],
                "cotton": ["Cotton Boll Rot", "Verticillium Wilt", "Target Spot"],
                "tomato": ["Early Blight", "Late Blight", "Leaf Mold"],
                "potato": ["Late Blight", "Early Blight", "Black Scurf"]
            }
            
            crop = crop_type.lower()
            if crop in common_diseases:
                import random
                disease_index = hash(image_path) % len(common_diseases[crop])
                disease_name = common_diseases[crop][disease_index]
                confidence = 0.7  # Moderate confidence
                symptoms = f"Visible symptoms include discoloration and lesions typical of {disease_name}."
                treatment = f"Recommended treatment includes fungicide application and improved field drainage. Consult a local agricultural extension for specific treatments for {disease_name}."
            else:
                disease_name = "Possible Disease Detected"
                confidence = 0.5
                symptoms = "Some discoloration and spots visible on leaves."
                treatment = "Recommend consulting with a local agricultural extension for proper diagnosis and treatment."
    
    except Exception as e:
        return jsonify({'error': f'Disease detection failed: {str(e)}'}), 500
    
    # Save to database if user_id and field_id provided
    report = None
    if user_id and field_id:
        try:
            report = DiseaseReport(
                user_id=user_id,
                field_id=field_id,
                disease_name=disease_name,
                confidence_score=confidence,
                image_path=image_path,
                symptoms=symptoms,
                treatment_recommendations=treatment,
                status='detected'
            )
            db.session.add(report)
            db.session.commit()
        except Exception as e:
            return jsonify({'error': f'Failed to save report: {str(e)}'}), 500
    
    # Return detection results
    result = {
        'disease_name': disease_name,
        'confidence': confidence,
        'symptoms': symptoms,
        'treatment': treatment,
        'image_path': image_path
    }
    
    if report:
        result['report_id'] = report.id
    
    return jsonify(result)

@app.route('/api/field_monitoring', methods=['GET'])
def get_field_monitoring():
    """Get field monitoring data (NDVI, etc.) using Farmonaut API"""
    field_id = request.args.get('field_id')
    
    if not field_id:
        return jsonify({'error': 'Field ID is required'}), 400
    
    # Get field from database
    field = Field.query.get(field_id)
    if not field:
        return jsonify({'error': 'Field not found'}), 404
    
    # Check if we have cached satellite data
    if field.satellite_data and (datetime.utcnow() - field.last_updated).days < 7:
        return jsonify(field.satellite_data)
    
    # In a real app, you would call the Farmonaut API here
    # For now, we'll create simulated data
    try:
        # Simulated satellite data
        current_day = datetime.utcnow().day
        ndvi_value = (current_day % 5) * 0.1 + 0.5  # NDVI between 0.5 and 0.9
        
        satellite_data = {
            'ndvi': ndvi_value,
            'field_health': 'Good' if ndvi_value > 0.7 else 'Fair',
            'last_updated': datetime.utcnow().strftime('%Y-%m-%d'),
            'time_series': [
                {
                    'date': (datetime.utcnow() - timedelta(days=i*7)).strftime('%Y-%m-%d'),
                    'ndvi': max(0.2, ndvi_value - (i * 0.05))
                } for i in range(6)
            ],
            'crop_stage': 'Vegetative',
            'estimated_yield': f'{70 + int(ndvi_value * 30)}%',
            'anomalies': []
        }
        
        # If NDVI below threshold, add anomaly
        if ndvi_value < 0.6:
            satellite_data['anomalies'].append({
                'type': 'Low NDVI',
                'location': 'North-East section',
                'severity': 'Moderate',
                'recommendation': 'Check for water stress or nutrient deficiency'
            })
        
        # Update field in database
        field.satellite_data = satellite_data
        field.last_updated = datetime.utcnow()
        db.session.commit()
        
        return jsonify(satellite_data)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/fertilizer_recommendations', methods=['GET'])
def get_fertilizer_recommendations():
    """Get AI-powered fertilizer recommendations"""
    field_id = request.args.get('field_id')
    
    if not field_id:
        return jsonify({'error': 'Field ID is required'}), 400
    
    # Get field from database
    field = Field.query.get(field_id)
    if not field:
        return jsonify({'error': 'Field not found'}), 404
    
    try:
        # Use Gemini if available for advanced recommendations
        if GEMINI_API_KEY:
            model = genai.GenerativeModel('gemini-pro')
            
            # Prepare context for the model
            context = (
                f"Field Information:\n"
                f"- Crop Type: {field.crop_type or 'Unknown'}\n"
                f"- Soil Type: {field.soil_type or 'Unknown'}\n"
                f"- Planting Date: {field.planting_date.strftime('%Y-%m-%d') if field.planting_date else 'Unknown'}\n"
                f"- Field Size: {field.area or 0} hectares\n"
            )
            
            # Add satellite data if available
            if field.satellite_data:
                context += (
                    f"- Current NDVI: {field.satellite_data.get('ndvi', 'Unknown')}\n"
                    f"- Field Health: {field.satellite_data.get('field_health', 'Unknown')}\n"
                    f"- Crop Stage: {field.satellite_data.get('crop_stage', 'Unknown')}\n"
                )
            
            # Add recent fertilizer applications if any
            recent_applications = FertilizerRecord.query.filter_by(field_id=field.id).order_by(FertilizerRecord.date.desc()).limit(3).all()
            if recent_applications:
                context += "\nRecent Fertilizer Applications:\n"
                for app in recent_applications:
                    context += f"- {app.date.strftime('%Y-%m-%d')}: {app.fertilizer_type} at {app.application_rate} kg/ha\n"
            
            # Generate fertilizer recommendations
            prompt = (
                f"{context}\n\n"
                "Based on the above information, provide fertilizer recommendations including:\n"
                "1. Recommended fertilizer types\n"
                "2. Application rates in kg/hectare\n"
                "3. Timing of application\n"
                "4. Application method\n"
                "5. Special considerations for this crop and soil type"
            )
            
            response = model.generate_content(prompt)
            recommendations = response.text
            
            return jsonify({
                'field_id': field.id,
                'crop_type': field.crop_type,
                'recommendations': recommendations,
                'generated_by': 'Google Gemini AI'
            })
            
        else:
            # Fallback basic recommendations based on crop type
            recommendations = {}
            
            if field.crop_type:
                crop = field.crop_type.lower()
                
                if 'rice' in crop:
                    recommendations = {
                        'npk_ratio': '14-14-14',
                        'rate': '300-350 kg/ha',
                        'timing': 'Apply 50% at planting, 25% during tillering, and 25% at panicle initiation',
                        'method': 'Broadcast application before planting, followed by top dressing',
                        'notes': 'Ensure good water management. Consider zinc supplements in deficient soils.'
                    }
                elif 'wheat' in crop:
                    recommendations = {
                        'npk_ratio': '12-32-16',
                        'rate': '250-300 kg/ha',
                        'timing': 'Apply 50% at sowing and 50% at first irrigation',
                        'method': 'Incorporate into soil before sowing, top dress remainder',
                        'notes': 'Additional nitrogen application may be needed at heading stage if crop shows deficiency.'
                    }
                elif 'cotton' in crop:
                    recommendations = {
                        'npk_ratio': '20-10-10',
                        'rate': '200-250 kg/ha',
                        'timing': 'Apply 30% at planting, 40% at square formation, 30% at flowering',
                        'method': 'Side-dress or band application',
                        'notes': 'Consider foliar application of micronutrients during peak growth.'
                    }
                else:
                    recommendations = {
                        'npk_ratio': '15-15-15',
                        'rate': '300 kg/ha',
                        'timing': 'Apply 50% at planting and 50% during vegetative growth',
                        'method': 'Broadcast and incorporate into soil',
                        'notes': 'Consult local extension service for specific recommendations for your crop and soil type.'
                    }
            else:
                recommendations = {
                    'npk_ratio': 'Unknown (crop type not specified)',
                    'rate': 'Consult local agricultural extension',
                    'timing': 'Depends on crop growth stage',
                    'method': 'Depends on fertilizer type and crop',
                    'notes': 'Please update field information with crop type for specific recommendations.'
                }
                
            return jsonify({
                'field_id': field.id,
                'crop_type': field.crop_type,
                'recommendations': recommendations,
                'generated_by': 'Basic recommendation system'
            })
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/users/register', methods=['POST'])
def register_user():
    """Register a new user"""
    data = request.json
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
        
    required_fields = ['username', 'email', 'password']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing required field: {field}'}), 400
    
    # Check if user already exists
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already taken'}), 409
        
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already registered'}), 409
    
    # Hash password (in a real app, use a proper password hashing library like bcrypt)
    import hashlib
    password_hash = hashlib.sha256(data['password'].encode()).hexdigest()
    
    # Create user
    try:
        user = User(
            username=data['username'],
            email=data['email'],
            password_hash=password_hash,
            full_name=data.get('full_name', ''),
            phone=data.get('phone', ''),
            profile_image=data.get('profile_image', '')
        )
        
        db.session.add(user)
        db.session.commit()
        
        return jsonify({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'message': 'User registered successfully'
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to register user: {str(e)}'}), 500

@app.route('/api/users/login', methods=['POST'])
def login_user():
    """Log in a user"""
    data = request.json
    
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username and password required'}), 400
    
    # Find user
    user = User.query.filter_by(username=data['username']).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Check password
    import hashlib
    password_hash = hashlib.sha256(data['password'].encode()).hexdigest()
    
    if user.password_hash != password_hash:
        return jsonify({'error': 'Invalid password'}), 401
    
    # In a real app, generate a JWT token here
    return jsonify({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'token': 'simulated_jwt_token',  # Placeholder - use a real JWT in production
        'message': 'Login successful'
    })

@app.route('/api/fields', methods=['GET', 'POST'])
def handle_fields():
    """Handle field operations"""
    user_id = request.args.get('user_id') or (request.json or {}).get('user_id')
    
    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400
    
    # Get all fields for a user
    if request.method == 'GET':
        fields = Field.query.filter_by(user_id=user_id).all()
        return jsonify({
            'fields': [{
                'id': f.id,
                'name': f.name,
                'location': f.location,
                'area': f.area,
                'crop_type': f.crop_type,
                'planting_date': f.planting_date.strftime('%Y-%m-%d') if f.planting_date else None,
                'soil_type': f.soil_type,
                'notes': f.notes
            } for f in fields]
        })
    
    # Create a new field
    elif request.method == 'POST':
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        if 'name' not in data:
            return jsonify({'error': 'Field name is required'}), 400
        
        try:
            # Parse planting date if provided
            planting_date = None
            if data.get('planting_date'):
                planting_date = datetime.strptime(data['planting_date'], '%Y-%m-%d')
            
            field = Field(
                user_id=user_id,
                name=data['name'],
                location=data.get('location', ''),
                area=data.get('area'),
                crop_type=data.get('crop_type', ''),
                planting_date=planting_date,
                soil_type=data.get('soil_type', ''),
                notes=data.get('notes', '')
            )
            
            db.session.add(field)
            db.session.commit()
            
            return jsonify({
                'id': field.id,
                'name': field.name,
                'message': 'Field created successfully'
            }), 201
            
        except Exception as e:
            db.session.rollback()
            return jsonify({'error': f'Failed to create field: {str(e)}'}), 500

# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)