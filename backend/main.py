from flask import Flask, jsonify, request
import json

app = Flask(__name__)
responses = '''[
    {
      "user": "anon",
      "title": "Sample Title",
      "preview": "Sample Preview"
    }
]'''

@app.route('/pick', methods=['GET'])
def pick():
    return jsonify({"todaysPick": "What's your favorite book?"})

@app.route('/submit', methods=['POST'])
def submit():
    global responses
    new_post = request.get_json()
    responses_list = json.loads(responses)
    responses_list.insert(0, new_post)  # Add new post to the front of the list
    responses = json.dumps(responses_list)
    return jsonify({"status": "success"}), 200

@app.route('/responses', methods=['GET'])
def get_responses():
    return jsonify(json.loads(responses))

if __name__ == '__main__':
    app.run(debug=True, use_reloader=False)
