from abc import ABC, abstractmethod

class BaseRegressor(ABC):
    @abstractmethod
    def train(self, X_train, y_train): pass

    @abstractmethod
    def evaluate(self, X_test, y_test, scaler): pass

    @abstractmethod
    def predict(self, X): pass
