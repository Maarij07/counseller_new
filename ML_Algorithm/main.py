from data.loader import load_and_clean_data
from data.preprocessor import (
    embed_statements, scale_labels,
    reduce_dimensions, filter_outliers
)
from data.preprocessor import scale_features
from sklearn.model_selection import train_test_split
from model.trainer import train_models
from model.save_load import save_model
from config import MODEL_OUTPUT_PATH, SCALER_OUTPUT_PATH
import numpy as np
from sklearn.decomposition import PCA

import matplotlib.pyplot as plt
# Add after loading and cleaning data
df = load_and_clean_data()

plt.hist(df["label"], bins=20, edgecolor='black')
plt.title("Label Distribution")
plt.xlabel("Score")
plt.ylabel("Frequency")
plt.show()

X = embed_statements(df["statement"])
y_scaled, scaler = scale_labels(df["label"].values)

# Fit PCA and save it
pca = PCA(n_components=128)
X = pca.fit_transform(X)
save_model(pca, "ML_Algorithm/models/pca_transformer.pkl")

X = scale_features(X)
# After embedding and scaling
X, y_scaled = filter_outliers(X, y_scaled, threshold=2)
X_train, X_test, y_train, y_test = train_test_split(
    X, y_scaled, test_size=0.2, random_state=42
)

print("Feature std dev:", np.std(X, axis=0).mean())

best_model, best_name, results = train_models(
    X_train, y_train, X_test, y_test, scaler
)

for name, (mae, rmse, r2, acc) in results.items():
    print(
        f"{name}: MAE={mae:.2f}, RMSE={rmse:.2f}, "
        f"R^2={r2:.2f}, Accuracy={acc*100:.2f}%"
    )
print(f"\nBest model: {best_name}")

save_model(best_model, MODEL_OUTPUT_PATH)
save_model(scaler, SCALER_OUTPUT_PATH)