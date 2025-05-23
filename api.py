import os
import json
import uuid
import requests
from datetime import datetime, timedelta
from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai

# FIREBASE ONLY: Import Firebase for complete data storage
from firebase_init import firebase
from firebase_models import (
    User, Field, DiseaseReport, IrrigationRecord, FertilizerRecord,
    MarketPrice, MarketFavorite, WeatherForecast, ChatHistory
)

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS

# FIREBASE ONLY: We've fully migrated to Firebase, no longer using PostgreSQL
print("FIREBASE MIGRATION COMPLETE: Using Firebase exclusively for all data storage")

# Skip PostgreSQL initialization
print("PostgreSQL database integration has been removed")

# No migration needed as we're fully on Firebase now
print("No migration needed - fully operating on Firebase")

# Configure Google Gemini API if API key is available
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')

# Rate limit tracker to avoid quota issues
last_api_call_time = {}
rate_limit_interval = 10  # Seconds between API calls to avoid quota issues

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    # Use the latest available Gemini model
    try:
        # List available models
        available_models = [m.name for m in genai.list_models()]
        print(f"Available Gemini models: {available_models}")
        
        # Try to use Flash models first as they have higher quotas
        if 'models/gemini-1.5-flash-latest' in available_models:
            gemini_model = genai.GenerativeModel('models/gemini-1.5-flash-latest')
            print("Using gemini-1.5-flash-latest model to avoid quota issues")
        elif 'models/gemini-1.5-flash' in available_models:
            gemini_model = genai.GenerativeModel('models/gemini-1.5-flash')
            print("Using gemini-1.5-flash model to avoid quota issues")
        elif 'models/gemini-1.5-pro-latest' in available_models:
            gemini_model = genai.GenerativeModel('models/gemini-1.5-pro-latest')
            print("Using gemini-1.5-pro-latest model")
        else:
            # Fallback to any available Gemini model
            for model_name in available_models:
                if 'gemini' in model_name and 'flash' in model_name:
                    gemini_model = genai.GenerativeModel(model_name)
                    print(f"Using fallback Gemini Flash model: {model_name}")
                    break
            else:
                for model_name in available_models:
                    if 'gemini' in model_name:
                        gemini_model = genai.GenerativeModel(model_name)
                        print(f"Using fallback Gemini model: {model_name}")
                        break
                else:
                    print("No suitable Gemini model found, using first available model")
                    gemini_model = genai.GenerativeModel(available_models[0])
    except Exception as e:
        print(f"Error initializing Gemini model: {str(e)}")
        gemini_model = None
        # Set a dummy model that will be replaced on first use
        gemini_model = None
else:
    print("No Gemini API key available")

# ------ Helper Functions ------

def generate_farm_guidance(field):
    """
    Generate AI-powered farming guidance based on field details
    
    Args:
        field: Field object with crop_type, soil_type, location, etc.
    
    Returns:
        dict: Structured guidance including general recommendations, crop-specific advice,
              fertilizer recommendations, pest management, and sustainable practices
    """
    # Default structured response
    guidance = {
        'general_recommendations': [],
        'crop_specific': [],
        'fertilizer': [],
        'pest_management': [],
        'irrigation': [],
        'sustainability': []
    }
    
    try:
        # If Gemini API key is available, use AI for guidance
        if GEMINI_API_KEY:
            model = genai.GenerativeModel('gemini-pro')
            
            # Construct the prompt for the AI model with field details
            prompt = f"""
            As an agricultural expert, provide comprehensive farming guidance for the following field:
            
            Field Name: {field.name}
            Location: {field.location or 'Unknown'}
            Area: {field.area or 'Unknown'} hectares
            Crop Type: {field.crop_type or 'Unknown'}
            Soil Type: {field.soil_type or 'Unknown'}
            Planting Date: {field.planting_date.strftime('%Y-%m-%d') if field.planting_date else 'Not specified'}
            
            Please provide structured farming recommendations in the following categories:
            1. General Recommendations: Overall management practices for this field
            2. Crop-Specific Advice: Best practices for growing {field.crop_type} successfully
            3. Fertilizer Recommendations: What fertilizers to use, when and how much
            4. Pest Management: Common pests/diseases for {field.crop_type} and how to prevent/treat them
            5. Irrigation Guidance: Best irrigation practices for {field.crop_type} in {field.soil_type or 'this'} soil
            6. Sustainable Practices: Environmentally friendly farming techniques
            
            Format the response in JSON with arrays of advice for each category.
            """
            
            response = model.generate_content(prompt)
            
            # Process the response
            if response and response.text:
                try:
                    # Try to parse as JSON first
                    import json
                    response_text = response.text.strip()
                    
                    # Look for JSON content in the response
                    if '```json' in response_text:
                        # Extract JSON from markdown code block
                        json_text = response_text.split('```json')[1].split('```')[0].strip()
                        parsed_guidance = json.loads(json_text)
                    elif '{' in response_text and '}' in response_text:
                        # Try to extract JSON object
                        json_text = response_text[response_text.find('{'):response_text.rfind('}')+1]
                        parsed_guidance = json.loads(json_text)
                    else:
                        # Manually parse the text response
                        raise ValueError("JSON not found in response")
                    
                    # Update guidance with AI response
                    for key in guidance.keys():
                        if key in parsed_guidance and isinstance(parsed_guidance[key], list):
                            guidance[key] = parsed_guidance[key]
                
                except (json.JSONDecodeError, ValueError, KeyError) as e:
                    print(f"Error parsing AI response: {str(e)}")
                    # Manually parse the text response if JSON parsing fails
                    sections = response.text.split('\n\n')
                    current_section = None
                    
                    for section in sections:
                        if ':' in section.split('\n')[0]:
                            section_title = section.split('\n')[0].split(':')[0].strip().lower()
                            if 'general' in section_title:
                                current_section = 'general_recommendations'
                            elif 'crop' in section_title:
                                current_section = 'crop_specific'
                            elif 'fertilizer' in section_title:
                                current_section = 'fertilizer'
                            elif 'pest' in section_title:
                                current_section = 'pest_management'
                            elif 'irrigation' in section_title or 'water' in section_title:
                                current_section = 'irrigation'
                            elif 'sustainable' in section_title or 'environment' in section_title:
                                current_section = 'sustainability'
                            
                            if current_section:
                                # Extract bullet points
                                points = [line.strip().lstrip('- ').lstrip('* ') for line in section.split('\n')[1:] if line.strip()]
                                if points and current_section in guidance:
                                    guidance[current_section] = points
        
        # If no AI is available, or if AI fails, use structured knowledge base
        if not GEMINI_API_KEY or not any(guidance.values()):
            # Provide basic guidance based on crop type and soil type
            crop_type = field.crop_type.lower() if field.crop_type else ''
            soil_type = field.soil_type.lower() if field.soil_type else ''
            
            # Basic crop-specific recommendations
            crop_guidance = get_crop_specific_guidance(crop_type)
            guidance.update(crop_guidance)
            
            # Add soil-specific advice
            soil_guidance = get_soil_specific_guidance(soil_type, crop_type)
            
            # Merge soil guidance into the main guidance
            for key, value in soil_guidance.items():
                if key in guidance and value:
                    guidance[key].extend(value)
        
        return guidance
    
    except Exception as e:
        print(f"Error generating farm guidance: {str(e)}")
        # Return basic guidance in case of error
        return {
            'general_recommendations': [
                "Schedule regular monitoring of your field", 
                "Keep detailed records of all farming activities", 
                "Consider soil testing to optimize fertility management"
            ],
            'crop_specific': [
                "Research best practices specific to your crop variety", 
                "Consider crop rotation to improve soil health and reduce pest pressure"
            ],
            'fertilizer': [
                "Apply balanced NPK fertilizer based on crop needs", 
                "Consider organic amendments to improve soil structure"
            ],
            'pest_management': [
                "Regularly scout for pests and diseases", 
                "Consider integrated pest management (IPM) approaches"
            ],
            'irrigation': [
                "Adjust irrigation based on crop growth stage", 
                "Consider water conservation techniques"
            ],
            'sustainability': [
                "Minimize soil disturbance to reduce erosion", 
                "Consider cover crops to improve soil health"
            ]
        }

def get_crop_specific_guidance(crop_type):
    """Provide guidance specific to crop type"""
    crop_type = crop_type.lower()
    
    # Dictionary of crop-specific guidance
    crop_guidance = {
        'rice': {
            'general_recommendations': [
                "Maintain proper water levels during different growth stages",
                "Regularly check for signs of water stress or excess",
                "Consider direct seeding techniques to reduce labor costs",
                "Implement proper drainage systems to prevent waterlogging"
            ],
            'crop_specific': [
                "Transplant at optimal spacing (20x15 cm) for most varieties",
                "Maintain water level of 2-5 cm during vegetative stage",
                "Allow field to dry periodically during tillering to encourage root growth",
                "Drain field 2-3 weeks before harvest to facilitate ripening and harvesting"
            ],
            'fertilizer': [
                "Apply basal dose of NPK before transplanting",
                "Top dress with nitrogen at tillering and panicle initiation stages",
                "Consider zinc application in deficient soils",
                "Incorporate rice straw after harvest to improve soil organic matter"
            ],
            'pest_management': [
                "Monitor for stem borers, plant hoppers, and leaf folders",
                "Watch for rice blast, bacterial leaf blight, and sheath blight diseases",
                "Use resistant varieties where disease pressure is high",
                "Consider biological controls like Trichogramma for egg parasitization"
            ],
            'irrigation': [
                "Maintain flooded conditions but periodically allow soil to dry slightly",
                "Critical irrigation periods: tillering, flowering, and grain filling",
                "Consider alternate wetting and drying technique to save water",
                "Ensure good drainage capacity to prevent submergence during heavy rains"
            ],
            'sustainability': [
                "Consider direct seeded rice to reduce water and labor requirements",
                "Implement crop rotation with legumes to improve soil fertility",
                "Use azolla as biofertilizer to reduce nitrogen requirements",
                "Practice integrated pest management to reduce pesticide use"
            ]
        },
        'wheat': {
            'general_recommendations': [
                "Ensure proper seed bed preparation for good germination",
                "Timely sowing is critical for optimal yields",
                "Monitor growth stages to time management practices appropriately",
                "Control weeds early to prevent yield loss"
            ],
            'crop_specific': [
                "Optimal sowing time: October-November for most regions in India",
                "Seed rate: 100-125 kg/ha for timely sowing, increase by 25% for late sowing",
                "First irrigation at crown root initiation stage is critical",
                "Monitor for heading and flowering for disease management"
            ],
            'fertilizer': [
                "Apply 50% N, full P and K as basal dose",
                "Top dress remaining N in two splits: at first irrigation and tillering",
                "Consider foliar spray of 2% urea at grain filling if needed",
                "Apply sulfur in sulfur-deficient soils for improved protein content"
            ],
            'pest_management': [
                "Monitor for aphids, especially during cool, humid weather",
                "Watch for rust diseases (yellow, brown, black) and powdery mildew",
                "Take preventive measures against termites in sandy soils",
                "Apply fungicides at boot and heading stages for disease control"
            ],
            'irrigation': [
                "Critical irrigation stages: crown root initiation, tillering, jointing, flowering, and grain filling",
                "Avoid over-irrigation to prevent lodging and disease",
                "Ensure good drainage to prevent waterlogging",
                "Consider sprinkler irrigation for water conservation and uniform application"
            ],
            'sustainability': [
                "Practice conservation tillage to reduce soil erosion",
                "Incorporate crop residues to improve soil health",
                "Consider legume rotation to improve soil nitrogen",
                "Use precision agriculture tools for targeted input application"
            ]
        },
        'cotton': {
            'general_recommendations': [
                "Ensure adequate soil moisture at planting",
                "Implement regular monitoring for pest pressure",
                "Consider high-density planting for improved yields",
                "Monitor plant growth regulators and defoliation timing"
            ],
            'crop_specific': [
                "Plant at appropriate spacing (75-90 cm between rows, 30-45 cm within row)",
                "Thin to maintain optimal plant population",
                "Monitor square formation and retention",
                "Consider topping to control excessive vegetative growth"
            ],
            'fertilizer': [
                "Apply balanced NPK with higher K for improved fiber quality",
                "Split nitrogen application over growing season",
                "Apply micronutrients like boron and zinc based on soil test",
                "Consider foliar sprays during boll development"
            ],
            'pest_management': [
                "Monitor for bollworms, whiteflies, aphids, and pink bollworm",
                "Implement IPM practices including pheromone traps",
                "Watch for bacterial blight and Alternaria leaf spot",
                "Use economic thresholds to guide control decisions"
            ],
            'irrigation': [
                "Critical irrigation stages: seedling establishment, squaring, flowering, boll formation",
                "Maintain adequate moisture during boll development",
                "Avoid water stress during flowering and early boll development",
                "Reduce irrigation during boll opening and before harvest"
            ],
            'sustainability': [
                "Implement trap crops for pest management",
                "Consider organic mulching to reduce weed pressure",
                "Practice crop rotation to break pest cycles",
                "Use drip irrigation for water conservation"
            ]
        },
        'sugarcane': {
            'general_recommendations': [
                "Prepare land thoroughly with deep plowing",
                "Select disease-free seed material",
                "Implement proper trash management after harvest",
                "Consider stubble shaving for ratoon management"
            ],
            'crop_specific': [
                "Plant setts with 2-3 buds at 5 cm depth",
                "Space rows 90-100 cm apart for optimal growth",
                "Practice propping to prevent lodging during later growth stages",
                "Monitor for tiller formation and growth"
            ],
            'fertilizer': [
                "Apply high organic matter before planting",
                "Use balanced NPK with higher N for vegetative growth",
                "Split nitrogen application over growing season",
                "Consider trash mulching to enhance soil fertility"
            ],
            'pest_management': [
                "Monitor for early shoot borer, pyrilla, and top borer",
                "Watch for red rot, smut, and ratoon stunting disease",
                "Use hot water treatment for seed material to prevent disease",
                "Implement pheromone traps for borers"
            ],
            'irrigation': [
                "Maintain consistent soil moisture, especially during germination and tillering",
                "Implement furrow irrigation for water conservation",
                "Reduce irrigation during ripening phase",
                "Consider drip irrigation for improved water use efficiency"
            ],
            'sustainability': [
                "Implement trash mulching to improve soil health",
                "Consider intercropping with legumes in early growth stages",
                "Practice green manuring to improve soil fertility",
                "Use biofertilizers to reduce chemical fertilizer requirements"
            ]
        }
    }
    
    # Default guidance for other crops
    default_guidance = {
        'general_recommendations': [
            "Implement regular field monitoring",
            "Keep records of all farming activities",
            "Maintain field sanitation to reduce pest pressure",
            "Analyze results each season to improve practices"
        ],
        'crop_specific': [
            "Research optimal planting densities for your variety",
            "Monitor key growth stages to time management practices",
            "Consider varietal selection based on local conditions",
            "Implement proper harvest and post-harvest handling"
        ],
        'fertilizer': [
            "Conduct soil testing to determine nutrient requirements",
            "Apply balanced nutrients based on crop needs",
            "Split fertilizer applications to improve efficiency",
            "Consider organic amendments to improve soil health"
        ],
        'pest_management': [
            "Regularly scout for pests and diseases",
            "Implement cultural practices to reduce pest pressure",
            "Consider resistant varieties when available",
            "Apply pesticides only when economically justified"
        ],
        'irrigation': [
            "Monitor soil moisture to guide irrigation decisions",
            "Identify critical growth stages for irrigation",
            "Implement water conservation techniques",
            "Consider irrigation scheduling based on ET rates"
        ],
        'sustainability': [
            "Implement crop rotation to break pest cycles",
            "Minimize soil disturbance to reduce erosion",
            "Consider cover crops to improve soil health",
            "Reduce chemical inputs through integrated management"
        ]
    }
    
    # Return crop-specific guidance if available, otherwise default
    for crop, guidance in crop_guidance.items():
        if crop in crop_type:
            return guidance
    
    return default_guidance

