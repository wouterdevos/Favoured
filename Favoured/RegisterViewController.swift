//
//  RegisterViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/10.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator

class RegisterViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {

    var firebase = Firebase(url: Constants.Firebase.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var validator = Validator()
    var alertController: UIAlertController?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var usernameValidationView: ValidationView!
    @IBOutlet weak var emailValidationView: ValidationView!
    @IBOutlet weak var passwordValidationView: ValidationView!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func register(sender: AnyObject) {
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
        case usernameValidationView.inputTextField:
            usernameValidationView.errorLabel.hidden = true
            handleValidation(usernameValidationView.inputTextField)
            break
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
        case usernameValidationView.inputTextField:
            emailValidationView.inputTextField.becomeFirstResponder()
            break
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
        createUser(email, password: password)
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
        usernameValidationView.initInputTextField(.Default, returnKeyType: .Next, spellCheckingType: .No, delegate: self, secureTextEntry: false)
        emailValidationView.initInputTextField(.EmailAddress, returnKeyType: .Next, spellCheckingType: .No, delegate: self, secureTextEntry: false)
        passwordValidationView.initInputTextField(.Default, returnKeyType: .Done, spellCheckingType: .No, delegate: self, secureTextEntry: true)
    }
    
    func initValidationRules() {
        // Register the username text field and validation rules.
        let usernameInputTextField = usernameValidationView.inputTextField
        let usernameErrorLabel = usernameValidationView.errorLabel
        let usernameRequiredRule = RequiredRule(message: Constants.Error.UsernameRequired)
        validator.registerField(usernameInputTextField, errorLabel: usernameErrorLabel, rules: [usernameRequiredRule])
        
        // Register the email text field and validation rules.
        let emailInputTextField = emailValidationView.inputTextField
        let emailErrorLabel = emailValidationView.errorLabel
        let emailRequiredRule = RequiredRule(message: Constants.Error.EmailRequired)
        let emailRule = EmailRule(message: Constants.Error.EmailInvalid)
        validator.registerField(emailInputTextField, errorLabel: emailErrorLabel, rules: [emailRequiredRule, emailRule])
        
        // Register the password text field and validation rules.
        let passwordInputTextField = passwordValidationView.inputTextField
        let passwordErrorLabel = passwordValidationView.errorLabel
        let passwordRequiredRule = RequiredRule(message: Constants.Error.PasswordRequired)
        let passwordRule = MinLengthRule(length: 8, message: Constants.Error.PasswordRule)
        validator.registerField(passwordInputTextField, errorLabel: passwordErrorLabel, rules: [passwordRequiredRule, passwordRule])
    }
    
    // MARK: - REST calls and response handler methods.
    
    func createUser(email: String, password: String) {
        activityIndicatorUtils.showProgressView(view)
        enableViews(false)
        firebase.createUser(email, password: password) { error, result in
            self.handleCreateUser(error, result: result)
        }
    }
    
    func handleCreateUser(error: NSError!, result: [NSObject:AnyObject]!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorUtils.hideProgressView()
            self.enableViews(true)
            if error != nil {
                let message = self.getCreateUserError(error)
                self.createAuthenticationAlertController(Constants.Title.Error, message: message)
            } else {
                let uid = result["uid"] as? String
                print("Successfully logged in with uid: \(uid)")
            }
        })
    }
    
    func getCreateUserError(error: NSError) -> String {
        if let errorCode = FAuthenticationError(rawValue: error.code) {
            switch errorCode {
            case .EmailTaken:
                return Constants.Error.EmailTaken
            default:
                return Constants.Error.UnexpectedError
            }
        }
        
        return Constants.Error.UnexpectedError
    }
    
    // MARK: - Convenience methods.
    
    func createAuthenticationAlertController(title: String, message: String) {
        alertController = Utils.createAlertController(title, message: message)
        presentViewController(alertController!, animated: true, completion: nil)
    }
    
    func enableViews(enabled: Bool) {
        usernameValidationView.enabled = enabled
        emailValidationView.enabled = enabled
        passwordValidationView.enabled = enabled
        registerButton.enabled = enabled
    }
}
