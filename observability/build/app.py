from flask import Flask, jsonify
import os
from random import randint
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app)

@app.route('/', methods=['GET'])
def roll_dice():
    dice_value = randint(1, 6)
    return jsonify({'dice_value': dice_value})

@app.route("/fail")
def fail():
    1/0
    return 'fail'

@app.errorhandler(500)
def handle_500(error):
    return str(error), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)))