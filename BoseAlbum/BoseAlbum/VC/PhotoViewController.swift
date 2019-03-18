//
//  PhotoViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/17/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var user: User?
    var albumName = ""
    var album = Album()
    let storage = Storage.storage()
    var imagePicker = UIImagePickerController()
    var curImage: UIImage?
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        imagePicker.delegate = self
        self.navigationItem.title = self.albumName
        
        
        let layout = self.photoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: (self.photoCollectionView.frame.size.width - 20)/2, height: self.photoCollectionView.frame.size.height/4)
        
        retrievePhotos()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueFromPhotoToImage"
        {
            let targetController = segue.destination as! ImageViewController
            targetController.selectedImage = self.curImage!
        }
    }
    
    func retrievePhotos() {
        let baseURL = "http:0.0.0.0:5000/retrieveImages"
        let parameters = ["user_id": self.user!.userID, "album_name": self.albumName]
        
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
            //            print(type(of: dictionary["album_count"]))
//            if let photo_count = dictionary["photo_count"] as? String {
//                self.album.photoCount = Int(photo_count) ?? 0
//            }
            
            if let photo_names = dictionary["photo_names"] as? [String: Any] {
                self.album.photoNames = Array(photo_names.keys).sorted().map {$0+".jpeg"}
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
                            self.album.photoCount += 1
                            DispatchQueue.main.async {
                                self.photoCollectionView.reloadData()
                            }
                        }
                    })
                }
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
            self.album.photoCount += 1
            self.album.photos.append(oriImage)
            self.photoCollectionView.reloadData()
        }
        
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            let stringImageUrl = imageURL.absoluteString
            let stringImageUrlArr = stringImageUrl.components(separatedBy: "/")
            let localName = stringImageUrlArr.last
            let storageRef = storage.reference()
            let imageRef = storageRef.child(self.user!.userID + localName!)
            imageRef.putFile(from: imageURL, metadata: nil) { metadata, error in
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
                            print("database add success")
                        }
                        else {
                            print("import photo server database error")
                        }
                    }.resume()
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
        return album.photoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = self.album.photos[indexPath.item]
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
}
