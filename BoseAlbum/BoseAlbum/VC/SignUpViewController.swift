//
//  SignUpViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/16/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.errorLabel.text = ""
        self.errorLabel.isHidden = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        if passwordField.text == confirmPasswordField.text {
            self.errorLabel.text = ""
            self.errorLabel.isHidden = true
        }
        else {
            self.errorLabel.text = "Password doesn't match"
            self.errorLabel.isHidden = false
        }
    }
    
    
}
