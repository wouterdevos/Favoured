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
    
    var firebase = Firebase(url: FirebaseConstants.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var validator = Validator()
    var alertController: UIAlertController?
    
    var emailResetPasswordTextField: UITextField?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var emailValidationView: ValidationView!
    @IBOutlet weak var passwordValidationView: ValidationView!
    
    @IBOutlet weak var registerBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBAction func login(sender: AnyObject) {
        validator.validate(self)
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        alertController = Utils.createAlertController(Title.ResetPassword, message: Message.EmailEnter, positiveButtonName: Button.Reset, negativeButtonName: Button.Cancel, positiveButtonAction: resetPasswordHandler, negativeButtonAction: nil, textFieldHandler: emailTextFieldConfiguration)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardOnTap()
        initValidationViews()
        initValidationRules()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        alertController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate methods.
    
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        switch textField {
        case emailValidationView.inputTextField:
            passwordValidationView.inputTextField.becomeFirstResponder()
            break
        case passwordValidationView.inputTextField:
            dismissKeyboard()
            validator.validate(self)
            break
        default:
            break
        }
        
        return true
    }
    
    // MARK: - ValidationDelegate methods.
    
    func validationSuccessful() {
        let email = emailValidationView.inputTextField.text!
        let password = passwordValidationView.inputTextField.text!
        authUser(email, password: password)
    }
    
    func validationFailed(errors: [UITextField : ValidationError]) {
        for (_, error) in errors {
//            field.layer.borderColor = UIColor.redColor().CGColor
//            field.layer.borderWidth = 1.0
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.hidden = false
        }
    }
    
    func handleValidation(textField: UITextField) {
        validator.validateField(textField) { error in
            if let validationError = error {
                validationError.errorLabel!.hidden = false
                validationError.errorLabel!.text = validationError.errorMessage
            }
        }
    }
    
    // MARK: - Initialisation methods.
    
    func initValidationViews() {
        emailValidationView.initInputTextField(.EmailAddress, returnKeyType: .Next, spellCheckingType: .No, delegate: self, secureTextEntry: false)
        passwordValidationView.initInputTextField(.Default, returnKeyType: .Done, spellCheckingType: .No, delegate: self, secureTextEntry: true)
    }
    
    func initValidationRules() {
        // Register the email text field and validation rules.
        let emailInputTextField = emailValidationView.inputTextField
        let emailErrorLabel = emailValidationView.errorLabel
        let emailRequiredRule = RequiredRule(message: Error.EmailRequired)
        let emailRule = EmailRule(message: Error.EmailInvalid)
        validator.registerField(emailInputTextField, errorLabel: emailErrorLabel, rules: [emailRequiredRule, emailRule])
        
        // Register the password text field and validation rules.
        let passwordInputTextField = passwordValidationView.inputTextField
        let passwordErrorLabel = passwordValidationView.errorLabel
        let passwordRequiredRule = RequiredRule(message: Error.PasswordRequired)
        validator.registerField(passwordInputTextField, errorLabel: passwordErrorLabel, rules: [passwordRequiredRule])
    }
    
    // MARK: - Reset password configuration and handler.
    
    func resetPasswordHandler(alertAction: UIAlertAction) {
        let email = emailResetPasswordTextField!.text!
        resetPasswordForUser(email)
    }
    
    func emailTextFieldConfiguration(textField: UITextField) {
        emailResetPasswordTextField = textField
        emailResetPasswordTextField!.placeholder = Placeholder.Email
    }
    
    // MARK: - REST calls and response handler methods.
    
    func authUser(email: String, password: String) {
        activityIndicatorUtils.showProgressView(view)
        enableViews(false)
        firebase.authUser(email, password: password) { error, authData in
            self.handleAuthUser(error, authData: authData)
        }
    }
    
    func resetPasswordForUser(email: String) {
        activityIndicatorUtils.showProgressView(view)
        enableViews(false)
        firebase.resetPasswordForUser(email) { error in
            self.handleResetPasswordForUser(error)
        }
    }
    
    func handleAuthUser(error: NSError!, authData: FAuthData!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorUtils.hideProgressView()
            self.enableViews(true)
            if error != nil {
                let message = self.getAuthUserError(error)
                self.createAuthenticationAlertController(Title.Error, message: message)
            } else {
                let uid = authData.uid
                print("Successfully logged in with uid: \(uid)")
            }
        })
    }
    
    func handleResetPasswordForUser(error: NSError!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorUtils.hideProgressView()
            self.enableViews(true)
            if error != nil {
                self.createAuthenticationAlertController(Title.Error, message: Error.ErrorResettingPassword)
            } else {
                self.createAuthenticationAlertController(Title.PasswordReset, message: Message.CheckEmailForPassword)
            }
        })
    }
    
    func getAuthUserError(error: NSError) -> String {
        if let errorCode = FAuthenticationError(rawValue: error.code) {
            switch errorCode {
            case .UserDoesNotExist:
                return Error.UserDoesNotExist
            case .InvalidEmail:
                return Error.EmailInvalidTryAgain
            case .InvalidPassword:
                return Error.PasswordIncorrectTryAgain
            default:
                return Error.UnexpectedError
            }
        }
        
        return Error.UnexpectedError
    }
    
    // MARK: - Convenience methods.
    
    func createAuthenticationAlertController(title: String, message: String) {
        alertController = Utils.createAlertController(title, message: message)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    func enableViews(enabled: Bool) {
        emailValidationView.enabled = enabled
        passwordValidationView.enabled = enabled
        registerBarButtonItem.enabled = enabled
        loginButton.enabled = enabled
        resetPasswordButton.enabled = enabled
    }
}

