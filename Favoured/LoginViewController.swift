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
    
    let firebase = Firebase(url: FirebaseConstants.URL)
    let activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    let validator = Validator()
    let defaultCenter = NSNotificationCenter.defaultCenter()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
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
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: "authUserCompleted:", name: NotificationNames.AuthUserCompleted, object: nil)
        defaultCenter.addObserver(self, selector: "resetPasswordForUserCompleted:", name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NotificationNames.AuthUserCompleted, object: nil)
        defaultCenter.removeObserver(self, name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
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
    
    // MARK: - REST calls and response methods.
    
    func authUser(email: String, password: String) {
        activityIndicatorUtils.showProgressView(view)
        enableViews(false)
        DataModel.authUser(email, password: password)
    }
    
    func resetPasswordForUser(email: String) {
        activityIndicatorUtils.showProgressView(view)
        enableViews(false)
        DataModel.resetPasswordForUser(email)
    }
    
    func authUserCompleted(notification: NSNotification) {
        activityIndicatorUtils.hideProgressView()
        enableViews(true)
        
        if let userInfo = notification.userInfo {
            let message = userInfo[NotificationData.Message] as! String
            createAuthenticationAlertController(Title.Error, message: message)
            return
        }
        
        print("Successfully logged in")
    }
    
    func resetPasswordForUserCompleted(notification: NSNotification) {
        activityIndicatorUtils.hideProgressView()
        enableViews(true)
        
        let title = notification.userInfo![NotificationData.Title] as! String
        let message = notification.userInfo![NotificationData.Message] as! String
        
        createAuthenticationAlertController(title, message: message)
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

