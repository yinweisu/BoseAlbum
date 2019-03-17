import pyrebase


class MyFirebase:
    firebase = None
    db = None
    storage = None

myFirebase = MyFirebase()

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
    auth = myFirebase.firebase.auth()
    user = auth.sign_in_with_email_and_password(email, password)

    user_id = user['localId']

    return user_id


def create_user(email, password):
    auth = myFirebase.firebase.auth()
    user = auth.create_user_with_email_and_password(email, password)

    user_id = user['localId']
    user_init(user_id)
    return user_id

def retrieve_user_albums(user_id):
    db = myFirebase.db
    album_data = dict(db.child("Albums").child(user_id).get().val())
    print(album_data)
    return album_data

def create_uesr_album(user_id, album_name):
    db = myFirebase.db
    album_data = dict(db.child("Albums").child(user_id).get().val())
    if album_name in album_data:
        return False
    album_data["album_name"] = album_name
    album_data["album_count"] = album_data["album_count"] + 1
    db.child("Albums").child(user_id).update(album_data)
    return True

def user_init(user_id):
    global myFirebase
    album_data = {
        "album_count": "0"
    }
    myFirebase.db.child("Albums").child(user_id).set(album_data)
    return album_data
