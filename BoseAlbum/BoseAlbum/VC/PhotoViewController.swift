//
//  PhotoViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/17/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseStorage

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: User?
    var albumName = ""
    var album = Album()
    let storage = Storage.storage()
    var imagePicker = UIImagePickerController()
    var curImage: UIImage?
    var viewer = false
    var fullAlbumName = ""
    
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSpinner(onView: self.view)
        navigationItem.rightBarButtonItem = editButtonItem
        if viewer == true {
            addBarButtonItem.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        else {
            navigationItem.title = self.albumName
            fullAlbumName = user!.userID + albumName
        }
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePicker.delegate = self
        album.delegate = self

        let layout = photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: (photoCollectionView.frame.size.width - 20)/2, height: photoCollectionView.frame.size.height/4)
        
        retrievePhotos()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueFromPhotoToImage" {
            let targetController = segue.destination as! ImageViewController
            targetController.selectedImage = self.curImage!
        }
        
        if segue.identifier == "segueFromPhotoToShare" {
            let targetController = segue.destination as! ShareViewController
            targetController.urlString = "bosealbum://" + fullAlbumName
        }
    }
    
    func retrievePhotos() {
        let baseURL = "http:0.0.0.0:5000/retrieveImages"
        let parameters = ["album_name": self.fullAlbumName]
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                print("Error: No data to decode")
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
                print(error ?? "error")
                return
            }
            
            guard let dictionary = json as? [String:Any] else {
                print(error ?? "error")
                return
            }
            
            if let photo_names = dictionary["photo_names"] as? [String: Any] {
                self.album.photoNames = Array(photo_names.keys).sorted().map {$0+".jpeg"}
                if self.album.photoNames.count != 0 {
                    for photoName in self.album.photoNames {
                        let storageRef = self.storage.reference()
                        let imageRef = storageRef.child(photoName)
                        
                        imageRef.getData(maxSize: 1 * 4096 * 4096, completion: { (data, error) in
                            if let error = error {
                                print("!!!!!!!!!")
                                print(error)
                            }
                            else {
                                self.album.photos.append(UIImage(data: data!)!)
                            }
                        })
                    }
                    while true {
                        if self.album.photoNames.count != 0 && self.album.photoNames.count == self.album.photos.count {
                            self.removeSpinner()
                            break
                        }
                    }
                }
                else {
                    self.removeSpinner()
                }
            }
            else {
                self.removeSpinner()
            }

            
        }.resume()
    }
    
    @IBAction func importImage(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true) {
            // After picking
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let oriImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.album.photos.append(oriImage)
//            self.photoCollectionView.reloadData()
//            let imageData = oriImage.jpegData(compressionQuality: 1.0)!.base64EncodedString(options: .lineLength64Characters)
//            let data = Data((base64Encoded: imageData))
            let imageData = oriImage.jpegData(compressionQuality: 0.1)
        
            if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                let stringImageUrl = imageURL.absoluteString
                let stringImageUrlArr = stringImageUrl.components(separatedBy: "/")
                let localName = stringImageUrlArr.last
                self.album.photoNames.append(self.user!.userID + localName!)
                let storageRef = storage.reference()
                let imageRef = storageRef.child(self.user!.userID + localName!)
                self.showSpinner(onView: self.view)
                imageRef.putData(imageData!, metadata: nil) { metadata, error in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("Upload success")
                        let baseURL = "http:0.0.0.0:5000/importImage"
                        let parameters = ["url": self.user!.userID + localName!, "user_id": self.user!.userID, "album_name": self.albumName]
                        
                        guard let url = URL(string: baseURL) else { return }
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
                        request.httpBody = httpBody
                        
                        let session = URLSession.shared
                        session.dataTask(with: request) { (data, response, error) in
                            guard let data = data else {
                                print("Error: No data to decode")
                                return
                            }
                            
                            guard let generalResponse = try? JSONDecoder().decode(GeneralResponse.self, from: data) else {
                                print("Error: Couldn't decode data into GeneralResponse")
                                return
                            }
                            
                            if generalResponse.status == "success" {
        //                            self.retrievePhotos()
                                DispatchQueue.main.async {
                                    self.photoCollectionView.reloadData()
                                }
                                
                                print("database add success")
                            }
                            else {
                                print("import photo server database error")
                            }
                            self.removeSpinner()
                        }.resume()
                    }
                }
            }
        }
        else {
            print("Error: reading images")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareAlbum(_ sender: Any) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = self.album.photos[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 2
        self.curImage = self.album.photos[indexPath.item]
        
        self.performSegue(withIdentifier: "segueFromPhotoToImage", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addBarButtonItem.isEnabled = !editing
        if let indexPaths = photoCollectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = photoCollectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    cell.isEditing = editing
                }
            }
        }
    }
    
    // MUSIC
    @IBAction func previousTapped(_ sender: Any) {
        songIndex -= 1
        do {
            let audioPath = Bundle.main.path(forResource: mySongs[songIndex], ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            
            var items = self.toolBar.items
            items![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(HomeViewController.playTapped(_:)))
            self.toolBar.setItems(items, animated: true)
        }
        catch {
            print("Error loading music")
        }
    }
    
    @IBAction func playTapped(_ sender: Any) {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            var items = self.toolBar.items
            items![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.play, target: self, action: #selector(HomeViewController.playTapped(_:)))
            self.toolBar.setItems(items, animated: true)
        }
        else {
            audioPlayer.play()
            var items = self.toolBar.items
            items![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(HomeViewController.playTapped(_:)))
            self.toolBar.setItems(items, animated: true)
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        songIndex += 1
        do {
            let audioPath = Bundle.main.path(forResource: mySongs[songIndex], ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
            
            var items = self.toolBar.items
            items![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.pause, target: self, action: #selector(HomeViewController.playTapped(_:)))
            self.toolBar.setItems(items, animated: true)
        }
        catch {
            print("Error loading music")
        }
    }
    
    
}

extension PhotoViewController: PhotoCollectionViewCellDelegate {
    func delete(cell: PhotoCollectionViewCell) {
        if let indexPath = photoCollectionView?.indexPath(for: cell) {
            showSpinner(onView: self.view)
            // delete datasource
            album.photos.remove(at: indexPath.item)
            let storage_url = album.photoNames.remove(at: indexPath.item)
            
            // delete in collection view
//            photoCollectionView?.deleteItems(at: [indexPath])
//            self.photoCollectionView.reloadData()
            
            // delete in database
            let baseURL = "http:0.0.0.0:5000/deleteImage"
            let parameters = ["url": storage_url, "user_id": self.user!.userID, "album_name": self.albumName]
            
            guard let url = URL(string: baseURL) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody = httpBody
            
            let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    print("Error: No data to decode")
                    return
                }
                
                guard let generalResponse = try? JSONDecoder().decode(GeneralResponse.self, from: data) else {
                    print("Error: Couldn't decode data into GeneralResponse")
                    return
                }
                
                if generalResponse.status == "success" {
                    print("database delete success")
                }
                else {
                    print("delete photo server database error")
                }
            }.resume()
            
            // delete in datastore
            let storageRef = self.storage.reference()
            let imageRef = storageRef.child(storage_url)
            imageRef.delete {
                error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print(error)
                } else {
                    // File deleted successfully
                    DispatchQueue.main.async {
                        self.photoCollectionView.reloadData()
                    }
                    print("successfully delete in firestore")
                }
            }
            removeSpinner()
        }
    }
}

extension PhotoViewController: AlbumDelegate {
    func updateCollectionView() {
        photoCollectionView.reloadData()
    }
}

var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