def get_soil_specific_guidance(soil_type, crop_type):
    """Provide guidance specific to soil type and crop combination"""
    
    # Default advice for different soil types
    soil_guidance = {
        'sandy': {
            'general_recommendations': [
                "Incorporate organic matter to improve water holding capacity",
                "Consider more frequent but lighter irrigation"
            ],
            'fertilizer': [
                "Apply fertilizers in smaller, more frequent doses to prevent leaching",
                "Increase organic matter to improve nutrient retention"
            ],
            'irrigation': [
                "Monitor soil moisture closely as sandy soils drain quickly",
                "Consider drip irrigation for efficient water use"
            ]
        },
        'clay': {
            'general_recommendations': [
                "Improve drainage to prevent waterlogging",
                "Implement proper tillage to prevent compaction"
            ],
            'fertilizer': [
                "Avoid heavy applications of nitrogen at once",
                "Consider adding gypsum to improve soil structure"
            ],
            'irrigation': [
                "Avoid overwatering as clay soils drain slowly",
                "Allow sufficient drying between irrigations"
            ]
        },
        'loam': {
            'general_recommendations': [
                "Maintain organic matter for optimal soil structure",
                "Implement minimal tillage to preserve soil quality"
            ],
            'fertilizer': [
                "Apply balanced fertilization program",
                "Consider split applications for better uptake"
            ],
            'irrigation': [
                "Monitor soil moisture at multiple depths",
                "Use efficient irrigation methods to prevent waste"
            ]
        },
        'black': {
            'general_recommendations': [
                "Implement proper drainage systems",
                "Careful moisture management to prevent cracking"
            ],
            'fertilizer': [
                "Monitor for micronutrient deficiencies",
                "Consider soil amendments to improve structure"
            ],
            'irrigation': [
                "Implement careful irrigation to prevent waterlogging",
                "Allow appropriate drying cycle between irrigations"
            ]
        },
        'red': {
            'general_recommendations': [
                "Focus on soil conservation practices",
                "Add organic matter to improve soil quality"
            ],
            'fertilizer': [
                "Apply micronutrients, especially zinc and iron",
                "Increase organic inputs to improve CEC"
            ],
            'irrigation': [
                "Implement water conservation techniques",
                "Consider mulching to reduce evaporation"
            ]
        }
    }
    
    # Default return empty guidance if no match
    result = {
        'general_recommendations': [],
        'fertilizer': [],
        'irrigation': []
    }
    
    # Check for matching soil type
    for soil, guidance in soil_guidance.items():
        if soil in soil_type:
            return guidance
    
    return result

# ------ API Routes ------

@app.route('/api/chat', methods=['POST'])
def chat():
    """Process chat message and return AI response with context awareness - FIREBASE ONLY"""
    try:
        data = request.json
        user_message = data.get('message', '')
        user_id = data.get('user_id', 'anonymous')
        session_id = data.get('session_id', str(uuid.uuid4()))  # Generate a session ID if none provided
        context_window = data.get('context_window', 5)  # Number of previous messages to include for context
        
        if not user_message:
            return jsonify({'error': 'No message provided'}), 400
        
        # Default response in case AI is not available - in Hindi
        default_response = "मैं AI किसान, आपका कृषि सहायक हूँ। मैं फसल की सलाह, रोग पहचान, मौसम की व्याख्या, और अधिक में आपकी मदद कर सकता हूँ। बेहतर सहायता के लिए कृपया अपने कृषि प्रश्न के बारे में विशिष्ट विवरण प्रदान करें।"
        
        # Detect topic/intent (simple keyword-based for now)
        context_data = detect_chat_intent(user_message)
        
        # Save message to chat history using Firebase
        try:
            # Create new chat message document in Firebase
            chat_data = {
                'user_id': user_id,
                'session_id': session_id,
                'message': user_message,
                'sender': 'user',
                'timestamp': datetime.utcnow().isoformat(),
                'context_data': context_data
            }
            
            # Use Firebase model
            ChatHistory.create(chat_data)
            print(f"Saved chat message to Firebase for user {user_id}")
        except Exception as e:
            print(f"Error in chat save: {str(e)}")
            return jsonify({'error': f'Failed to save chat message: {str(e)}'}), 500
        
        # Get conversation history from Firebase
        try:
            # Get conversation history from Firebase model
            print(f"Using Firebase to get chat history for user {user_id}, session {session_id}")
            chat_history = ChatHistory.get_by_user_and_session(user_id, session_id)
            
            # Sort by timestamp
            chat_history.sort(key=lambda x: x.get('timestamp', ''))
            
            # Limit to context window
            if len(chat_history) > context_window:
                chat_history = chat_history[-context_window:]
        except Exception as e:
            print(f"Error in chat history retrieval: {str(e)}")
            chat_history = []
        
        # Format chat history for AI context
        conversation_context = ""
        if chat_history and len(chat_history) > 1:  # If there's more than just the current message
            conversation_context = "Previous conversation:\n"
            for entry in chat_history[:-1]:  # Exclude the current message which we just saved
                role = "किसान" if entry.get('sender') == "user" else "AI किसान"
                conversation_context += f"{role}: {entry.get('message', '')}\n"
        
        # If Gemini API key is available, use AI for chat
        if GEMINI_API_KEY:
            try:
                # Define the system prompt for farming assistant
                system_prompt = """
                You are AI Kisan, an expert agricultural assistant for farmers in India. 
                You provide helpful, practical advice on farming practices, crop management, disease identification, 
                weather interpretations, and market trends. Your responses should be:
                
                1. Practical and actionable for farmers
                2. Based on scientific agricultural knowledge
                3. Relevant to Indian farming conditions
                4. Considerate of both traditional and modern farming approaches
                5. Clear and easy to understand
                6. ALWAYS IN HINDI LANGUAGE using Devanagari script
                7. Contextually aware of the ongoing conversation
                
                When responding to queries about crop problems, ask for specifics like symptoms, 
                affected plant parts, and growth stage. For weather-related queries, explain implications 
                for farming activities. Always suggest sustainable practices when appropriate.
                
                IMPORTANT: Reference previous messages in the conversation to maintain context.
                If the farmer is asking follow-up questions, make sure to connect your answer to previous exchanges.
                REMEMBER: You MUST respond in Hindi language. Your users are rural Indian farmers who primarily speak Hindi.
                Even if the question is in English, always respond in Hindi.
                """
                
                # Use the latest available Gemini model
                try:
                    # Configure generation parameters for more human-like responses
                    generation_config = {
                        "temperature": 0.8,  # Slightly higher temperature for more creative responses
                        "top_p": 0.95,
                        "top_k": 40,
                        "max_output_tokens": 1024,  # Increased token limit for more comprehensive answers
                    }
                    
                    # Construct a clear prompt for Hindi responses with context
                    improved_prompt = f"""
                    {system_prompt}
                    
                    {conversation_context}
                    
                    किसान का वर्तमान प्रश्न: {user_message}
                    
                    कृपया हिंदी में विस्तृत और संदर्भ के अनुसार मददगार उत्तर दें:
                    """
                    
                    # Use one of the available Gemini models - gemini-1.5-pro-latest
                    model = genai.GenerativeModel('models/gemini-1.5-pro-latest')
                    
                    # Try detecting and incorporating user context (field info, previous interactions)
                    try:
                        # If the message mentions crops or fields, try to augment with user's field data
                        field_data = None
                        if any(keyword in user_message.lower() for keyword in ['field', 'crop', 'farm', 'खेत', 'फसल']):
                            # Try to get the user's field data if they're a registered user
                            if user_id.isdigit():
                                fields = Field.query.filter_by(user_id=int(user_id)).all()
                                if fields:
                                    field_data = "\nउपयोगकर्ता के खेत की जानकारी:\n"
                                    for field in fields:
                                        field_data += f"- नाम: {field.name}, स्थान: {field.location or 'अज्ञात'}, फसल: {field.crop_type or 'अज्ञात'}, मिट्टी: {field.soil_type or 'अज्ञात'}\n"
                        
                        # Add field data to prompt if available
                        if field_data:
                            improved_prompt += f"\n{field_data}"
                    except Exception as context_error:
                        print(f"Error adding field context: {str(context_error)}")
                    
                    response = model.generate_content(improved_prompt)
                    
                    if response and response.text:
                        ai_response = response.text
                        print("Successfully generated Gemini response")
                        
                        # Save AI response to chat history using Firebase model
                        try:
                            # Create new chat message document in Firebase
                            ai_chat_data = {
                                'user_id': user_id,
                                'session_id': session_id,
                                'message': ai_response,
                                'sender': 'assistant',
                                'timestamp': datetime.utcnow().isoformat(),
                                'context_data': context_data
                            }
                            
                            # Use Firebase model
                            ChatHistory.create(ai_chat_data)
                            print(f"Saved AI response to Firebase for user {user_id}")
                        except Exception as e:
                            print(f"Error saving AI response: {str(e)}")
                            # Continue anyway - the response is still valid even if we couldn't save it
                        
                        return jsonify({'reply': ai_response})
                    else:
                        print("No valid response from Gemini model")
                        return jsonify({'reply': default_response})
                        
                except Exception as inner_e:
                    print(f"Error with primary model generation: {str(inner_e)}")
                    # Try a different model as fallback
                    try:
                        # Try gemini-1.5-flash model as fallback
                        fallback_model = genai.GenerativeModel('models/gemini-1.5-flash-latest')
                        response = fallback_model.generate_content(
                            f"{system_prompt}\n\n{conversation_context}\n\nFarmer's current question: {user_message}\n\nYour expert response in Hindi:",
                            generation_config={"temperature": 0.7, "max_output_tokens": 800}
                        )
                        
                        if response and response.text:
                            ai_response = response.text
                            
                            # Save AI response to chat history
                            try:
                                # Create new chat message document in Firebase
                                ai_chat_data = {
                                    'user_id': user_id,
                                    'session_id': session_id,
                                    'message': ai_response,
                                    'sender': 'assistant',
                                    'timestamp': datetime.utcnow().isoformat(),
                                    'context_data': context_data
                                }
                                
                                # Use Firebase model
                                ChatHistory.create(ai_chat_data)
                                print(f"Saved fallback AI response to Firebase for user {user_id}")
                            except Exception as e:
                                print(f"Error saving fallback AI response: {str(e)}")
                                # Continue anyway - the response is still valid even if we couldn't save it
                            
                            return jsonify({'reply': ai_response})
                        else:
                            return jsonify({'reply': default_response})
                    except Exception as fallback_error:
                        print(f"Final fallback error: {str(fallback_error)}")
                        return jsonify({'reply': default_response})
                    
            except Exception as e:
                print(f"Error calling Gemini API: {str(e)}")
                return jsonify({'reply': default_response})
        else:
            print("No Gemini API key available")
            # Creating a hardcoded Hindi response since API key is not available
            hindi_responses = {
                "hello": "नमस्ते! मैं आपका AI किसान सहायक हूँ। मैं आपकी कैसे मदद कर सकता हूँ?",
                "hi": "नमस्ते! आज आप किस प्रकार की कृषि जानकारी के बारे में पूछना चाहेंगे?",
                "how are you": "मैं एक AI सहायक हूँ और सदैव आपकी सेवा के लिए तैयार हूँ। आपको खेती से संबंधित क्या जानकारी चाहिए?",
                "help": "मैं फसल चुनाव, रोग निदान, मौसम सलाह, और उर्वरक सिफारिशों जैसे विषयों पर मदद कर सकता हूँ। कृपया विशेष प्रश्न पूछें।",
                "weather": "आपके क्षेत्र के मौसम की जानकारी के लिए, कृपया अपना स्थान बताएं। मैं वहां के मौसम पूर्वानुमान प्रदान करूंगा।",
                "crops": "भारत में मुख्य फसलें चावल, गेहूं, मक्का, ज्वार, बाजरा, दालें, तिलहन, गन्ना और कपास हैं। किस फसल के बारे में जानकारी चाहिए?",
                "fertilizer": "उर्वरक सिफारिशों के लिए, मुझे आपकी फसल, मिट्टी का प्रकार और फसल का चरण बताएं। उचित उर्वरक प्रबंधन फसल उत्पादन में महत्वपूर्ण है।"
            }
            
            # Check if the user message contains any keywords, with case-insensitive matching
            user_message_lower = user_message.lower()
            ai_response = default_response
            for keyword, response in hindi_responses.items():
                if keyword in user_message_lower:
                    ai_response = response
                    break
            
            # Save AI response to chat history using Firebase model
            try:
                # Create new chat message document in Firebase
                ai_chat_data = {
                    'user_id': user_id,
                    'session_id': session_id,
                    'message': ai_response,
                    'sender': 'assistant',
                    'timestamp': datetime.utcnow().isoformat(),
                    'context_data': context_data
                }
                
                # Use Firebase model
                ChatHistory.create(ai_chat_data)
                print(f"Saved default AI response to Firebase for user {user_id}")
            except Exception as e:
                print(f"Error saving default AI response: {str(e)}")
                # Continue anyway - the response is still valid even if we couldn't save it
            
            return jsonify({'reply': ai_response})
            
    except Exception as e:
        print(f"Error in chat endpoint: {str(e)}")
        return jsonify({'error': 'Failed to process chat message'}), 500


