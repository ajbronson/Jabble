//
//  SignupViewController.swift
//  Jabble
//
//  Created by AJ Bronson on 6/9/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var lastTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!


    @IBAction func createUserButtonTapped(sender: AnyObject) {
        guard let email = emailTextField.text,
            let firstName = firstTextField.text,
            let lastName = lastTextField.text,
            let displayName = displayNameTextField.text,
            let password1 = passwordTextField.text,
            let password2 = passwordAgainTextField.text
            where email.characters.count > 0 && firstName.characters.count > 0 && lastName.characters.count > 0 && displayName.characters.count > 0 && password1.characters.count > 0 && password2.characters.count > 0  else { self.showAlertWith("Error", message: "Please complete all fields."); return }
        
        if password1.characters.count < 6 {
            self.showAlertWith("Error", message: "Password must contain at least 6 characters.")
        } else if password1 != password2 {
            showAlertWith("Error", message: "Passwords do not match.")
        } else {
            UserController.createUser(firstName, lastName: lastName, email: email, displayName: displayName, password: password1) { (user) in
                if let user = user {
                    LoginPersistenceController.saveUser(user)
                    self.performSegueWithIdentifier("userCreatedAccount", sender: self)
                }
            }
        }
    }
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        
    }
}
