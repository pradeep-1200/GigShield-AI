import pandas as pd
from sklearn.ensemble import RandomForestRegressor
import pickle
import os

def train_model():
    dataset_path = os.path.join(os.path.dirname(__file__), '..', 'dataset', 'gig_worker_risk_dataset.csv')
    data = pd.read_csv(dataset_path)

    X = data.drop("disruption_risk", axis=1)
    y = data["disruption_risk"]

    X = pd.get_dummies(X)

    model = RandomForestRegressor(random_state=42)
    model.fit(X, y)

    model_path = os.path.join(os.path.dirname(__file__), 'risk_model.pkl')
    
    # Save the model and columns to ensure aligning during prediction
    with open(model_path, 'wb') as f:
        pickle.dump({'model': model, 'columns': X.columns.tolist()}, f)
        
    print(f"Model trained and saved successfully at {model_path}")

if __name__ == "__main__":
    train_model()
