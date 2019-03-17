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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveAlbums()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addAlbum(_ sender: Any) {
        
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
            if let data = data {
                
                }
            }.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }

}
