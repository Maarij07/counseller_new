from sentence_transformers import SentenceTransformer
from sklearn.preprocessing import MinMaxScaler
from scipy.stats import zscore
import numpy as np
from config import EMBEDDING_MODEL
labse = SentenceTransformer(EMBEDDING_MODEL)

# labse = SentenceTransformer("sentence-transformers/LaBSE")
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import numpy as np

def scale_features(X):
    scaler = StandardScaler()
    return scaler.fit_transform(X)

def reduce_dimensions(X, n_components=256):
    pca = PCA(n_components=n_components)
    return pca.fit_transform(X)

def embed_statements(statements):
    return labse.encode(statements.tolist(), show_progress_bar=True)

def scale_labels(labels, feature_range=(0, 10)):
    scaler = MinMaxScaler(feature_range=feature_range)
    y_scaled = scaler.fit_transform(labels.reshape(-1, 1)).flatten()
    return y_scaled, scaler

def filter_outliers(X, y_scaled, threshold=2):
    zscores = np.abs(zscore(y_scaled))
    mask = zscores < threshold
    return X[mask], y_scaled[mask]