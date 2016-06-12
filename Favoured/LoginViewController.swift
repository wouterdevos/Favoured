//
//  ViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import SwiftValidator

class LoginViewController: FavouredViewController, UITextFieldDelegate, ValidationDelegate {
    
    let validator = Validator()
    
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
        DataModel.authUser() { isCurrentUser in
            if isCurrentUser {
                self.toggleRequestProgress(true)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
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
        defaultCenter.addObserver(self, selector: #selector(authUserCompleted(_:)), name: NotificationNames.AuthUserCompleted, object: nil)
        defaultCenter.addObserver(self, selector: #selector(resetPasswordForUserCompleted(_:)), name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
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
        toggleRequestProgress(true)
        DataModel.signInWithEmail(email, password: password)
    }
    
    func resetPasswordForUser(email: String) {
        toggleRequestProgress(true)
        DataModel.sendPasswordResetWithEmail(email)
    }
    
    func authUserCompleted(notification: NSNotification) {
        toggleRequestProgress(false)
        if let userInfo = notification.userInfo {
            let message = userInfo[NotificationData.Message] as! String
            createAlertController(Title.Error, message: message)
        } else {
            clearValidationViews()
            let mainNavigationController = navigationController!.storyboard!.instantiateViewControllerWithIdentifier("MainNavigationController")
            navigationController!.presentViewController(mainNavigationController, animated: true, completion: nil)
        }
    }
    
    func resetPasswordForUserCompleted(notification: NSNotification) {
        toggleRequestProgress(false)
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        let title = userInfo[NotificationData.Title] as! String
        let message = userInfo[NotificationData.Message] as! String
        
        createAlertController(title, message: message)
    }
    
    // MARK: - Convenience methods.
    
    func toggleRequestProgress(inProgress: Bool) {
        inProgress ? activityIndicatorUtils.showProgressView(view) : activityIndicatorUtils.hideProgressView()
        emailValidationView.enabled = !inProgress
        passwordValidationView.enabled = !inProgress
        registerBarButtonItem.enabled = !inProgress
        loginButton.enabled = !inProgress
        resetPasswordButton.enabled = !inProgress
    }
    
    func clearValidationViews() {
        emailValidationView.inputTextField.text = ""
        passwordValidationView.inputTextField.text = ""
    }
}

