from flask import Flask
from firebase_helper import * 

user_id
app = Flask(__name__)

@app.route('/signup', methods = ['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    global user_id
    user_id = create_user(email, password)
    return json.dumps(user_id)

@app.route('/login', methods = ['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    global user_id
    user_id = auth_user(email, password)
    return json.dumps(user_id)

if __name__ == "__main__":
    app.run(
        debug=True,
        port=5000,
        host='0.0.0.0'
    )
