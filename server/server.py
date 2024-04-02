from flask import Flask, request, jsonify
from flask_cors import CORS
from chatbot import answer_question

app = Flask(__name__)
CORS(app)

@app.route("/", methods=["POST"])
def home():
    question = request.get_json()["question"]
    return jsonify(answer_question(question))

@app.route("/dev")
def dev():
    return "<p>Hello, World!</p>"