import pyrebase


class MyFirebase:
    firebase = None
    db = None
    storage = None

myFirebase = MyFirebase()
user_id = None

def firebase_init():
    config = {
      "apiKey": "AIzaSyAh-pTR7rILd0VFoK0DG67rgZImhTEm4Ec",
      "authDomain": "bosealbum.firebaseapp.com",
      "databaseURL": "https://bosealbum.firebaseio.com/",
      "storageBucket": "bosealbum.appspot.com",
      "serviceAccount": "./credentials/bosealbum-firebase-adminsdk-ogbjs-b6254634cb.json"
    }

    global myFirebase
    myFirebase.firebase = pyrebase.initialize_app(config)
    myFirebase.db = myFirebase.firebase.database()
    myFirebase.storage = myFirebase.firebase.storage()

def auth_user(email, password):
    global myFirebase
    auth = myFirebase.firebase.auth()
    user = auth.sign_in_with_email_and_password(email, password)

    global user_id
    user_id = user['localId']

    return user_id


def create_user(email, password):
    global myFirebase
    auth = myFirebase.firebase.auth()
    user = auth.create_user_with_email_and_password(email, password)

    global user_id
    user_id = user['localId']
    user_init()
    return user_id

def user_init():
    global myFirebase
    album_data = {
        "album-count": "1",
        "album1": {}
    }
    myFirebase.db.child("Albums").child(user_id).set(album_data)
    return album_data
