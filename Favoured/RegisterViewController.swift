//
//  RegisterViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/10.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var firebase = Firebase(url: Constants.Firebase.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func register(sender: AnyObject) {
//        let isValidUsername = Utils.isValid(usernameTextField)
//        let isValidEmail = Utils.isValid(emailTextField)
//        let isValidPassword = Utils.isValid(passwordTextField)
//        let isValidConfirmPassword = Utils.isValid(confirmPasswordTextField)
    }
    
    func handleRegisterUser() {
        
    }
}
