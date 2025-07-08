from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    name = data.get('name')
    return jsonify({'message': f'Hello {name}, from Python!'})

if __name__ == '__main__':
    app.run(debug=True)
