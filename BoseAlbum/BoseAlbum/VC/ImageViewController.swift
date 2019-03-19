//
//  ImageViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/18/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let selectedImage = self.selectedImage else {
            return
        }
        imageView.image = selectedImage
        // Do any additional setup after loading the view.
    }
    
}
