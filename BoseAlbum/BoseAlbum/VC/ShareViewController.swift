//
//  ShareViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/18/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    var urlString = ""
    
    @IBOutlet weak var urlTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextView.text = urlString
        // Do any additional setup after loading the view.
    }
    
}
