import logging
from flask import Flask, request, jsonify
import pickle
import pandas as pd
import requests
import os
import hashlib
import traceback

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
from flask_cors import CORS
CORS(app)

OPENWEATHER_API_KEY = os.environ.get("OPENWEATHER_API_KEY", "")

# Load model
try:
    BASE_DIR = os.path.dirname(__file__)
    model_path = os.path.join(BASE_DIR, 'risk_model.pkl')
    
    logger.info(f"Loading ML model from: {model_path}")
    if not os.path.exists(model_path):
        logger.error("ML model file not found!")

    with open(model_path, 'rb') as f:
        saved_data = pickle.load(f)
        model = saved_data['model']
        model_columns = saved_data['columns']
    logger.info("ML Model loaded successfully.")
except FileNotFoundError:
    model = None
    model_columns = None
    logger.warning("ML Model not found.")

def get_weather_and_aqi(city):
    if OPENWEATHER_API_KEY:
        try:
            # Weather API
            url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={OPENWEATHER_API_KEY}&units=metric"
            res = requests.get(url)
            if res.status_code == 404:
                return None
            res = res.json()
            temp = res["main"]["temp"]
            rain = res.get("rain", {}).get("1h", 0.0)
            lat, lon = res["coord"]["lat"], res["coord"]["lon"]
            
            # AQI API
            aqi_url = f"https://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={OPENWEATHER_API_KEY}"
            aqi_res = requests.get(aqi_url).json()
            aqi_level = aqi_res["list"][0]["main"]["aqi"]
            
            # Convert 1-5 to 50-400
            aqi_map = {1: 50, 2: 100, 3: 150, 4: 250, 5: 400}
            aqi_val = aqi_map.get(aqi_level, 150)
            
            return {"temperature": temp, "rainfall": rain, "aqi": aqi_val}
        except Exception as e:
            logger.error(f"Failed to fetch real weather. Error: {e}")

    # Fallback to algorithmic simulation based on hash of city name if API key absent
    city_hash = int(hashlib.md5(city.lower().encode('utf-8')).hexdigest(), 16)
    temp = 25.0 + (city_hash % 200) / 10.0 # 25 - 45 C
    rain = (city_hash % 1000) / 10.0 if city_hash % 3 == 0 else 0.0 # 0 - 100 mm, 33% chance of rain
    aqi = 50 + (city_hash % 350) # 50 - 400
    
    return {"temperature": round(temp, 1), "rainfall": round(rain, 1), "aqi": round(aqi, 0)}

def get_risk_level(score):
    if score < 0.3: return "Low Risk"
    if score < 0.6: return "Moderate Risk"
    return "High Risk"

@app.route("/predict-risk", methods=["POST"])
def predict_risk():
    try:
        data = request.json
        logger.info(f"Received risk prediction request for data: {data}")
        
        city = data.get('city', 'Chennai')
        real_env = get_weather_and_aqi(city)
        
        if real_env is None:
            return jsonify({"error": "Invalid city name. City not found."}), 404
            
        logger.info(f"Fetched weather for {city}: {real_env}")
        
        if model is None:
            return jsonify({"error": "ML Model not trained yet"}), 500
            
        input_data = {
            'city': city,
            'rainfall_mm': real_env["rainfall"],
            'temperature_c': real_env["temperature"],
            'aqi': real_env["aqi"],
            'flood_history': data.get('flood_history', 0),
            'working_hours': data.get('hours', 8),
            'weekly_income': data.get('income', 5000),
            'platform': data.get('platform', 'Zomato')
        }
        
        df = pd.DataFrame([input_data])
        df = pd.get_dummies(df)
        df = df.reindex(columns=model_columns, fill_value=0)
        
        model_risk = float(model.predict(df)[0])
        
        # Formula fallback to guarantee dynamic weighting logic requirement
        formula_risk = (real_env["rainfall"]/200 + real_env["temperature"]/50 + real_env["aqi"]/500) / 3
        final_risk = round(min((model_risk + formula_risk) / 2, 1.0), 2)
        risk_level = get_risk_level(final_risk)
        
        explanation = f"Why your risk is {risk_level}:\n"
        explanation += f"• Rainfall is {real_env['rainfall']} mm.\n"
        explanation += f"• Temperature is {real_env['temperature']}°C.\n"
        explanation += f"• AQI is {real_env['aqi']}.\n"
        if real_env['rainfall'] > 20 or real_env['temperature'] > 38 or real_env['aqi'] > 250:
            explanation += "These extreme environmental conditions significantly increase the probability of delivery disruptions."
        else:
            explanation += "Current environmental factors indicate safe delivery operations."

        logger.info(f"Calculated risk score: {final_risk}")
        return jsonify({
            "risk_score": final_risk,
            "risk_level": risk_level,
            "weather_data": real_env,
            "ai_explanation": explanation
        })
    except Exception as e:
        logger.error(f"Error in predict-risk: {e}\n{traceback.format_exc()}")
        return jsonify({
            "error": "Internal Server Error",
            "message": str(e),
            "traceback": traceback.format_exc()
        }), 500

@app.route("/calculate-premium", methods=["POST"])
def calculate_premium():
    data = request.json
    risk = data.get("risk", 0)
    income = data.get("income", 5000)
    
    logger.info(f"Calculating premium for risk: {risk}, income: {income}")
    
    coverage = income * 0.4
    premium = coverage * 0.03 * risk
    
    return jsonify({
        "coverage": round(coverage, 2),
        "premium": round(premium, 2)
    })

@app.route("/monitor-weather", methods=["GET"])
def monitor_weather():
    city = request.args.get('city', 'Chennai')
    demo_override = request.args.get('force_demo', 'false').lower() == 'true'
    
    logger.info(f"Monitoring live weather for {city} (Demo Override: {demo_override})")
    
    if demo_override:
        return jsonify({
            "temperature": 43.0, 
            "rainfall": 60.0,    
            "aqi": 380.0
        })
        
    real_env = get_weather_and_aqi(city)
    return jsonify(real_env)

@app.route("/claim-trigger", methods=["POST"])
def claim_trigger():
    data = request.json
    rainfall = data.get("rainfall", 0)
    temperature = data.get("temperature", 0)
    aqi = data.get("aqi", 0)
    weekly_income = data.get("weekly_income", 5000)
    working_hours = data.get("working_hours", 8)
    hours_lost = data.get("hours_lost", 4)
    
    logger.info("Checking claim parameters...")
    
    triggered = False
    reasons = []
    
    if rainfall > 50:
        triggered = True
        reasons.append(f"Rainfall > 50mm ({rainfall}mm)")
    if temperature > 42:
        triggered = True
        reasons.append(f"Temperature > 42°C ({temperature}°C)")
    if aqi > 350:
        triggered = True
        reasons.append(f"AQI > 350 ({aqi})")
        
    if triggered:
        hourly_income = weekly_income / (working_hours * 7)
        income_loss = hourly_income * hours_lost
        payout = income_loss * 0.4
        
        logger.warning(f"Claim automatically triggered! Reasons: {reasons}, Payout: {payout}")
        return jsonify({
            "status": "triggered",
            "reasons": reasons,
            "income_loss": round(income_loss, 2),
            "coverage_percent": 40,
            "payout": round(payout, 2)
        })
    else:
        logger.info("No claim triggers met.")
        return jsonify({
            "status": "not_triggered",
            "message": "No disruption conditions met"
        })

@app.route("/")
def health():
    return {"status": "GigShield AI backend running"}

if __name__ == "__main__":
    logger.info("Starting GigShield Flask Backend Server...")
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
