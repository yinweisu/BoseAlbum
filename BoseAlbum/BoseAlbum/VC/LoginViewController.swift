//
//  LoginViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/16/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var user: User?
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "segueFromLoginToHome"
        {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! HomeViewController
            targetController.user = self.user!
        }
    }

    @IBAction func loginPressed(_ sender: Any) {
        //            let baseURL = "http://bose-album-server.herokuapp.com/login"
        let baseURL = "http:0.0.0.0:5000/login"
        let parameters = ["email": emailField.text, "password": passwordField.text]
        
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    self.user = user
                    print(user)
                    OperationQueue.main.addOperation {
                        self.performSegue(withIdentifier: "segueFromLoginToHome", sender: self)
                    }
                } catch {
                    do {
                        let myError = try JSONDecoder().decode(MyError.self, from: data)
                        var errorMessage = ""
                        switch myError.error {
                        case "INVALID_EMAIL":
                            errorMessage = "Please enter a valid Email"
                        case "INVALID_PASSWORD":
                            errorMessage = "Your password is incorrect"
                        case "EMAIL_NOT_FOUND":
                            errorMessage = "Your email doesn't exist"
                        default:
                            errorMessage = "Unexpected error happened. Please try again"
                        }
                        OperationQueue.main.addOperation {
                            self.errorLabel.text = errorMessage
                            self.errorLabel.isHidden = false
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }.resume()
    }
}
