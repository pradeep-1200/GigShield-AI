# GigShield AI – AI Powered Parametric Insurance for Gig Workers

**Guidewire DevTrails 2026**
Team Name: **Binary Beats**
College: **Sri Eshwar College of Engineering**

## Overview
GigShield AI is a prototype platform that protects gig economy delivery workers from **income loss caused by external disruptions such as rain, heatwaves, floods, and pollution**.

## Features
1. Worker Registration
2. Risk Prediction using ML
3. Weekly Premium Calculation
4. Weather Monitoring
5. Disruption Trigger System
6. Claim Simulation
7. Worker Dashboard

## Architecture
- **Mobile App**: Flutter
- **Backend**: Python Flask API
- **Machine Learning**: Python, Scikit-learn (Random Forest Regression)
- **Database**: SQLite (Prototype logic integrated)
- **APIs**: OpenWeatherMap

## Folder Structure
```
├── dataset
│   ├── generate_dataset.py
│   └── gig_worker_risk_dataset.csv
├── ml
│   ├── train_model.py
│   └── risk_model.pkl
├── backend
│   └── app.py
├── mobile_app
│   └── flutter_app
└── README.md
```

## How to Run the Prototype

### 1. Start the Backend API (Flask)
The backend model relies on the generated `risk_model.pkl`. 
From the `d:\Projects\GigShield` directory, start the server:
```bash
python backend/app.py
```
*The server will start running on `http://127.0.0.1:5000`*

### 2. Run the Flutter Mobile App
Launch a new terminal, navigate to the Flutter project directory, and run the app on an emulator, Chrome, or physical device:
```bash
cd mobile_app/flutter_app
flutter run
```

### 3. Demo Flow Steps
Once both the Flask Backend and Flutter App are running:
1. **Registration Screen**: Enter your mock worker details (City, Income, Hours, Platform) and click **Calculate Risk**. (The app sends this to Flask, which predicts risk).
2. **Risk Result Screen**: Shows your mock worker’s automated Danger/Risk level. Click **Get Premium Quote**.
3. **Premium Screen**: Displays dynamic weekly premiums calculated based on the 40% loss formula. Click **Activate Insurance**.
4. **Disruption Monitor**: Tap the **Simulate Weather API Check** button. The flask backend will inject a high-danger environment (Rain > 50mm, Temp > 42°C) to simulate a real-world scenario.
5. **Claim Automation**: The app detects the hazard and will execute a claim pop-up. Click **Proceed to Claim** to view your automated payout metrics!

## Completed Modules
- [x] Synthetic dataset generation logic
- [x] ML Training script & Trained `.pkl` footprint
- [x] Flask Backend APIs (Risk, Premium, Weather, triggers)
- [x] Complete Flutter mobile app UI workflow
- [x] Simulated mock payouts based on worker algorithms
