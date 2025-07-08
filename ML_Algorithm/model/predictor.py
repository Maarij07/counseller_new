from data.preprocessor import labse

def predict_statement(statement, model, scaler):
    vector = labse.encode([statement])
    scaled_pred = model.predict(vector)
    return scaler.inverse_transform([[scaled_pred[0]]])[0][0]
