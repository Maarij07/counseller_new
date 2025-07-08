import numpy as np
from sklearn.ensemble import HistGradientBoostingRegressor, RandomForestRegressor, StackingRegressor, BaggingRegressor, VotingRegressor, AdaBoostRegressor
from sklearn.neural_network import MLPRegressor
from sklearn.svm import SVR
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from utils.metrics import accuracy_score
from sklearn.linear_model import Ridge
from sklearn.ensemble import ExtraTreesRegressor
# from lightgbm import LGBMRegressor
# from xgboost import XGBRegressor

def train_models(X_train, y_train, X_test, y_test, scaler):
    models = {
        # Tuned Random Forest
        "RandomForest": RandomForestRegressor(
            n_estimators=600, max_depth=15,
            min_samples_split=3, min_samples_leaf=1,
            random_state=42
        ),

        # "LightGBM": LGBMRegressor(
        #     n_estimators=300,
        #     learning_rate=0.05,
        #     max_depth=2,
        #     num_leaves=5,
        #     min_data_in_leaf=15,
        #     feature_fraction=0.9,
        #     bagging_fraction=0.9,
        #     bagging_freq=1,
        #     random_state=42
        # ),

        # Better HistGradientBoosting (slower learning, deeper trees)
        "HistGradientBoosting": HistGradientBoostingRegressor(
            max_iter=800, learning_rate=0.02,
            max_depth=8, l2_regularization=0.1,
            early_stopping=True, random_state=42
        ),

        # Tuned SVR with better hyperparameters
        "SVR": SVR(
            kernel='poly',
            degree=3, C=30,
            epsilon=0.05,
            gamma='scale'
        ),

        # Improved MLP with deeper architecture and early stopping
        "MLPRegressor": MLPRegressor(
            hidden_layer_sizes=(128, 64, 32),
            max_iter=1000, alpha=0.0001,
            early_stopping=True, random_state=42
        ),

        "BaggedSVR_poly": BaggingRegressor(
            estimator=SVR(kernel='poly', C=30, epsilon=0.05, degree=3, gamma='scale'),
            n_estimators=10, random_state=42
        ),
        "BaggedMLP": BaggingRegressor(
            estimator=MLPRegressor(hidden_layer_sizes=(128, 64), max_iter=1000, early_stopping=True, random_state=42),
            n_estimators=10, random_state=42
        ),
        "VotingRegressor": VotingRegressor(estimators=[
            ("svr", SVR(kernel='poly', C=30, epsilon=0.05, degree=3)),
            ("rf", RandomForestRegressor(n_estimators=400, max_depth=14)),
            ("mlp", MLPRegressor(hidden_layer_sizes=(128, 64), max_iter=1000))
        ]),
        "ExtraTrees": ExtraTreesRegressor(n_estimators=300, max_depth=14, random_state=42),

        # New: AdaBoost with Ridge (robust + low variance)
        "AdaBoostRidge": AdaBoostRegressor(
            estimator=Ridge(alpha=1.0),
            n_estimators=100, learning_rate=0.1, random_state=42
        ),

        # Stacking with tuned base models
        "Stacking": StackingRegressor(
            estimators=[
                ("rf", RandomForestRegressor(n_estimators=200, random_state=42)),
                ("svr", SVR(C=10, epsilon=0.1)),
                ("mlp", MLPRegressor(hidden_layer_sizes=(100, 50), max_iter=500, random_state=42))
            ],
            final_estimator=Ridge(alpha=1.0),
            passthrough=True
        )
    }

    results = {}
    best_model = None
    best_r2 = float('-inf')

    for name, model in models.items():
        model.fit(X_train, y_train)
        pred_scaled = model.predict(X_test)
        pred = scaler.inverse_transform(pred_scaled.reshape(-1, 1)).flatten()
        y_test_original = scaler.inverse_transform(y_test.reshape(-1, 1)).flatten()
        mae = mean_absolute_error(y_test_original, pred)
        rmse = np.sqrt(mean_squared_error(y_test_original, pred))
        r2 = r2_score(y_test_original, pred)
        acc = accuracy_score(y_test_original, pred)
        results[name] = (mae, rmse, r2, acc)
        if r2 > best_r2:
            best_r2 = r2
            best_model = model
            best_name = name
    return best_model, best_name, results