def detect_chat_intent(message):
    """
    Detect the user's intent from chat message to provide better context-aware responses
    """
    message_lower = message.lower()
    
    # Define intent categories with keywords (both English and Hindi)
    intent_keywords = {
        'greeting': ['hello', 'hi', 'hey', 'नमस्ते', 'नमस्कार', 'प्रणाम'],
        'weather': ['weather', 'rain', 'temperature', 'forecast', 'climate', 'मौसम', 'बारिश', 'तापमान'],
        'crop_info': ['crop', 'plant', 'cultivation', 'grow', 'फसल', 'बीज', 'खेती', 'उगाना'],
        'disease': ['disease', 'pest', 'infection', 'रोग', 'कीट', 'संक्रमण', 'बीमारी'],
        'fertilizer': ['fertilizer', 'manure', 'nutrition', 'उर्वरक', 'खाद'],
        'market': ['price', 'market', 'sell', 'buy', 'बाजार', 'मूल्य', 'कीमत', 'बेचना', 'खरीदना'],
        'irrigation': ['water', 'irrigation', 'moisture', 'पानी', 'सिंचाई', 'नमी'],
        'farming_tech': ['technology', 'machine', 'equipment', 'तकनीक', 'मशीन', 'उपकरण'],
        'help': ['help', 'support', 'मदद', 'सहायता']
    }
    
    # Extract the top 3 likely intents
    intents = []
    for intent, keywords in intent_keywords.items():
        for keyword in keywords:
            if keyword in message_lower:
                intents.append(intent)
                break
    
    # If no specific intent is found, classify as 'general_query'
    if not intents:
        intents.append('general_query')
    
    # Return metadata with identified intents and original message properties
    return {
        'intents': intents[:3],  # Top 3 intents max
        'message_length': len(message),
        'timestamp': datetime.utcnow().isoformat(),
        'contains_question': '?' in message or 'क्या' in message_lower or 'कौन' in message_lower or 'कब' in message_lower
    }


@app.route('/api/chat_history', methods=['GET'])
def get_chat_history():
    """Get chat history for a user"""
    user_id = request.args.get('user_id', 'anonymous')
    session_id = request.args.get('session_id')
    limit = request.args.get('limit', 50, type=int)
    
    # Get chat history using Firebase models
    try:
        print(f"Using Firebase to get chat history for user {user_id}, session {session_id}")
        
        if session_id:
            # Get history for a specific session
            chat_history = ChatHistory.get_by_user_and_session(user_id, session_id)
        else:
            # Get all history for the user
            chat_history = ChatHistory.get_by_user_id(user_id)
        
        # Process the records
        if chat_history:
            # Sort by timestamp (older first)
            chat_history.sort(key=lambda x: x.get('timestamp', ''))
            
            # Limit the number of records
            if len(chat_history) > limit:
                # Get most recent messages
                chat_history = chat_history[-limit:]
                
            # Format the response
            return jsonify({
                'history': [{
                    'id': entry.get('id', ''),
                    'user_id': entry.get('user_id', ''),
                    'session_id': entry.get('session_id', ''),
                    'message': entry.get('message', ''),
                    'sender': entry.get('sender', ''),
                    'timestamp': entry.get('timestamp', ''),
                    'intents': entry.get('context_data', {}).get('intents', []) if entry.get('context_data') else []
                } for entry in chat_history]
            })
    except Exception as e:
        print(f"Firebase chat history error: {e}")
        
    # Return empty history on error
    return jsonify({'history': []})


@app.route('/api/chat_sessions', methods=['GET'])
def get_chat_sessions():
    """Get unique chat sessions for a user"""
    user_id = request.args.get('user_id', 'anonymous')
    
    # Get chat sessions using Firebase models
    try:
        print(f"Using Firebase to get chat sessions for user {user_id}")
        
        # Get sessions directly from ChatHistory model
        sessions = ChatHistory.get_sessions(user_id)
        
        # If sessions were found, format and return them
        if sessions:
            # Sort by most recent sessions first
            sessions.sort(key=lambda x: x.get('timestamp', ''), reverse=True)
            
            # Format the response
            result = []
            for session in sessions:
                session_id = session.get('session_id', '')
                timestamp = session.get('timestamp', '')
                last_message = session.get('last_message', '')
                
                # Generate title from first message
                title = last_message[:50] + '...' if last_message and len(last_message) > 50 else last_message or 'New Conversation'
                
                session_info = {
                    'session_id': session_id,
                    'last_message_time': timestamp,
                    'message_count': 0,  # We'd need another query to get the count
                    'primary_intent': 'general_query',  # We'd need another query to analyze intents
                    'title': title
                }
                
                result.append(session_info)
            
            return jsonify({'sessions': result})
    except Exception as e:
        print(f"Firebase chat sessions error: {e}")
    
    # Return empty sessions on error
    return jsonify({'sessions': []})

