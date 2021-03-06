from flask import Flask, json, request
from firebase_helper import *

app = Flask(__name__)

@app.route('/signup', methods = ['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

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

    try:
        user_id = auth_user(email, password)
        response = {"userID": user_id}
    except Exception as e:
        error = json.loads(e.strerror)
        errorMessage = error['error']['message']
        response = {"error": errorMessage}

    return json.dumps(response)

@app.route('/retrieveAlbums', methods = ['POST'])
def retrieve_albums():
    data = request.get_json()
    user_id = data["user_id"]
    response = retrieve_user_albums(user_id)

    return json.dumps(response)
    # return json.dumps({"album_count": "0", "albums":[]})

@app.route('/createAlbum', methods = ['POST'])
def create_album():
    data = request.get_json()
    user_id = data["user_id"]
    album_name = data["album_name"]
    if create_uesr_album(user_id, album_name):
        response = {"status": "success"}
    else:
        response = {"status": "fail"}

    return json.dumps(response)

@app.route('/importImage', methods = ['POST'])
def import_image():
    data = request.get_json()
    storage_url = data['url']
    user_id = data['user_id']
    album_name = data['album_name']
    if upload_image(user_id, album_name, storage_url):
        response = {"status": "success"}
    else:
        response = {"status": "fail"}

    return json.dumps(response)

@app.route('/deleteImage', methods = ['POST'])
def delete_image():
    data = request.get_json()
    storage_url = data['url']
    user_id = data["user_id"]
    album_name = data["album_name"]
    delete_user_image(user_id, album_name, storage_url)

    return json.dumps({"status": "success"})

@app.route('/retrieveImages', methods = ['POST'])
def retrieve_images():
    data = request.get_json()
    album_name = data["album_name"]
    response = get_user_photos(album_name)

    return json.dumps(response)


if __name__ == "__main__":
    firebase_init()
    app.run(
        debug=True,
        port=5000,
        host='0.0.0.0'
    )
