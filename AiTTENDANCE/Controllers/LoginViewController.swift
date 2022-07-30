//
//  LoginViewController.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 29/05/2022.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    self.handle(e)
                }else{
                    self.performSegue(withIdentifier: K.loginSegue , sender: self)
                }
            }
        }
    }
    
    func handle(_ error: Error) {
        let alert = UIAlertController(
            title: K.authError,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "Ok",
            style: .default
        ))
        present(alert, animated: true)
    }
}
