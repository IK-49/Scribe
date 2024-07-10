from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/pick', methods=['GET'])
def pick():
    return jsonify({"todaysPick": "whats ur fav book"})



if __name__ == '__main__':
    app.run(debug=True)