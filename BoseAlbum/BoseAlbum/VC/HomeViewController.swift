//
//  HomeViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/16/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var user: User?
    var albums = Albums()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        var layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width - 20)/2, height: self.collectionView.frame.size.height/4)
        
        retrieveAlbums()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addAlbum(_ sender: Any) {
        
        let alert = UIAlertController(title: "Enter the name of the Album", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Type the name here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let album_name = alert.textFields?.first?.text {
                let baseURL = "http:0.0.0.0:5000/createAlbum"
                let parameters = ["user_id": self.user?.userID, "album_name": album_name]
                
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
                        self.retrieveAlbums()
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                    else {
                        let alert = UIAlertController(title: "Fail to add album", message: "Choose a new name for the album", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }.resume()
            }
        }))
        
        self.present(alert, animated: true)

    }
    
    
    func retrieveAlbums() {
        let baseURL = "http:0.0.0.0:5000/retrieveAlbums"
        let parameters = ["user_id": user?.userID]
        
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
            if let album_count = dictionary["album_count"] as? String {
                self.albums.albumCounts = Int(album_count) ?? 0
//                print(self.albums.albumCounts)
            }
            
            if let album_names = dictionary["album_names"] as? [String: Any] {
                self.albums.albums = Array(album_names.keys).sorted()
//                print(self.albums.albums)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print(self.albums.albumCounts)
        return self.albums.albumCounts
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
//        print(self.albums.albums[indexPath.item])
        let str = self.albums.albums[indexPath.item]
        if let user = self.user {
            let start = str.index(str.startIndex, offsetBy: user.userID.count)
            cell.albumLabel.text = String(str.suffix(from: start))
        }
        else {
            cell.albumLabel.text = self.albums.albums[indexPath.item]
        }
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }

}
