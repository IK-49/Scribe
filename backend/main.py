from flask import Flask, jsonify, request
import json

app = Flask(__name__)

@app.route('/promptGenerate', methods=['GET'])
def pick():
    return jsonify({"todaysPrompt": "What's your favorite book?"})

if __name__ == '__main__':
    app.run(debug=True, use_reloader=False)
