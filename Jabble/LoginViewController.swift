//
//  LoginViewController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/9/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func submitButtonTapped(sender: AnyObject) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text
            where email.characters.count > 0 && password.characters.count > 0 else { showInvalidLogin(); return }
        
        UserController.authUser(email, password: password) { (user) in
            if user == nil {
                self.showInvalidLogin()
            } else if let user = user {
                LoginPersistenceController.saveUser(user)
                self.performSegueWithIdentifier("userLoggedIn", sender: self)
            }
        }
    }
    
    func showInvalidLogin() {
        let alert = UIAlertController(title: "Error", message: "Invalid Login Credentials. \nTry Again.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
