//
//  ViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import Firebase
import Validator

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var emailValidationView: ValidationView!
    @IBOutlet weak var passwordValidationView: ValidationView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var emailResetPasswordTextField: UITextField?
    
    var firebase = Firebase(url: Constants.Firebase.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var alertController: UIAlertController?
    
    var isValid = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailValidationView.inputTextField.delegate = self
        passwordValidationView.inputTextField.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        alertController?.dismissViewControllerAnimated(false, completion: nil)
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if emailValidationView.inputTextField == textField {

        } else if passwordValidationView.inputTextField == textField {
            
        }
    }
    
    @IBAction func login(sender: AnyObject) {

        let email = emailValidationView.inputTextField.text!
        let password = passwordValidationView.inputTextField.text!
        activityIndicatorUtils.showProgressView(view)
        firebase.authUser(email, password: password) { error, authData in
            self.handleAuthUser(error, authData: authData)
        }
    }

    @IBAction func register(sender: AnyObject) {
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        alertController = Utils.createAlertController(Constants.Title.ResetPassword, message: Constants.Message.EmailEnter, positiveButtonName: Constants.Button.Reset, negativeButtonName: Constants.Button.Cancel, positiveButtonAction: forgotPasswordHandler, negativeButtonAction: nil, textFieldHandler: emailTextFieldConfiguration)
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
                self.createAuthenticationAlertController(Constants.Error.ErrorResettingPassword)
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

