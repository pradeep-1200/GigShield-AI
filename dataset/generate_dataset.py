import pandas as pd
import numpy as np
import random
import os

def generate_dataset(num_rows=300):
    np.random.seed(42)
    random.seed(42)
    
    cities = ['Chennai', 'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Pune', 'Kolkata']
    platforms = ['Zomato', 'Swiggy', 'Zepto', 'Blinkit', 'Amazon', 'Flipkart']

    data = []
    
    for _ in range(num_rows):
        city = random.choice(cities)
        rainfall_mm = random.randint(0, 200)
        temperature_c = random.randint(25, 45)
        aqi = random.randint(50, 400)
        flood_history = random.choice([0, 1])
        working_hours = random.randint(6, 10)
        weekly_income = random.randint(4000, 7000)
        platform = random.choice(platforms)
        
        # Risk score formula:
        # risk = (rainfall/200 + temperature/50 + aqi/500) / 3
        risk = (rainfall_mm/200 + temperature_c/50 + aqi/500) / 3
        
        # Ensure risk doesn't exceed 1.0
        disruption_risk = min(risk, 1.0)
        
        data.append([
            city, rainfall_mm, temperature_c, aqi, flood_history, 
            working_hours, weekly_income, platform, round(disruption_risk, 4)
        ])
        
    df = pd.DataFrame(data, columns=[
        'city', 'rainfall_mm', 'temperature_c', 'aqi', 'flood_history', 
        'working_hours', 'weekly_income', 'platform', 'disruption_risk'
    ])
    
    output_path = os.path.join(os.path.dirname(__file__), 'gig_worker_risk_dataset.csv')
    df.to_csv(output_path, index=False)
    print(f"Dataset generated successfully at {output_path}")

if __name__ == "__main__":
    generate_dataset()
