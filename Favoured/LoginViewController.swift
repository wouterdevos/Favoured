//
//  ViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator

class LoginViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {

    
    @IBOutlet weak var emailValidationView: ValidationView!
    @IBOutlet weak var passwordValidationView: ValidationView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var emailResetPasswordTextField: UITextField?
    
    var firebase = Firebase(url: Constants.Firebase.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var alertController: UIAlertController?
    
    var isValid = true
    var validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initValidationViews()
        initValidationRules()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        alertController?.dismissViewControllerAnimated(false, completion: nil)
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        isValid = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        switch textField {
        case emailValidationView.inputTextField:
            emailValidationView.errorLabel.hidden = true
            handleValidation(emailValidationView.inputTextField)
            break
        case passwordValidationView.inputTextField:
            passwordValidationView.errorLabel.hidden = true
            handleValidation(passwordValidationView.inputTextField)
            break;
        default:
            break
        }
    }
    
    func validationSuccessful() {
        
    }
    
    func validationFailed(errors: [UITextField : ValidationError]) {
        
    }
    
    func handleValidation(textField: UITextField) {
        validator.validateField(textField) { error in
            if let validationError = error {
                self.isValid = false
                validationError.errorLabel!.hidden = false
                validationError.errorLabel!.text = validationError.errorMessage
            }
        }
    }
    
    func initValidationViews() {
        let emailInputTextField = emailValidationView.inputTextField
        let emailErrorLabel = emailValidationView.errorLabel
        emailInputTextField.delegate = self
        emailInputTextField.keyboardType = UIKeyboardType.EmailAddress
        emailInputTextField.returnKeyType = UIReturnKeyType.Next
        emailErrorLabel.hidden = true
        
        let passwordInputTextField = passwordValidationView.inputTextField
        let passwordErrorLabel = passwordValidationView.errorLabel
        passwordInputTextField.delegate = self
        passwordInputTextField.secureTextEntry = true
        passwordInputTextField.keyboardType = UIKeyboardType.Default
        passwordInputTextField.returnKeyType = UIReturnKeyType.Done
        passwordErrorLabel.hidden = true
    }
    
    func initValidationRules() {
        // Register the email text field and validation rules.
        let emailInputTextField = emailValidationView.inputTextField
        let emailErrorLabel = emailValidationView.errorLabel
        let emailRequiredRule = RequiredRule(message: Constants.Error.EmailRequired)
        let emailRule = EmailRule(message: Constants.Error.EmailInvalid)
        validator.registerField(emailInputTextField, errorLabel: emailErrorLabel, rules: [emailRequiredRule, emailRule])
        
        // Register the password text field and validation rules
        let passwordInputTextField = passwordValidationView.inputTextField
        let passwordErrorLabel = passwordValidationView.errorLabel
        let passwordRequiredRule = RequiredRule(message: Constants.Error.PasswordRequired)
        validator.registerField(passwordInputTextField, errorLabel: passwordErrorLabel, rules: [passwordRequiredRule])
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

