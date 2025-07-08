from flask import Flask, request, jsonify
from sentence_transformers import SentenceTransformer
import joblib
import firebase_admin
from firebase_admin import credentials, firestore
import numpy as np
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load model, scaler, and PCA transformer
logger.info("Loading ML models and transformers...")
model = joblib.load("ML_Algorithm/models/regression_model.pkl")
scaler = joblib.load("ML_Algorithm/models/target_scaler.pkl")
pca = joblib.load("ML_Algorithm/models/pca_transformer.pkl")
labse = SentenceTransformer("sentence-transformers/LaBSE")
logger.info("Models loaded successfully")

# Initialize Firebase
firebase_key_path = "ML_Algorithm/therapyrobot-a8d2f-firebase-adminsdk-4nmam-0014eeaa1f.json"
cred = credentials.Certificate(firebase_key_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

app = Flask(__name__)

@app.route("/predict", methods=["POST"])
def predict():
    try:
        logger.info("Received prediction request")
        data = request.get_json()
        statement = data.get("statement")
        user_id = data.get("userId")

        if not statement or not user_id:
            logger.error("Missing statement or userId")
            return jsonify({"error": "Missing statement or userId"}), 400

        logger.info(f"Processing request for user {user_id}")
        logger.info(f"Statement: {statement}")

        # Get user data
        user_docs = db.collection("users").where("userID", "==", user_id).get()
        if not user_docs:
            logger.error(f"User not found: {user_id}")
            return jsonify({"error": "User not found"}), 404
        
        user_data = user_docs[0].to_dict()
        logger.info("User data retrieved successfully")

        # Get embeddings and transform
        logger.info("Generating embeddings...")
        embedding = labse.encode([statement])
        logger.info("Reducing dimensions...")
        embedding_reduced = pca.transform(embedding)
        embedding_scaled = embedding_reduced

        logger.info("Making prediction...")
        pred_scaled = model.predict(embedding_scaled)
        prediction = float(scaler.inverse_transform([[pred_scaled[0]]])[0][0])
        rounded_prediction = round(prediction, 2)
        logger.info(f"Prediction score: {rounded_prediction}")

        # Store prediction data
        prediction_data = {
            "userId": user_id,
            "statement": statement,
            "predictedScore": rounded_prediction,
            "timestamp": firestore.SERVER_TIMESTAMP,
            "userDetails": {
                "firstName": user_data.get("firstName", ""),
                "lastName": user_data.get("lastName", ""),
                "age": user_data.get("age", ""),
                "gender": user_data.get("gender", "")
            }
        }

        # Add to user_predictions collection
        logger.info("Storing prediction in Firestore...")
        db.collection("user_predictions").add(prediction_data)
        logger.info("Prediction stored successfully")

        return jsonify({
            "prediction": rounded_prediction,
            "userId": user_id,
            "timestamp": datetime.now().isoformat()
        })

    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, port=8080)