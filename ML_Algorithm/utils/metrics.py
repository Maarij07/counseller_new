def accuracy_score(true, pred, max_score=10):
    mae = sum(abs(true - pred)) / len(true)
    return 1 - mae / max_score
