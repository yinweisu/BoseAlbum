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

def user_init(user_id):
    global myFirebase
    album_data = {
        "album_count": "0"
    }
    myFirebase.db.child("Users").child(user_id).set(album_data)
    return album_data

def retrieve_user_albums(user_id):
    db = myFirebase.db
    album_data = dict(db.child("Users").child(user_id).get().val())
    print(album_data)
    return album_data

def create_uesr_album(user_id, album_name):
    db = myFirebase.db
    user_album = dict(db.child("Users").child(user_id).get().val())
    if "album_names" not in user_album:
        myFirebase.db.child("Users").child(user_id).child("album_names").set({user_id + album_name: ""})
        user_album["album_count"] = str(int(user_album["album_count"]) + 1)
        db.child("Users").child(user_id).update(user_album)
        db.child("Albums").child(user_id + album_name).set({"photo_count":"0"})
    else:
        album_data = dict(db.child("Users").child(user_id).child("album_names").get().val())
        print(album_data)
        if user_id + album_name in album_data:
            return False
        album_data[user_id + album_name] = ""
        user_album["album_count"] = str(int(user_album["album_count"]) + 1)
        db.child("Users").child(user_id).update(user_album)
        db.child("Users").child(user_id).child("album_names").update(album_data)
        db.child("Albums").child(user_id + album_name).set({"photo_count":"0"})
    return True

def upload_image(user_id, album_name, storage_url):
    print(storage_url)
    storage_url = storage_url.split(".")[0]
    db = myFirebase.db
    album = dict(db.child("Albums").child(user_id + album_name).get().val())
    if "photo_names" not in album:
        album["photo_count"] = str(int(album["photo_count"]) + 1)
        db.child("Albums").child(user_id+album_name).update(album)
        myFirebase.db.child("Albums").child(user_id+album_name).child("photo_names").set({storage_url: ""})
    else:
        photo_data = dict(db.child("Albums").child(user_id + album_name).child("photo_names").get().val())
        print(photo_data)
        if storage_url in photo_data:
            return False
        photo_data[storage_url] = ""
        album["photo_count"] = str(int(album["photo_count"]) + 1)
        db.child("Albums").child(user_id + album_name).update(album)
        db.child("Albums").child(user_id + album_name).child("photo_names").update(photo_data)

    return True

def delete_user_image(user_id, album_name, storage_url):
    storage_url = storage_url.split(".")[0]
    db = myFirebase.db
    album = dict(db.child("Albums").child(user_id + album_name).child("photo_names").get().val())
    print(album)
    album.pop(storage_url)
    print(album)
    db.child("Albums").child(user_id + album_name).child("photo_names").set(album)
    return True

def get_user_photos(user_id, album_name):
    db = myFirebase.db
    photo_data = dict(db.child("Albums").child(user_id+album_name).get().val())
    print(photo_data)
    return photo_data
