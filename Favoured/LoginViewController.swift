//
//  ViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var emailResetPasswordTextField: UITextField?
    
    var firebase = Firebase(url: Constants.Firebase.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        alertController?.dismissViewControllerAnimated(false, completion: nil)
    }

    @IBAction func login(sender: AnyObject) {
        let isValidEmail = Utils.isValid(emailTextField)
        let isValidPassword = Utils.isValid(passwordTextField)
        var message : String?
        
        if !(isValidEmail || isValidPassword) {
            message = Constants.Message.EnterEmailAndPassword
        } else if !isValidEmail {
            message = Constants.Message.EnterEmail
        } else if !isValidPassword {
            message = Constants.Message.EnterPassword
        }
        
        guard message == nil else {
            createAuthenticationAlertController(message!)
            return
        }
        
        activityIndicatorUtils.showProgressView(view)
        firebase.authUser(emailTextField.text!, password: passwordTextField.text!) { error, authData in
            self.handleAuthUser(error, authData: authData)
        }
    }

    @IBAction func register(sender: AnyObject) {
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        alertController = Utils.createAlertController(Constants.Title.ResetPassword, message: Constants.Message.EnterEmail, positiveButtonName: Constants.Button.Reset, negativeButtonName: Constants.Button.Cancel, positiveButtonAction: forgotPasswordHandler, negativeButtonAction: nil, textFieldHandler: emailTextFieldConfiguration)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    func forgotPasswordHandler(alertAction: UIAlertAction) {
        activityIndicatorUtils.showProgressView(view)
        firebase.resetPasswordForUser(emailResetPasswordTextField?.text) { error in
            self.handleResetPasswordForUser(error)
        }
    }
    
    func emailTextFieldConfiguration(textField: UITextField) {
        emailResetPasswordTextField = textField
        emailResetPasswordTextField!.placeholder = Constants.Placeholder.Email
    }
    
    func handleAuthUser(error: NSError!, authData: FAuthData!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorUtils.hideProgressView()
            if error != nil {
                self.createAuthenticationAlertController(error.localizedDescription)
            } else {
                let uid = authData.uid
                print("Successfully logged in with uid: \(uid)")
            }
        })
    }
    
    func handleResetPasswordForUser(error: NSError!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorUtils.hideProgressView()
            if error != nil {
                self.createAuthenticationAlertController(Constants.Message.ErrorResettingPassword)
            } else {
                self.createAuthenticationAlertController(Constants.Message.CheckEmailForPassword)
            }
        })
    }
    
    func createAuthenticationAlertController(message: String) {
        alertController = Utils.createAlertController(nil, message: message)
        presentViewController(alertController!, animated: true, completion: nil)
    }
}