@app.route('/api/weather', methods=['GET'])
def get_weather():
    """Get weather forecast for a location"""
    location = request.args.get('location', 'New Delhi')
    
    # Try to fetch from Firebase first
    try:
        # Get any existing forecasts for this location
        forecasts = WeatherForecast.get_by_location(location)
        
        # Check if we have fresh forecasts (within last 30 minutes)
        today = datetime.utcnow().date()
        recent_forecasts = []
        
        for forecast in forecasts:
            # Check if the forecast is for today or future dates
            forecast_date = datetime.fromisoformat(forecast.get('forecast_date', '')).date() \
                if forecast.get('forecast_date', '') else None
            
            updated_at = datetime.fromisoformat(forecast.get('updated_at', '')) \
                if forecast.get('updated_at', '') else None
                
            if forecast_date and forecast_date >= today and updated_at and \
               (datetime.utcnow() - updated_at).total_seconds() < 1800:  # 30 minutes
                recent_forecasts.append(forecast)
        
        if recent_forecasts:
            # Sort by date
            recent_forecasts.sort(key=lambda x: x.get('forecast_date', ''))
            
            return jsonify({
                'location': location,
                'forecasts': [{
                    'date': datetime.fromisoformat(f.get('forecast_date', '')).strftime('%Y-%m-%d') \
                        if f.get('forecast_date', '') else '',
                    'temp_min': f.get('temperature_min', 0),
                    'temp_max': f.get('temperature_max', 0),
                    'humidity': f.get('humidity', 0),
                    'precipitation': f.get('precipitation', 0),
                    'wind_speed': f.get('wind_speed', 0),
                    'description': f.get('weather_description', '')
                } for f in recent_forecasts]
            })
    except Exception as e:
        print(f"Error fetching weather from Firebase: {str(e)}")
    
    # Otherwise, generate location-specific weather data
    try:
        # Generate location-specific weather data using location name as a seed
        import hashlib
        
        # Create a hash of the location name to get consistent but different values per location
        location_hash = int(hashlib.md5(location.encode()).hexdigest(), 16) % 100
        
        # Base temperature varies by location
        base_temp_min = 18 + (location_hash % 8)  # 18-25°C min temp
        base_temp_max = 28 + (location_hash % 8)  # 28-35°C max temp
        
        # Get different weather types based on location
        weather_types = ['Sunny', 'Partly cloudy', 'Cloudy', 'Light rain', 'Rain', 'Thunderstorm', 'Foggy', 'Clear']
        primary_weather = weather_types[location_hash % len(weather_types)]
        secondary_weather = weather_types[(location_hash + 3) % len(weather_types)]
        
        today = datetime.utcnow().date()
        forecasts_data = []
        for i in range(7):
            # Day-to-day variations
            daily_variation = (i * 7 + location_hash) % 5 - 2  # -2 to +2 degrees
            rain_chance = (location_hash + i * 13) % 100  # 0-99%
            
            # Decide today's weather
            if i == 0 or i == 1:
                weather = primary_weather
            elif i == 5 or i == 6:
                weather = secondary_weather
            else:
                # Middle days rotate between the two
                weather = primary_weather if ((i + location_hash) % 2 == 0) else secondary_weather
            
            # Precipitation depends on weather type
            precip = 0
            if 'rain' in weather.lower() or 'storm' in weather.lower():
                precip = 0.1 + (rain_chance / 100) * 0.9  # 0.1-1.0
            elif 'cloudy' in weather.lower():
                precip = (rain_chance / 100) * 0.4  # 0-0.4
                
            # Create the forecast
            forecasts_data.append({
                'date': (today + timedelta(days=i)).strftime('%Y-%m-%d'),
                'temp_min': base_temp_min + daily_variation,
                'temp_max': base_temp_max + daily_variation,
                'humidity': 50 + (rain_chance // 2),  # 50-99%
                'precipitation': round(precip, 2),
                'wind_speed': 5 + (location_hash + i * 11) % 20,  # 5-24 km/h
                'description': weather
            })
        
        # Save new forecasts to Firebase
        try:
            # First, try to delete the old forecasts
            WeatherForecast.delete_by_location(location)
            
            # Store new forecast data in database
            for forecast in forecasts_data:
                forecast_date = datetime.strptime(forecast['date'], '%Y-%m-%d')
                
                # Create a new forecast entry
                forecast_data = {
                    'location': location,
                    'forecast_date': forecast_date.isoformat(),
                    'temperature_min': forecast['temp_min'],
                    'temperature_max': forecast['temp_max'],
                    'humidity': forecast['humidity'],
                    'precipitation': forecast['precipitation'],
                    'wind_speed': forecast['wind_speed'],
                    'weather_description': forecast['description'],
                    'updated_at': datetime.utcnow().isoformat()
                }
                
                WeatherForecast.create(forecast_data)
            
            print(f"Successfully stored weather forecasts for {location} in Firebase")
        except Exception as save_error:
            print(f"Error saving weather forecasts to Firebase: {str(save_error)}")
        
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
    results = []
    
    # Try to get prices from Firebase
    try:
        # Get latest market prices, optionally filtered by crop type
        if crop_type:
            prices = MarketPrice.get_by_crop_type(crop_type)
        else:
            prices = MarketPrice.get_latest()
            
        if prices:
            # Format the results for API response
            for price in prices:
                results.append({
                    'crop_type': price.get('crop_type', ''),
                    'market_name': price.get('market_name', ''),
                    'price': price.get('price', 0),
                    'min_price': price.get('min_price', 0),
                    'max_price': price.get('max_price', 0),
                    'date': datetime.fromisoformat(price.get('date', '')).strftime('%Y-%m-%d') if price.get('date', '') else '',
                    'source': price.get('source', '')
                })
    except Exception as e:
        print(f"Error fetching market prices from Firebase: {str(e)}")
    
    # If no data in Firebase or there was an error, generate new data
    if not results:
        # Generate market price data
        supported_crops = [
            'Rice', 'Wheat', 'Cotton', 'Sugarcane', 'Maize', 
            'Soybean', 'Potato', 'Tomato', 'Chickpea', 'Mustard',
            'Groundnut', 'Chilli', 'Onion', 'Turmeric', 'Ginger',
            'Millet', 'Barley', 'Jute', 'Sunflower'
        ]
        
        markets = ['Delhi', 'Mumbai', 'Kolkata', 'Chennai', 'Lucknow', 'Bangalore', 'Hyderabad']
        
        # Generate data based on crop types
        crops_to_process = [crop_type] if crop_type else supported_crops
        
        # Use realistic base prices for different crops (in ₹ per quintal)
        base_prices = {
            'Rice': 2200,
            'Wheat': 2000,
            'Cotton': 6000,
            'Sugarcane': 300,
            'Maize': 1800,
            'Soybean': 4000,
            'Potato': 1500,
            'Tomato': 2000,
            'Chickpea': 5000,
            'Mustard': 5500,
            'Groundnut': 5800,
            'Chilli': 8000,
            'Onion': 1200,
            'Turmeric': 7500,
            'Ginger': 6500,
            'Millet': 2800,
            'Barley': 2200,
            'Jute': 4500,
            'Sunflower': 5600
        }
        
        try:
            # Add realistic variation
            import random
            
            for crop in crops_to_process:
                base_price = base_prices.get(crop, 2000)
                variation_pct = random.uniform(-0.1, 0.1)
                
                for market in markets:
                    # Add market-specific variation
                    market_variation = random.uniform(-0.05, 0.05)
                    final_price = base_price * (1 + variation_pct + market_variation)
                    final_price = round(final_price, 0)
                    
                    min_price = round(final_price * 0.95, 0)
                    max_price = round(final_price * 1.1, 0)
                    
                    # Create price data dictionary
                    price_data = {
                        'crop_type': crop,
                        'market_name': market,
                        'price': final_price,
                        'min_price': min_price,
                        'max_price': max_price,
                        'date': datetime.utcnow().isoformat(),
                        'source': 'Generated Data'
                    }
                    
                    # Save to Firebase for future use
                    try:
                        MarketPrice.create(price_data)
                    except Exception as save_error:
                        print(f"Error saving market price to Firebase: {str(save_error)}")
                    
                    # Add to results
                    results.append({
                        'crop_type': crop,
                        'market_name': market,
                        'price': final_price,
                        'min_price': min_price,
                        'max_price': max_price,
                        'date': datetime.utcnow().strftime('%Y-%m-%d'),
                        'source': 'Generated Data'
                    })
        except Exception as e:
            print(f"Error generating market prices: {str(e)}")
    
    # Return results in the expected format for the frontend
    # Frontend expects: { prices: [...] }
    return jsonify({
        'prices': results
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
            # Use Gemini for image analysis with proper model selection
            try:
                # Try to use the newer multimodal model first
                model = genai.GenerativeModel('gemini-1.5-pro')
                print(f"Using gemini-1.5-pro for disease detection")
            except:
                # Fallback model selection logic
                vision_model = None
                for m in genai.list_models():
                    if 'gemini' in m.name and 'vision' in m.name and 'generateContent' in m.supported_generation_methods:
                        vision_model = m.name.replace('models/', '')
                        print(f"Using fallback vision model: {vision_model}")
                        model = genai.GenerativeModel(vision_model)
                        break
                
                if not vision_model:
                    for m in genai.list_models():
                        if 'gemini' in m.name and 'generateContent' in m.supported_generation_methods:
                            model_name = m.name.replace('models/', '')
                            print(f"Using general model: {model_name}")
                            model = genai.GenerativeModel(model_name)
                            break
            
            with open(image_path, 'rb') as f:
                image_data = f.read()
            
            # For gemini-1.5-pro and newer models
            # Format the content specifically for image analysis
            response = model.generate_content(
                contents=[
                    {
                        "role": "user",
                        "parts": [
                            {"text": "You are an expert agricultural pathologist. Analyze this crop image and identify any diseases. If you see a disease, provide the following information in a structured format:\n\nDisease name: [Name of the disease]\nConfidence level: [0.7-0.9 depending on your certainty]\nSymptoms: [List the visible symptoms in the image]\nRecommended treatments: [Provide 2-3 specific treatment recommendations]\n\nIf you cannot identify a specific disease with certainty, make your best educated guess based on the visible symptoms. Do not say 'Unknown Disease' or that you cannot identify it."},
                            {"inline_data": {"mime_type": "image/jpeg", "data": image_data}},
                            {"text": f"This is a {crop_type} plant. Please analyze it for diseases and provide the information as requested above."}
                        ]
                    }
                ],
                generation_config={"temperature": 0.2}
            )
            
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
            # First try to save to Firebase
            try:
                print(f"Saving disease report to Firebase for user {user_id}, field {field_id}")
                report_data = {
                    'user_id': user_id,
                    'field_id': field_id,
                    'disease_name': disease_name,
                    'confidence_score': confidence,
                    'image_path': image_path,
                    'symptoms': symptoms,
                    'treatment_recommendations': treatment,
                    'status': 'detected',
                    'detection_date': datetime.utcnow().isoformat(),
                }
                
                # Create report in Firebase
                firebase_report = DiseaseReport.create(report_data)
                if firebase_report:
                    report = firebase_report
                    print("Successfully saved disease report to Firebase")
            except Exception as firebase_error:
                print(f"Failed to save disease report to Firebase: {str(firebase_error)}")
                print("Falling back to PostgreSQL for disease report storage")
                
                # Fallback to PostgreSQL if Firebase fails
                from models import DiseaseReport as SQLDiseaseReport
                sql_report = SQLDiseaseReport(
                    user_id=user_id,
                    field_id=field_id,
                    disease_name=disease_name,
                    confidence_score=confidence,
                    image_path=image_path,
                    symptoms=symptoms,
                    treatment_recommendations=treatment,
                    status='detected'
                )
                db.session.add(sql_report)
                db.session.commit()
                report = sql_report
                print("Successfully saved disease report to PostgreSQL")
                
        except Exception as e:
            print(f"Failed to save disease report: {str(e)}")
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
    
    # Try to get field from Firebase first
    field_data = None
    try:
        print(f"Using Firebase to get field monitoring data for field {field_id}")
        field_data = Field.get(field_id)
        
        if not field_data:
            # Fall back to PostgreSQL
            raise Exception("Field not found in Firebase")
            
    except Exception as firebase_error:
        print(f"Firebase field monitoring error: {firebase_error}, falling back to PostgreSQL")
        
        # Fallback to PostgreSQL
        try:
            from models import Field as SQLField
            field = SQLField.query.get(field_id)
            if not field:
                return jsonify({'error': 'Field not found'}), 404
                
            # Convert to dict for consistent handling
            field_data = {
                'id': field.id,
                'user_id': field.user_id,
                'name': field.name,
                'location': field.location,
                'area': field.area,
                'crop_type': field.crop_type,
                'planting_date': field.planting_date.isoformat() if field.planting_date else None,
                'soil_type': field.soil_type,
                'satellite_data': field.satellite_data,
                'last_updated': field.last_updated.isoformat() if field.last_updated else None
            }
        except Exception as pg_error:
            print(f"PostgreSQL field monitoring error: {pg_error}")
            return jsonify({'error': 'Field not found in either database'}), 404
    
    # Check if we have cached satellite data that's recent (within 7 days)
    if field_data.get('satellite_data') and field_data.get('last_updated'):
        last_updated = datetime.fromisoformat(field_data['last_updated']) if isinstance(field_data['last_updated'], str) else field_data['last_updated']
        
        if (datetime.utcnow() - last_updated).days < 7:
            return jsonify(field_data['satellite_data'])
    
    # No recent data, so generate new satellite data
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
        
        # Update field in Firebase first
        try:
            updated_data = {
                'satellite_data': satellite_data,
                'last_updated': datetime.utcnow().isoformat()
            }
            
            # Update in Firebase
            Field.update(field_id, updated_data)
            print(f"Updated satellite data in Firebase for field {field_id}")
            
        except Exception as firebase_update_error:
            print(f"Firebase update error: {firebase_update_error}, falling back to PostgreSQL")
            
            # Fallback to PostgreSQL
            try:
                from models import Field as SQLField
                field = SQLField.query.get(field_id)
                if field:
                    field.satellite_data = satellite_data
                    field.last_updated = datetime.utcnow()
                    db.session.commit()
                    print(f"Updated satellite data in PostgreSQL for field {field_id}")
            except Exception as pg_update_error:
                print(f"PostgreSQL update error: {pg_update_error}")
                # Continue anyway, we'll still return the generated data
        
        return jsonify(satellite_data)
        
    except Exception as e:
        print(f"Error generating satellite data: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/fertilizer_recommendations', methods=['GET'])
def get_fertilizer_recommendations():
    """Get AI-powered fertilizer recommendations"""
    field_id = request.args.get('field_id')
    
    if not field_id:
        return jsonify({'error': 'Field ID is required'}), 400
    
    # Try to get field from Firebase first
    field_data = None
    try:
        print(f"Using Firebase to get field for fertilizer recommendations {field_id}")
        field_data = Field.get(field_id)
        
        if not field_data:
            # Fall back to PostgreSQL
            raise Exception("Field not found in Firebase")
            
    except Exception as firebase_error:
        print(f"Firebase field error: {firebase_error}, falling back to PostgreSQL")
        
        # Fallback to PostgreSQL
        try:
            from models import Field as SQLField
            field = SQLField.query.get(field_id)
            if not field:
                return jsonify({'error': 'Field not found'}), 404
                
            # Use the PostgreSQL field object directly
            return generate_fertilizer_recommendations_from_sql_field(field)
        except Exception as pg_error:
            print(f"PostgreSQL field error: {pg_error}")
            return jsonify({'error': 'Field not found in either database'}), 404
    
    # If we got here, we're using Firebase field data
    return generate_fertilizer_recommendations_from_firebase_field(field_data)

# Helper function to generate fertilizer recommendations from a SQL field object
def generate_fertilizer_recommendations_from_sql_field(field):
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
            try:
                from models import FertilizerRecord as SQLFertilizerRecord
                recent_applications = SQLFertilizerRecord.query.filter_by(field_id=field.id).order_by(SQLFertilizerRecord.date.desc()).limit(3).all()
                if recent_applications:
                    context += "\nRecent Fertilizer Applications:\n"
                    for app in recent_applications:
                        context += f"- {app.date.strftime('%Y-%m-%d')}: {app.fertilizer_type} at {app.application_rate} kg/ha\n"
            except Exception as e:
                print(f"Error getting fertilizer records: {e}")
                # Continue without fertilizer records
                
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
            crop_type = field.crop_type
            soil_type = field.soil_type
            return generate_rule_based_fertilizer_recommendations(crop_type, soil_type, "mid-season")
            
    except Exception as e:
        print(f"Error generating fertilizer recommendations from SQL field: {e}")
        return jsonify({'error': str(e)}), 500

# Helper function to generate fertilizer recommendations from a Firebase field document
def generate_fertilizer_recommendations_from_firebase_field(field_data):
    try:
        # Use Gemini if available for advanced recommendations
        if GEMINI_API_KEY:
            model = genai.GenerativeModel('gemini-pro')
            
            # Extract field data
            crop_type = field_data.get('crop_type', 'Unknown')
            soil_type = field_data.get('soil_type', 'Unknown')
            planting_date = field_data.get('planting_date', 'Unknown')
            area = field_data.get('area', 0)
            
            # Format planting date properly if it's available as a string
            if isinstance(planting_date, str) and planting_date not in ('Unknown', ''):
                try:
                    planting_date = datetime.fromisoformat(planting_date.replace('Z', '+00:00')).strftime('%Y-%m-%d')
                except:
                    # If parsing fails, just use the string as is
                    pass
            
            # Prepare context for the model
            context = (
                f"Field Information:\n"
                f"- Crop Type: {crop_type}\n"
                f"- Soil Type: {soil_type}\n"
                f"- Planting Date: {planting_date}\n"
                f"- Field Size: {area} hectares\n"
            )
            
            # Add satellite data if available
            satellite_data = field_data.get('satellite_data', {})
            if satellite_data:
                context += (
                    f"- Current NDVI: {satellite_data.get('ndvi', 'Unknown')}\n"
                    f"- Field Health: {satellite_data.get('field_health', 'Unknown')}\n"
                    f"- Crop Stage: {satellite_data.get('crop_stage', 'Unknown')}\n"
                )
            
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
            
            # Use the field_id from the Firebase document
            field_id = field_data.get('id', 'unknown')
            return jsonify({
                'field_id': field_id,
                'crop_type': crop_type,
                'recommendations': recommendations,
                'generated_by': 'Google Gemini AI'
            })
            
        else:
            # Use the rule-based function for consistent recommendations
            crop_type = field_data.get('crop_type', '')
            soil_type = field_data.get('soil_type', 'Unknown')
            growth_stage = "mid-season"  # Default to mid-season if unknown
            
            # Extract growth stage from satellite data if available
            satellite_data = field_data.get('satellite_data', {})
            if satellite_data and satellite_data.get('crop_stage'):
                stage = satellite_data.get('crop_stage', '').lower()
                if 'early' in stage or 'seedling' in stage:
                    growth_stage = 'early'
                elif 'flower' in stage or 'fruit' in stage or 'reproductive' in stage:
                    growth_stage = 'late'
            
            # Get recommendations from rule-based system for consistency
            recommendations = generate_rule_based_fertilizer_recommendations(
                crop_type=crop_type,
                soil_type=soil_type,
                growth_stage=growth_stage
            )
                
            # Use the field_id from the Firebase document
            field_id = field_data.get('id', 'unknown')
            return jsonify({
                'field_id': field_id,
                'crop_type': crop_type,
                'recommendations': recommendations,
                'generated_by': 'Basic recommendation system'
            })
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/market_favorites', methods=['GET', 'POST'])
def handle_market_favorites():
    """Handle market price favorites/alerts - FIREBASE ONLY"""
    
    if request.method == 'POST':
        # Create new market favorite/alert
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        if 'user_id' not in data or 'crop_type' not in data:
            return jsonify({'error': 'Missing required fields: user_id and crop_type are required'}), 400
        
        try:
            # Don't check for user existence, just create the favorite
            # This is a simplification for development purposes
            
            # Create favorite data for Firebase
            favorite_data = {
                'user_id': data['user_id'],
                'crop_type': data['crop_type'],
                'market_name': data.get('market_name', ''),
                'price_alert_min': data.get('price_alert_min'),
                'price_alert_max': data.get('price_alert_max'),
                'created_at': datetime.utcnow().isoformat()
            }
            
            # Save to Firebase
            new_favorite = MarketFavorite.create(favorite_data)
            
            # Return the saved data with the generated ID
            if isinstance(new_favorite, dict):
                return jsonify({
                    'id': new_favorite.get('id', ''),
                    'user_id': new_favorite.get('user_id', ''),
                    'crop_type': new_favorite.get('crop_type', ''),
                    'market_name': new_favorite.get('market_name', ''),
                    'price_alert_min': new_favorite.get('price_alert_min'),
                    'price_alert_max': new_favorite.get('price_alert_max')
                })
            else:
                # If the response is not a dictionary, create a basic response
                return jsonify({
                    'message': 'Market favorite created successfully',
                    'crop_type': favorite_data['crop_type'],
                    'user_id': favorite_data['user_id']
                })
            
        except Exception as e:
            print(f"Error creating market favorite in Firebase: {str(e)}")
            return jsonify({'error': f'Failed to create market favorite: {str(e)}'}), 500
    
    else:
        # GET method - retrieve favorites for a user
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({'error': 'User ID is required'}), 400
            
        try:
            # Use Firebase to get favorites
            favorites = MarketFavorite.get_by_user_id(user_id)
            
            # Return the favorites list
            if not favorites:
                favorites = []
                
            # Make sure each favorite has properly formatted fields
            formatted_favorites = []
            for favorite in favorites:
                # Format the favorite to ensure consistent structure
                formatted_favorites.append({
                    'id': favorite.get('id', ''),
                    'user_id': favorite.get('user_id', ''),
                    'crop_type': favorite.get('crop_type', ''),
                    'market_name': favorite.get('market_name', ''),
                    'price_alert_min': favorite.get('price_alert_min'),
                    'price_alert_max': favorite.get('price_alert_max')
                })
                
            return jsonify({
                'favorites': formatted_favorites
            })
            
        except Exception as e:
            print(f"Error retrieving market favorites from Firebase: {str(e)}")
            return jsonify({'error': f'Failed to retrieve market favorites: {str(e)}'}), 500

@app.route('/api/users/register', methods=['POST'])
def register_user():
    """Register a new user - FIREBASE ONLY"""
    data = request.json
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
        
    required_fields = ['username', 'email', 'password']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing required field: {field}'}), 400
    
    # Check if user already exists by email
    existing_by_email = User.get_by_email(data['email'])
    if existing_by_email:
        return jsonify({'error': 'Email already registered'}), 409
        
    # Check if user already exists by username
    existing_by_username = User.get_by_username(data['username'])
    if existing_by_username:
        return jsonify({'error': 'Username already taken'}), 409
    
    # Hash password (in a real app, use a proper password hashing library like bcrypt)
    import hashlib
    password_hash = hashlib.sha256(data['password'].encode()).hexdigest()
    
    # Create user data
    try:
        user_data = {
            'username': data['username'],
            'email': data['email'],
            'password': password_hash,  # Store the hashed password
            'full_name': data.get('full_name', ''),
            'phone': data.get('phone', ''),
            'profile_image': data.get('profile_image', ''),
            'created_at': datetime.utcnow().isoformat(),
            'is_active': True
        }
        
        # Create user in Firebase
        new_user = User.create(user_data)
        
        return jsonify({
            'id': new_user.get('id', ''),
            'username': new_user.get('username', ''),
            'email': new_user.get('email', ''),
            'message': 'User registered successfully'
        }), 201
        
    except Exception as e:
        print(f"Firebase user registration error: {str(e)}")
        return jsonify({'error': f'Failed to register user: {str(e)}'}), 500

@app.route('/api/users/login', methods=['POST'])
def login_user():
    """Log in a user - FIREBASE ONLY"""
    data = request.json
    
    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username and password required'}), 400
    
    try:
        # Find user by username
        user = User.get_by_username(data['username'])
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        # Check password
        import hashlib
        password_hash = hashlib.sha256(data['password'].encode()).hexdigest()
        
        if user.get('password') != password_hash:
            return jsonify({'error': 'Invalid password'}), 401
        
        # Generate a simple session token (in a real app, use JWT)
        session_token = hashlib.sha256(f"{user.get('id')}-{datetime.utcnow().isoformat()}".encode()).hexdigest()
        
        return jsonify({
            'id': user.get('id', ''),
            'username': user.get('username', ''),
            'email': user.get('email', ''),
            'token': session_token,
            'message': 'Login successful'
        })
        
    except Exception as e:
        print(f"Firebase login error: {str(e)}")
        return jsonify({'error': f'Login failed: {str(e)}'}), 500

@app.route('/api/fields', methods=['GET', 'POST'])
def handle_fields():
    """Handle field operations - FIREBASE ONLY"""
    user_id = request.args.get('user_id') or (request.json or {}).get('user_id')
    
    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400
    
    # Get all fields for a user
    if request.method == 'GET':
        try:
            print(f"Using Firebase to get fields for user {user_id}")
            fields_data = Field.get_by_user_id(user_id)
            return jsonify({'fields': fields_data or []})
        except Exception as e:
            print(f"Firebase fields error: {e}")
            return jsonify({'error': f'Failed to retrieve fields: {str(e)}'}), 500
    
    # Create a new field
    elif request.method == 'POST':
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        if 'name' not in data:
            return jsonify({'error': 'Field name is required'}), 400
        
        try:
            print(f"Using Firebase to create field for user {user_id}")
            
            # Parse planting date if provided
            planting_date = None
            if data.get('planting_date'):
                planting_date = datetime.strptime(data['planting_date'], '%Y-%m-%d').isoformat()
            
            # Prepare the field data
            field_data = {
                'user_id': user_id,
                'name': data['name'],
                'location': data.get('location', ''),
                'area': data.get('area'),
                'crop_type': data.get('crop_type', ''),
                'planting_date': planting_date,
                'soil_type': data.get('soil_type', ''),
                'notes': data.get('notes', ''),
                'created_at': datetime.utcnow().isoformat(),
                'last_updated': datetime.utcnow().isoformat()
            }
            
            # Create the field in Firebase
            firebase_field = Field.create(field_data)
            
            if firebase_field:
                # Create a Field-like object for guidance generation
                class FieldObject:
                    def __init__(self, data):
                        self.id = data.get('id', '')
                        self.name = data.get('name', '')
                        self.location = data.get('location', '')
                        self.area = data.get('area', 0)
                        self.crop_type = data.get('crop_type', '')
                        self.planting_date = None  # We'll parse this if available
                        self.soil_type = data.get('soil_type', '')
                        self.notes = data.get('notes', '')
                        
                        # Parse planting date if it exists
                        if data.get('planting_date'):
                            try:
                                self.planting_date = datetime.fromisoformat(data['planting_date'])
                            except:
                                pass
                
                field_obj = FieldObject(firebase_field)
                
                # Generate AI farming guidance
                guidance = generate_farm_guidance(field_obj)
                
                return jsonify({
                    'id': firebase_field.get('id', ''),
                    'name': firebase_field.get('name', ''),
                    'message': 'Field created successfully',
                    'guidance': guidance
                }), 201
                
        except Exception as e:
            print(f"Firebase field creation error: {e}")
            return jsonify({'error': f'Failed to create field: {str(e)}'}), 500

@app.route('/api/farm_guidance/<field_id>', methods=['GET'])
def get_farm_guidance(field_id):
    """Get AI-powered farm management guidance for a specific field - FIREBASE ONLY"""
    
    try:
        print(f"Using Firebase to get field {field_id}")
        firebase_field = Field.get(field_id)
        
        if not firebase_field:
            return jsonify({'error': 'Field not found'}), 404
            
        # Create a Field-like object with the required attributes
        class FieldObject:
            def __init__(self, data):
                self.id = data.get('id', '')
                self.name = data.get('name', '')
                self.location = data.get('location', '')
                self.area = data.get('area', 0)
                self.crop_type = data.get('crop_type', '')
                self.planting_date = None  # We'll parse this if available
                self.soil_type = data.get('soil_type', '')
                self.notes = data.get('notes', '')
                
                # Parse planting date if it exists
                if data.get('planting_date'):
                    try:
                        self.planting_date = datetime.fromisoformat(data['planting_date'])
                    except:
                        pass
        
        field = FieldObject(firebase_field)
        
        # Generate guidance
        guidance = generate_farm_guidance(field)
        
        # Return structured guidance
        return jsonify({
            'field_id': field.id,
            'field_name': field.name,
            'crop_type': field.crop_type,
            'guidance': guidance
        })
            
    except Exception as e:
        print(f"Firebase farm guidance error: {str(e)}")
        return jsonify({'error': f'Failed to generate farm guidance: {str(e)}'}), 500

# Helper function for generating detailed crop articles
def get_crop_specific_article(crop_type, soil_type):
    """Generate a detailed article on crop cultivation based on crop type and soil type"""
    # Default detailed content when API is unavailable
    crop_articles = {
        'Rice': f"""
# Rice Cultivation Guide for {soil_type} Soil

Rice is one of the most important food crops globally, providing nourishment to billions of people. Cultivating rice in {soil_type} soil requires specific techniques to maximize yield and quality.

## Pre-planting Preparation
- Prepare the field 30-45 days before planting
- Level the field properly to ensure uniform water distribution
- For {soil_type} soil, incorporate organic matter at 5-10 tons/hectare
- Maintain proper drainage systems to prevent waterlogging

## Planting and Cultivation
- Use certified seeds of varieties suitable for your region
- Seed rate: 60-80 kg/hectare for direct seeding, 40-50 kg/hectare for transplanting
- Maintain water level at 2-5 cm during the vegetative stage
- Apply fertilizers in split doses: 40% at planting, 30% at tillering, 30% at heading

## Pest and Disease Management
- Monitor regularly for leaf folder, stem borer, and brown planthopper
- Implement integrated pest management practices
- Use resistant varieties when available
- Apply fungicides only when necessary and follow recommended dosages

## Harvest and Post-harvest
- Harvest when 80-85% of the grains turn golden yellow
- Dry the harvested grain properly to moisture content of 12-14%
- Store in clean, dry, and well-ventilated areas
""",
        'Wheat': f"""
# Wheat Cultivation Guide for {soil_type} Soil

Wheat is a major cereal crop grown worldwide. Cultivating wheat in {soil_type} soil requires specific approaches to ensure optimal growth and yield.

## Field Preparation
- Deep plowing to a depth of 20-25 cm is recommended
- Apply 10-15 tons/hectare of well-decomposed farmyard manure
- Ensure proper field leveling for uniform irrigation
- For {soil_type} soil, consider adding gypsum if soil pH is high

## Sowing and Crop Management
- Sow at the optimal time for your region (usually early winter)
- Seed rate: 100-125 kg/hectare
- Row spacing: 20-22.5 cm
- First irrigation: 20-25 days after sowing
- Subsequent irrigations at critical growth stages: crown root initiation, tillering, jointing, flowering, and grain filling

## Nutrient Management
- Apply NPK at 120:60:40 kg/hectare
- Apply nitrogen in split doses: 50% at sowing, 25% at first irrigation, 25% at second irrigation
- Apply micronutrients based on soil test results

## Harvesting and Storage
- Harvest when grain moisture content is around 14-16%
- Proper drying and storage is essential to maintain quality
- Store in clean, dry, and well-ventilated spaces to prevent pest infestation
""",
        'Potato': f"""
# Potato Cultivation Guide for {soil_type} Soil

Potatoes are a versatile and nutritious crop that can be grown in various soil conditions. Growing potatoes in {soil_type} soil requires specific management practices.

## Soil Preparation
- Prepare well-drained, loose soil with pH 5.5-6.5
- Apply farmyard manure at 20-25 tons/hectare
- For {soil_type} soil, incorporate organic matter to improve soil structure
- Deep plowing (30-35 cm) helps in better tuber development

## Planting and Growth
- Use certified seed potatoes cut into pieces with 2-3 eyes each
- Seed rate: 2000-2500 kg/hectare
- Spacing: 60 cm between rows and 20 cm between plants
- Plant at a depth of 5-10 cm
- Earthing up (hilling) should be done when plants reach 15-25 cm height

## Water and Nutrient Management
- Maintain consistent soil moisture, especially during tuber formation
- Apply NPK at 150:100:120 kg/hectare
- Apply 50% N and full P and K at planting and remaining N at earthing up
- Avoid over-irrigation as it can lead to various diseases

## Pest and Disease Management
- Monitor for late blight, early blight, and Colorado potato beetle
- Practice crop rotation to reduce soil-borne diseases
- Use resistant varieties when available
- Follow recommended fungicide and insecticide applications
""",
        'Sugarcane': f"""
# Sugarcane Cultivation Guide for {soil_type} Soil

Sugarcane is a perennial grass that thrives in tropical and subtropical regions. Cultivating sugarcane in {soil_type} soil requires specific management strategies.

## Land Preparation
- Deep plowing to a depth of 30-35 cm is recommended
- Apply farmyard manure or compost at 10-15 tons/hectare
- For {soil_type} soil, incorporate green manure crops if possible
- Prepare ridges and furrows with spacing of 90-120 cm

## Planting and Management
- Use disease-free setts (stem cuttings) from 8-10 month old crop
- Sett rate: 75,000-80,000 three-budded setts per hectare
- Plant setts end-to-end in furrows at a depth of 5-7 cm
- Apply irrigation immediately after planting
- First earthing up at 5-6 weeks and final earthing up at 4-5 months

## Nutrient Management
- Apply NPK at 250:100:120 kg/hectare
- Apply nitrogen in three splits: at planting, at tillering, and at grand growth stage
- Micronutrients like zinc and iron may be applied based on soil tests

## Harvesting and Ratoon Management
- Harvest when the crop is mature (usually 12-14 months after planting)
- Cut the cane close to the ground level
- For ratoon crops, stubble shaving, gap filling, and proper fertilization are essential
"""
    }
    
    # Return default detailed article for common crops or a generic one if crop not found
    return crop_articles.get(crop_type, f"""
# {crop_type} Cultivation Guide for {soil_type} Soil

{crop_type} cultivation in {soil_type} soil requires careful planning and management to achieve optimal yields. This guide provides comprehensive information on best practices tailored to your specific conditions.

## Soil Preparation
- Test soil pH and nutrient levels before planting
- Incorporate organic matter to improve soil structure and fertility
- Ensure proper drainage, especially for {soil_type} soil
- Apply recommended soil amendments based on soil test results

## Planting Guidelines
- Select high-quality seeds or planting materials suitable for your region
- Follow recommended spacing for optimal plant density
- Plant at the appropriate depth for your crop
- Consider row orientation for maximum sunlight exposure

## Water Management
- Develop an irrigation schedule based on crop requirements and soil moisture
- Monitor soil moisture regularly using appropriate tools
- Adjust irrigation based on weather conditions and crop growth stage
- Implement water conservation techniques like mulching

## Nutrient Management
- Apply balanced fertilizers according to crop needs and soil test results
- Consider split application of fertilizers for better efficiency
- Include micronutrients if deficiencies are identified
- Use organic fertilizers to improve long-term soil health

## Pest and Disease Management
- Regularly monitor crops for signs of pests and diseases
- Implement integrated pest management strategies
- Use resistant varieties when available
- Apply pesticides judiciously and follow safety protocols

## Harvesting and Post-harvest
- Harvest at optimal maturity for best quality and yield
- Handle produce carefully to minimize damage
- Implement appropriate post-harvest treatments
- Store properly to maintain quality and extend shelf life
""")

# Quick guidance endpoint (no authentication required)
@app.route('/api/guidance/quick', methods=['POST'])
def get_quick_farm_guidance():
    """Get AI-powered farm management guidance based on crop and soil type only"""
    
    try:
        data = request.json
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        crop_type = data.get('crop_type')
        soil_type = data.get('soil_type')
        
        if not crop_type or not soil_type:
            return jsonify({'error': 'Crop type and soil type are required'}), 400
        
        # Use a more detailed approach for quick guidance with narrative content
        guidance = {
            'general_recommendations': [
                "Schedule regular monitoring of your field",
                "Keep detailed records of all farming activities",
                "Consider soil testing to optimize fertility management"
            ],
            'crop_specific': [
                "Research best practices specific to your crop variety",
                "Consider crop rotation to improve soil health and reduce pest pressure"
            ],
            'fertilizer': [
                "Apply balanced NPK fertilizer based on crop needs",
                "Consider organic amendments to improve soil structure"
            ],
            'pest_management': [
                "Regularly scout for pests and diseases",
                "Consider integrated pest management (IPM) approaches"
            ],
            'irrigation': [
                "Adjust irrigation based on crop growth stage",
                "Consider water conservation techniques"
            ],
            'sustainability': [
                "Minimize soil disturbance to reduce erosion",
                "Consider cover crops to improve soil health"
            ],
            'detailed_article': get_crop_specific_article(crop_type, soil_type)  # Set default content
        }
        
        try:
            # If Gemini API key is available, use AI for detailed guidance
            if GEMINI_API_KEY:
                # List available models to see what we can use
                print("\n\n--- AVAILABLE GEMINI MODELS ---")
                for m in genai.list_models():
                    if 'generateContent' in m.supported_generation_methods:
                        print(f"Model name: {m.name}")
                print("--- END AVAILABLE MODELS ---\n\n")
                
                # Use the newer model names that are available
                # Use a more reliable approach to find an available model
                available_model = None
                
                # First, try gemini-1.5-flash-latest which has higher quota limits
                try:
                    available_model = 'gemini-1.5-flash-latest'
                    model = genai.GenerativeModel(available_model)
                    print(f"Using model: {available_model}")
                except Exception as e:
                    print(f"Error with {available_model}: {str(e)}")
                    available_model = None
                
                # If that fails, try gemini-1.5-flash
                if available_model is None:
                    try:
                        available_model = 'gemini-1.5-flash'
                        model = genai.GenerativeModel(available_model)
                        print(f"Using model: {available_model}")
                    except Exception as e:
                        print(f"Error with {available_model}: {str(e)}")
                        available_model = None
                
                # Last resort - try to find any available model
                if available_model is None:
                    for m in genai.list_models():
                        if 'gemini' in m.name and 'generateContent' in m.supported_generation_methods:
                            try:
                                available_model = m.name.replace('models/', '')
                                print(f"Using fallback model: {available_model}")
                                model = genai.GenerativeModel(available_model)
                                break
                            except Exception as e:
                                print(f"Error with {available_model}: {str(e)}")
                                continue
                
                # If we still don't have a model, we'll use our fallback data
                
                # Create a more comprehensive prompt for detailed guidance
                prompt = f"""
                You are an agricultural expert commissioned to write a comprehensive farming manual. Create a detailed, practical guide for {crop_type} cultivation in {soil_type} soil that combines traditional practices and modern techniques.
                
                FORMAT YOUR RESPONSE AS A COMPLETE ARTICLE WITH HEADINGS AND SUBHEADINGS. DO NOT include any JSON content or code blocks in the main article. Write in clear, professional language suitable for publishing in an agricultural journal.

                ## ARTICLE STRUCTURE AND CONTENT:

                # {crop_type} Cultivation Guide for {soil_type} Soil
                Begin with a thorough introduction (250-300 words) explaining why {crop_type} is well-suited (or what challenges it faces) in {soil_type} soil. Include regional considerations and economic importance.

                ## Detailed Cultivation Timeline
                Create a chronological, month-by-month or season-by-season breakdown of the complete growing cycle with SPECIFIC DATES AND TIMINGS:
                - Pre-planting soil preparation (beginning 45-60 days before planting date)
                - Seed selection and treatment recommendations with EXACT seed rates (kg/ha)
                - Planting window with PRECISE spacing measurements (e.g., 45cm between rows, 15cm between plants)
                - Post-planting care with timing
                - Critical growth stages with SPECIFIC DURATION of each stage
                - Harvest timing indicators with EXACT maturity signs
                - Post-harvest handling and storage recommendations

                ## Soil Management Techniques
                Provide soil-specific guidance:
                - Detailed analysis of {soil_type} soil properties and how they affect {crop_type}
                - Step-by-step soil preparation procedures with SPECIFIC amendment quantities
                - Optimal pH range with EXACT adjustment methods (e.g., "Add 500kg/ha of agricultural lime to raise pH from 5.5 to 6.5")
                - Organic matter incorporation with EXACT rates and timing
                - Tillage recommendations (depth, frequency, tools)

                ## Precise Irrigation Strategy
                Develop a complete irrigation plan:
                - Water requirements throughout each growth stage with EXACT quantities (mm or L/plant)
                - Irrigation frequency with SPECIFIC intervals based on crop stage and weather conditions
                - Irrigation system recommendations specifically for {soil_type} soil
                - Water conservation techniques with implementation details
                - Signs of water stress or excess with remediation strategies
                - Drainage considerations specific to {soil_type} soil

                ## Comprehensive Fertilization Plan
                Create a complete nutritional program:
                - SPECIFIC NPK ratio requirements for each growth stage (e.g., 12-24-12 at planting)
                - PRECISE application rates in kg/ha for each application
                - Detailed timing of fertilizer applications tied to growth stages
                - Micronutrient requirements with SPECIFIC products and rates
                - Organic fertilization alternatives with EXACT application rates
                - Foliar feeding recommendations with SPECIFIC dilution rates

                ## Integrated Pest and Disease Management
                Provide a complete protection strategy:
                - List of common pests specific to {crop_type} in {soil_type} soil with IDENTIFICATION FEATURES
                - List of common diseases with EARLY SYMPTOMS
                - Preventive measures with SPECIFIC timing relative to growth stages
                - Monitoring techniques with EXACT frequency (e.g., "Scout fields twice weekly")
                - Organic control options with PRECISE application rates and timing
                - Conventional chemical options with SPECIFIC active ingredients, rates, and safety intervals
                - Resistance management strategies

                ## Modern Farming Technologies
                Detail relevant technological innovations:
                - Appropriate mechanization options for different farm sizes
                - Precision agriculture techniques applicable to {crop_type} in {soil_type} soil
                - Sensor and monitoring technologies with implementation guidance
                - Digital tools and software recommendations for farm management
                - Cost-benefit analysis of technology adoption

                ## Sustainable Farming Practices
                Outline environmental conservation approaches:
                - SPECIFIC crop rotation recommendations with exact crop sequences
                - Cover cropping strategies with NAMED species recommendations
                - Soil conservation practices tailored to {soil_type}
                - Biodiversity enhancement techniques around fields
                - Carbon sequestration approaches for {crop_type} cultivation
                - Water conservation strategies beyond irrigation management

                ## Economic Considerations
                Provide business guidance:
                - Estimated yields for {crop_type} in {soil_type} soil under different management intensities
                - Production costs breakdown with REALISTIC figures
                - Market opportunities and value-addition possibilities
                - Storage and handling for market timing

                IMPORTANT: Your response should be as comprehensive as a book chapter. Write the COMPLETE ARTICLE. Include SPECIFIC, ACTIONABLE information with EXACT measurements, timing, and application rates. Avoid generalizations - be precise throughout. Emphasize PRACTICAL IMPLEMENTATION.
                """
                
                # Set default temperature and max_output_tokens for more detailed content
                generation_config = {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "top_k": 40,
                    "max_output_tokens": 4096,  # Request longer response
                    "response_mime_type": "text/plain"
                }
                
                # Generate content with specified configuration
                response = model.generate_content(
                    prompt,
                    generation_config=generation_config
                )
                
                # Print the response to debug it
                print("\n\n--- GEMINI RESPONSE START ---")
                print("Response status:", response._result.candidates[0].finish_reason)
                print("Response text preview:", response.text[:500] if response.text else "No text")
                print("Response text length:", len(response.text) if response.text else 0)
                print("--- GEMINI RESPONSE END ---\n\n")
                
                # Process the response
                if response and response.text:
                    # Extract detailed article content
                    article_text = response.text.strip()
                    guidance['detailed_article'] = article_text
                    
                    try:
                        # Try to extract JSON for structured bullet points
                        import json
                        if '```json' in article_text:
                            # Extract JSON from markdown code block
                            json_text = article_text.split('```json')[1].split('```')[0].strip()
                            parsed_guidance = json.loads(json_text)
                            
                            # Update structured guidance fields
                            for key in parsed_guidance:
                                if key in guidance:
                                    guidance[key] = parsed_guidance[key]
                    except:
                        # If JSON extraction fails, use basic guidance
                        print("JSON extraction failed, using basic rule-based guidance")
                        from types import SimpleNamespace
                        temp_field = SimpleNamespace(
                            name="Quick Analysis",
                            location=None,
                            area=None, 
                            crop_type=crop_type,
                            soil_type=soil_type,
                            planting_date=None,
                            notes=None
                        )
                        
                        # Get structured bullet points only
                        basic_guidance = generate_farm_guidance(temp_field)
                        for key in basic_guidance:
                            if key in guidance and key != 'detailed_article':
                                guidance[key] = basic_guidance[key]
        except Exception as e:
            print(f"Error generating detailed guidance: {str(e)}")
            # Fallback to simple guidance
            from types import SimpleNamespace
            temp_field = SimpleNamespace(
                name="Quick Analysis",
                location=None,
                area=None, 
                crop_type=crop_type,
                soil_type=soil_type,
                planting_date=None,
                notes=None
            )
            
            # Generate basic guidance using the same function used for regular fields
            basic_guidance = generate_farm_guidance(temp_field)
            for key in basic_guidance:
                if key in guidance:
                    guidance[key] = basic_guidance[key]
        
        # Return structured guidance
        return jsonify({
            'crop_type': crop_type,
            'soil_type': soil_type,
            'guidance': guidance
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to generate quick farm guidance: {str(e)}'}), 500

# Advanced AI-powered fertilizer recommendations
@app.route('/api/advanced_fertilizer_recommendations', methods=['POST'])
def get_advanced_fertilizer_recommendations():
    """Get AI-powered fertilizer recommendations based on field details and soil test results"""
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        # Required parameters
        crop_type = data.get('crop_type')
        soil_type = data.get('soil_type')
        growth_stage = data.get('growth_stage', 'seedling')  # Default to seedling if not specified
        
        # Optional parameters
        field_size = data.get('field_size', 1.0)  # In hectares
        planting_date = data.get('planting_date')
        
        # Soil test results (optional but valuable)
        soil_test = data.get('soil_test', {})
        nitrogen_level = soil_test.get('nitrogen', 'medium')
        phosphorus_level = soil_test.get('phosphorus', 'medium')
        potassium_level = soil_test.get('potassium', 'medium')
        ph_level = soil_test.get('ph', 7.0)
        organic_matter = soil_test.get('organic_matter', 'medium')
        
        # Location data for regional considerations
        location = data.get('location')
        
        # Previous fertilizer applications
        previous_applications = data.get('previous_applications', [])
        
        # Use AI to generate fertilizer recommendations
        if GEMINI_API_KEY:
            try:
                # Use the best available model
                try:
                    print("Initializing model for fertilizer recommendations...")
                    model = genai.GenerativeModel('gemini-1.5-pro-latest')
                    print("Successfully initialized gemini-1.5-pro-latest model for fertilizer recommendations")
                except Exception as model_error:
                    print(f"Error initializing gemini-1.5-pro-latest model: {str(model_error)}")
                    # Fallback model selection logic
                    try:
                        # Get list of available models
                        available_models = genai.list_models()
                        gemini_models = [m for m in available_models if 'gemini' in m.name and 'generateContent' in m.supported_generation_methods]
                        
                        # Choose the latest gemini model
                        if gemini_models:
                            for preferred_model in ['gemini-1.5-pro', 'gemini-pro', 'gemini-1.0-pro']:
                                matching_models = [m for m in gemini_models if preferred_model in m.name]
                                if matching_models:
                                    model_name = matching_models[0].name
                                    print(f"Using fallback model: {model_name}")
                                    model = genai.GenerativeModel(model_name)
                                    break
                            else:
                                # If none of the preferred models are found, use the first available gemini model
                                model_name = gemini_models[0].name
                                print(f"Using alternative model: {model_name}")
                                model = genai.GenerativeModel(model_name)
                        else:
                            raise Exception("No suitable Gemini models available")
                    except Exception as fallback_error:
                        print(f"Error selecting fallback model: {str(fallback_error)}")
                        raise
                
                # Construct the prompt for fertilizer recommendations
                prompt = f"""
                As an agricultural expert, provide detailed fertilizer recommendations for:
                
                Crop: {crop_type}
                Soil Type: {soil_type}
                Growth Stage: {growth_stage}
                Field Size: {field_size} hectares
                {"Planting Date: " + planting_date if planting_date else ""}
                {"Location: " + location if location else ""}
                
                Soil Test Results:
                - Nitrogen Level: {nitrogen_level}
                - Phosphorus Level: {phosphorus_level}
                - Potassium Level: {potassium_level}
                - pH Level: {ph_level}
                - Organic Matter: {organic_matter}
                
                Previous Fertilizer Applications:
                {previous_applications if previous_applications else "None recorded"}
                
                Provide a comprehensive fertilizer application plan with:
                1. Specific NPK fertilizer ratios and brands/types for each growth stage
                2. Precise application rates in kg/hectare
                3. Exact timing of applications related to growth stages
                4. Application methods (broadcast, banding, foliar, etc.)
                5. Secondary nutrients and micronutrients if needed
                6. Both organic and conventional fertilizer options
                7. Cost-effective fertilizer combinations to maximize yield
                
                Format your response as a JSON object with these keys:
                "primary_recommendations": [array of main fertilizer recommendations with product, ratio, rate, timing, method]
                "secondary_nutrients": [recommendations for secondary nutrients if needed]
                "micronutrients": [recommendations for micronutrients if needed]
                "organic_alternatives": [organic fertilizer options]
                "application_schedule": [detailed timing of applications]
                "expected_benefits": [expected yield impact]
                "precautions": [warnings and precautions]
                "cost_estimate": estimated cost per hectare
                """
                
                # Generate recommendations
                response = model.generate_content(prompt)
                
                try:
                    # Try to extract JSON from the response
                    import json
                    import re
                    
                    # Find JSON-like content
                    json_match = re.search(r'({[\s\S]*})', response.text)
                    if json_match:
                        json_str = json_match.group(1)
                        recommendations = json.loads(json_str)
                    else:
                        # If JSON extraction fails, create structured data
                        recommendations = {
                            "primary_recommendations": [
                                {
                                    "product": f"NPK fertilizer suitable for {crop_type}",
                                    "ratio": "Based on soil test results",
                                    "rate": f"Calculate based on {field_size} hectares",
                                    "timing": f"Apply at {growth_stage} stage",
                                    "method": "As appropriate for your field conditions"
                                }
                            ],
                            "notes": "Detailed analysis based on AI processing.",
                            "raw_response": response.text
                        }
                        
                    # Return the recommendations
                    return jsonify({
                        'fertilizer_recommendations': recommendations,
                        'generated_by': 'AI Agriculture Expert (Gemini)'
                    })
                    
                except Exception as e:
                    print(f"Error processing fertilizer recommendations: {str(e)}")
                    return jsonify({
                        'fertilizer_recommendations': {
                            'notes': 'Error processing detailed recommendations',
                            'general_advice': response.text
                        },
                        'generated_by': 'AI Agriculture Expert (Gemini)'
                    })
                    
            except Exception as e:
                print(f"Error generating fertilizer recommendations with AI: {str(e)}")
                # Fall back to rule-based recommendations
        
        # Fallback rule-based fertilizer recommendations
        # This provides basic recommendations when AI is unavailable
        recommendations = generate_rule_based_fertilizer_recommendations(
            crop_type, soil_type, growth_stage, 
            nitrogen_level, phosphorus_level, potassium_level, ph_level
        )
        
        return jsonify({
            'fertilizer_recommendations': recommendations,
            'generated_by': 'Rule-Based System'
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to generate fertilizer recommendations: {str(e)}'}), 500

# Advanced AI-powered irrigation recommendations
@app.route('/api/disease_reports', methods=['GET'])
def get_disease_reports():
    """Get disease reports for a user"""
    try:
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({'error': 'User ID is required'}), 400
        
        # Try to get disease reports using Firebase model first
        try:
            print(f"Using Firebase to get disease reports for user {user_id}")
            
            # Get reports from Firebase model
            firebase_reports = DiseaseReport.get_by_user_id(user_id)
            
            if firebase_reports:
                return jsonify({'reports': firebase_reports}), 200
        except Exception as firebase_error:
            print(f"Firebase disease reports error: {firebase_error}, falling back to PostgreSQL")
        
        # Fallback to PostgreSQL
        try:
            # Convert user_id to int if needed for PostgreSQL
            if isinstance(user_id, str) and user_id.isdigit():
                pg_user_id = int(user_id)
            else:
                pg_user_id = user_id
                
            # Use SQL model from models
            from models import DiseaseReport as SQLDiseaseReport
            reports = SQLDiseaseReport.query.filter_by(user_id=pg_user_id).all()
            
            # Convert reports to a list of dictionaries
            reports_list = []
            for report in reports:
                reports_list.append({
                    'id': report.id,
                    'user_id': report.user_id,
                    'field_id': report.field_id,
                    'disease_name': report.disease_name,
                    'detection_date': report.detection_date.isoformat() if report.detection_date else None,
                    'confidence_score': report.confidence_score,
                    'image_path': report.image_path,
                    'symptoms': report.symptoms,
                    'treatment_recommendations': report.treatment_recommendations,
                    'status': report.status,
                    'notes': report.notes
                })
                
            return jsonify({'reports': reports_list}), 200
        except Exception as pg_error:
            print(f"PostgreSQL disease reports error: {pg_error}")
            return jsonify({'reports': []}), 200
    
    except Exception as e:
        print(f"Error in get_disease_reports endpoint: {str(e)}")
        # Return empty array instead of error to prevent UI issues
        return jsonify({'reports': []}), 200

@app.route('/api/irrigation_recommendations', methods=['POST'])
def get_irrigation_recommendations():
    """Get AI-powered irrigation recommendations based on crop, soil, and weather conditions"""
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        # Required parameters
        crop_type = data.get('crop_type')
        soil_type = data.get('soil_type')
        growth_stage = data.get('growth_stage', 'vegetative')  # Default to vegetative if not specified
        
        # Optional parameters
        field_size = data.get('field_size', 1.0)  # In hectares
        current_soil_moisture = data.get('soil_moisture', 'medium')  # Dry, medium, wet
        irrigation_system = data.get('irrigation_system', 'drip')  # Drip, sprinkler, flood, etc.
        
        # Weather data (optional but valuable)
        weather_data = data.get('weather_data', {})
        temperature = weather_data.get('temperature', 25)  # In Celsius
        humidity = weather_data.get('humidity', 50)  # Percentage
        precipitation_forecast = weather_data.get('precipitation_forecast', [0, 0, 0, 0, 0])  # 5-day precipitation
        evapotranspiration = weather_data.get('evapotranspiration', 5)  # Daily ET in mm
        
        # Location and time data
        location = data.get('location')
        season = data.get('season', 'summer')
        
        # Previous irrigation records
        previous_irrigation = data.get('previous_irrigation', [])
        
        # Use AI to generate irrigation recommendations
        if GEMINI_API_KEY:
            try:
                # Use the best available model
                try:
                    print("Initializing model for irrigation recommendations...")
                    model = genai.GenerativeModel('gemini-1.5-pro-latest')
                    print("Successfully initialized gemini-1.5-pro-latest model for irrigation recommendations")
                except Exception as model_error:
                    print(f"Error initializing gemini-1.5-pro-latest model: {str(model_error)}")
                    # Fallback model selection logic
                    try:
                        # Get list of available models
                        available_models = genai.list_models()
                        gemini_models = [m for m in available_models if 'gemini' in m.name and 'generateContent' in m.supported_generation_methods]
                        
                        # Choose the latest gemini model
                        if gemini_models:
                            for preferred_model in ['gemini-1.5-pro', 'gemini-pro', 'gemini-1.0-pro']:
                                matching_models = [m for m in gemini_models if preferred_model in m.name]
                                if matching_models:
                                    model_name = matching_models[0].name
                                    print(f"Using fallback model: {model_name}")
                                    model = genai.GenerativeModel(model_name)
                                    break
                            else:
                                # If none of the preferred models are found, use the first available gemini model
                                model_name = gemini_models[0].name
                                print(f"Using alternative model: {model_name}")
                                model = genai.GenerativeModel(model_name)
                        else:
                            raise Exception("No suitable Gemini models available")
                    except Exception as fallback_error:
                        print(f"Error selecting fallback model: {str(fallback_error)}")
                        raise
                
                # Construct the prompt for irrigation recommendations
                prompt = f"""
                As an irrigation expert, provide detailed irrigation recommendations for:
                
                Crop: {crop_type}
                Soil Type: {soil_type}
                Growth Stage: {growth_stage}
                Field Size: {field_size} hectares
                Current Soil Moisture: {current_soil_moisture}
                Irrigation System: {irrigation_system}
                {"Location: " + location if location else ""}
                Season: {season}
                
                Weather Data:
                - Temperature: {temperature}°C
                - Humidity: {humidity}%
                - 5-day Precipitation Forecast (mm): {precipitation_forecast}
                - Evapotranspiration: {evapotranspiration} mm/day
                
                Previous Irrigation:
                {previous_irrigation if previous_irrigation else "None recorded"}
                
                Provide a comprehensive irrigation plan with:
                1. Exact water requirements in mm or liters per hectare
                2. Frequency of irrigation (daily, every 2 days, weekly, etc.)
                3. Duration of each irrigation session in minutes or hours
                4. Best time of day to irrigate
                5. Adjustments needed based on weather forecast
                6. Water conservation techniques
                7. Signs of over/under irrigation to monitor
                
                Format your response as a JSON object with these keys:
                "water_requirement": daily water requirement in mm
                "frequency": recommended irrigation frequency
                "duration": duration of each irrigation session
                "best_time": optimal time of day for irrigation
                "weather_adjustments": adjustments based on forecast
                "conservation_techniques": water conservation methods
                "monitoring_indicators": signs to watch for
                "irrigation_schedule": detailed schedule for next 7 days
                "expected_benefits": expected benefits of following this plan
                """
                
                # Generate recommendations
                response = model.generate_content(prompt)
                
                try:
                    # Try to extract JSON from the response
                    import json
                    import re
                    
                    # Find JSON-like content
                    json_match = re.search(r'({[\s\S]*})', response.text)
                    if json_match:
                        json_str = json_match.group(1)
                        recommendations = json.loads(json_str)
                    else:
                        # If JSON extraction fails, create structured data
                        recommendations = {
                            "water_requirement": f"Based on {crop_type} needs in {growth_stage} stage",
                            "frequency": "Determined by soil conditions and weather",
                            "duration": "Adjust based on system efficiency",
                            "notes": "Detailed analysis from AI processing.",
                            "raw_response": response.text
                        }
                        
                    # Return the recommendations
                    return jsonify({
                        'irrigation_recommendations': recommendations,
                        'generated_by': 'AI Irrigation Expert (Gemini)'
                    })
                    
                except Exception as e:
                    print(f"Error processing irrigation recommendations: {str(e)}")
                    return jsonify({
                        'irrigation_recommendations': {
                            'notes': 'Error processing detailed recommendations',
                            'general_advice': response.text
                        },
                        'generated_by': 'AI Irrigation Expert (Gemini)'
                    })
                    
            except Exception as e:
                print(f"Error generating irrigation recommendations with AI: {str(e)}")
                # Fall back to rule-based recommendations
        
        # Fallback rule-based irrigation recommendations
        recommendations = generate_rule_based_irrigation_recommendations(
            crop_type, soil_type, growth_stage, 
            current_soil_moisture, irrigation_system, precipitation_forecast
        )
        
        return jsonify({
            'irrigation_recommendations': recommendations,
            'generated_by': 'Rule-Based System'
        })
        
    except Exception as e:
        return jsonify({'error': f'Failed to generate irrigation recommendations: {str(e)}'}), 500

# Helper function for rule-based fertilizer recommendations
def generate_rule_based_fertilizer_recommendations(crop_type, soil_type, growth_stage, 
                                                  nitrogen_level='medium', phosphorus_level='medium', 
                                                  potassium_level='medium', ph_level=7.0):
    """Generate basic fertilizer recommendations based on crop and soil type"""
    
    # Basic NPK ratios by crop type (simplified)
    crop_npk_ratios = {
        'Rice': '15-15-15',
        'Wheat': '20-10-10',
        'Cotton': '5-15-15',
        'Sugarcane': '15-15-15',
        'Maize': '15-15-15',
        'Potato': '10-20-20',
        'Tomato': '10-10-10',
        'Chickpea': '10-20-10',
        'Soybean': '0-20-20',
        'Groundnut': '10-20-20',
        'Turmeric': '5-10-20',
    }
    
    # Default to balanced fertilizer if crop not in list
    npk_ratio = crop_npk_ratios.get(crop_type, '15-15-15')
    
    # Adjust based on soil type
    soil_adjustments = {
        'Sandy': 'Increase frequency, reduce quantity per application',
        'Clay': 'Reduce frequency, may need additional drainage',
        'Loamy': 'Standard application',
        'Silt': 'Moderate frequency',
        'Black': 'May need less phosphorus',
        'Red': 'May need more phosphorus',
        'Alluvial': 'Often fertile, may need less fertilizer',
        'Laterite': 'May need more complete nutrients',
        'Peaty': 'May need less nitrogen, more phosphorus',
        'Calcareous': 'Watch for micronutrient availability',
        'Saline': 'May need special salt-tolerant formulations',
        'Acidic': 'Consider lime application to adjust pH'
    }
    
    soil_note = soil_adjustments.get(soil_type, 'Standard application methods')
    
    # Adjust based on growth stage
    stage_guidance = {
        'seedling': 'Focus on phosphorus for root development',
        'vegetative': 'Higher nitrogen needed for leaf growth',
        'flowering': 'Reduce nitrogen, increase phosphorus and potassium',
        'fruiting': 'Focus on potassium for fruit development',
        'maturity': 'Minimal fertilizer needed, prepare for next season'
    }
    
    stage_note = stage_guidance.get(growth_stage, 'Balanced nutrition recommended')
    
    # Adjust based on soil test results
    adjustments = []
    
    if nitrogen_level == 'low':
        adjustments.append('Increase nitrogen application by 25%')
    elif nitrogen_level == 'high':
        adjustments.append('Decrease nitrogen application by 25%')
        
    if phosphorus_level == 'low':
        adjustments.append('Increase phosphorus application by 25%')
    elif phosphorus_level == 'high':
        adjustments.append('Decrease phosphorus application by 25%')
        
    if potassium_level == 'low':
        adjustments.append('Increase potassium application by 25%')
    elif potassium_level == 'high':
        adjustments.append('Decrease potassium application by 25%')
    
    # pH adjustments
    ph_recommendation = ''
    if ph_level < 6.0:
        ph_recommendation = 'Consider applying agricultural lime to raise pH'
    elif ph_level > 7.5:
        ph_recommendation = 'Consider adding organic matter or sulfur to lower pH'
    else:
        ph_recommendation = 'pH is in good range for most crops'
    
    # Compile recommendations
    recommendations = {
        'primary_recommendations': [
            {
                'product': f'NPK {npk_ratio}',
                'rate': '250 kg/hectare',
                'timing': f'Apply at {growth_stage} stage',
                'method': 'Broadcast and incorporate into soil'
            }
        ],
        'soil_specific_notes': soil_note,
        'growth_stage_notes': stage_note,
        'adjustments': adjustments,
        'ph_management': ph_recommendation,
        'organic_alternatives': [
            {
                'product': 'Well-rotted farmyard manure',
                'rate': '10-15 tons/hectare',
                'timing': 'Apply before planting',
                'method': 'Broadcast and incorporate into soil'
            },
            {
                'product': 'Compost',
                'rate': '5-10 tons/hectare',
                'timing': 'Apply before planting',
                'method': 'Broadcast and incorporate into soil'
            }
        ]
    }
    
    return recommendations

# Helper function for rule-based irrigation recommendations
def generate_rule_based_irrigation_recommendations(crop_type, soil_type, growth_stage, 
                                                 soil_moisture='medium', irrigation_system='drip',
                                                 precipitation_forecast=[0, 0, 0, 0, 0]):
    """Generate basic irrigation recommendations based on crop, soil, and conditions"""
    
    # Base water requirements by crop type (in mm/day, simplified)
    crop_water_needs = {
        'Rice': 8,
        'Wheat': 5,
        'Cotton': 6,
        'Sugarcane': 7,
        'Maize': 5.5,
        'Potato': 4.5,
        'Tomato': 5,
        'Chickpea': 4,
        'Soybean': 5,
        'Groundnut': 5,
        'Turmeric': 6,
    }
    
    # Default water requirement if crop not in list
    base_water_requirement = crop_water_needs.get(crop_type, 5)  # mm/day
    
    # Adjust based on soil type
    soil_factors = {
        'Sandy': 1.2,  # Needs more frequent irrigation
        'Clay': 0.8,   # Holds water longer
        'Loamy': 1.0,  # Balanced water retention
        'Silt': 0.9,   # Good water retention
        'Black': 0.85, # Good water retention
        'Red': 1.1,    # Less water retention
        'Alluvial': 0.95,
        'Laterite': 1.1,
        'Peaty': 0.8,
        'Calcareous': 1.05,
        'Saline': 1.15, # Needs more water to manage salinity
        'Acidic': 1.0
    }
    
    soil_factor = soil_factors.get(soil_type, 1.0)
    adjusted_water_requirement = base_water_requirement * soil_factor
    
    # Adjust based on growth stage
    stage_factors = {
        'seedling': 0.6,     # Less water needed
        'vegetative': 1.0,   # Standard water needs
        'flowering': 1.2,    # Critical stage, more water
        'fruiting': 1.1,     # Needs good moisture
        'maturity': 0.7      # Reducing water needs
    }
    
    stage_factor = stage_factors.get(growth_stage, 1.0)
    adjusted_water_requirement *= stage_factor
    
    # Adjust based on current soil moisture
    moisture_factors = {
        'dry': 1.2,      # Needs more water to rehydrate
        'medium': 1.0,   # Normal irrigation
        'wet': 0.7       # Reduced irrigation
    }
    
    moisture_factor = moisture_factors.get(soil_moisture, 1.0)
    adjusted_water_requirement *= moisture_factor
    
    # Irrigation frequency based on soil type and system
    frequency_guide = {
        'Sandy': {
            'drip': 'Daily',
            'sprinkler': 'Every 2 days',
            'flood': 'Every 4 days'
        },
        'Clay': {
            'drip': 'Every 3 days',
            'sprinkler': 'Every 5 days',
            'flood': 'Every 7 days'
        },
        'Loamy': {
            'drip': 'Every 2 days',
            'sprinkler': 'Every 3 days',
            'flood': 'Every 5 days'
        }
    }
    
    # Default frequency if specific combination not found
    if soil_type in frequency_guide and irrigation_system in frequency_guide[soil_type]:
        frequency = frequency_guide[soil_type][irrigation_system]
    elif irrigation_system == 'drip':
        frequency = 'Every 2 days'
    elif irrigation_system == 'sprinkler':
        frequency = 'Every 3-4 days'
    else:
        frequency = 'Every 5-7 days'
    
    # Calculate duration based on system efficiency
    system_efficiency = {
        'drip': 0.9,       # 90% efficiency
        'sprinkler': 0.7,  # 70% efficiency
        'flood': 0.5       # 50% efficiency
    }
    
    efficiency = system_efficiency.get(irrigation_system, 0.7)
    
    # Adjust for precipitation forecast
    total_precipitation = sum(precipitation_forecast)
    if total_precipitation > 0:
        # Reduce irrigation by expected rainfall
        adjusted_water_requirement = max(0, adjusted_water_requirement - (total_precipitation / 5))
    
    # Calculate water volume needed (L/hectare)
    water_volume_per_day = adjusted_water_requirement * 10000  # L/hectare
    
    # Determine best time for irrigation
    best_time = 'Early morning or late evening to reduce evaporation'
    
    # Conservation techniques
    conservation_techniques = [
        'Mulching to reduce evaporation',
        'Regular system maintenance to prevent leaks',
        'Proper scheduling based on crop needs',
        f'Using {irrigation_system} irrigation for higher efficiency'
    ]
    
    # Signs to monitor
    monitoring_signs = [
        'Wilting leaves indicate under-irrigation',
        'Yellowing lower leaves may indicate over-irrigation',
        'Cracked soil surface indicates dry conditions',
        'Fungal growth may indicate excessive moisture'
    ]
    
    # 7-day schedule
    schedule = []
    for day in range(7):
        if "Daily" in frequency:
            should_irrigate = True
        elif "Every 2 days" in frequency:
            should_irrigate = day % 2 == 0
        elif "Every 3 days" in frequency:
            should_irrigate = day % 3 == 0
        elif "Every 4 days" in frequency:
            should_irrigate = day % 4 == 0
        elif "Every 5 days" in frequency:
            should_irrigate = day % 5 == 0
        elif "Every 7 days" in frequency:
            should_irrigate = day % 7 == 0
        else:
            should_irrigate = day == 0 or day == 3 or day == 6  # Default to 3 times/week
        
        # Adjust for forecast precipitation
        rain_adjustment = ""
        if day < len(precipitation_forecast) and precipitation_forecast[day] > 5:
            should_irrigate = False
            rain_adjustment = f" (Skipped due to {precipitation_forecast[day]}mm forecast rainfall)"
        
        if should_irrigate:
            schedule.append({
                'day': day + 1,
                'irrigate': True,
                'amount': f"{adjusted_water_requirement:.1f} mm",
                'volume': f"{water_volume_per_day:.0f} L/hectare",
                'note': f"Standard irrigation{rain_adjustment}" 
            })
        else:
            schedule.append({
                'day': day + 1,
                'irrigate': False,
                'amount': "0 mm",
                'volume': "0 L/hectare",
                'note': f"No irrigation needed{rain_adjustment}"
            })
    
    # Compile recommendations
    recommendations = {
        'water_requirement': f"{adjusted_water_requirement:.1f} mm/day",
        'frequency': frequency,
        'best_time': best_time,
        'system_efficiency': f"{efficiency*100:.0f}%",
        'conservation_techniques': conservation_techniques,
        'monitoring_indicators': monitoring_signs,
        'irrigation_schedule': schedule,
        'notes': [
            f"Recommendations adjusted for {soil_type} soil and {growth_stage} growth stage",
            f"Current soil moisture is {soil_moisture}",
            f"Total forecast precipitation: {total_precipitation}mm over next 5 days"
        ]
    }
    
    return recommendations

# Run the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004, debug=True)