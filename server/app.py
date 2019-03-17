from flask import Flask, json, request
from firebase_helper import *

user_id
app = Flask(__name__)

@app.route('/signup', methods = ['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    global user_id
    try:
        user_id = create_user(email, password)
        response = {"userID": user_id}
    except Exception as e:
        error = json.loads(e.strerror)
        errorMessage = error['error']['message']
        print(errorMessage)
        response = {"error": errorMessage}
    return json.dumps(response)

@app.route('/login', methods = ['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    global user_id
    try:
        user_id = auth_user(email, password)
        response = {"userID": user_id}
    except Exception as e:
        error = json.loads(e.strerror)
        errorMessage = error['error']['message']
        response = {"error": errorMessage}

    return json.dumps(response)

if __name__ == "__main__":
    firebase_init()
    app.run(
        debug=True,
        port=5000,
        host='0.0.0.0'
    )
