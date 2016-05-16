//
//  RegisterViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/10.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import SwiftValidator

class RegisterViewController: ImagePickerViewController, UITextFieldDelegate, ValidationDelegate {

    let validator = Validator()
    var uid: String?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var usernameValidationView: ValidationView!
    @IBOutlet weak var emailValidationView: ValidationView!
    @IBOutlet weak var passwordValidationView: ValidationView!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func selectProfilePicture(sender: AnyObject) {
        createImagePickerAlertController()
    }
    
    @IBAction func register(sender: AnyObject) {
        validator.validate(self)
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
        let username = usernameValidationView.inputTextField.text!
        let email = emailValidationView.inputTextField.text!
        let password = passwordValidationView.inputTextField.text!
        createUser(username, email: email, password: password, profilePicture: profilePictureButton.currentImage)
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
    
    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePictureButton.setImage(pickedImage, forState: .Normal)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
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
        let usernameRequiredRule = RequiredRule(message: Error.UsernameRequired)
        validator.registerField(usernameInputTextField, errorLabel: usernameErrorLabel, rules: [usernameRequiredRule])
        
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
        let passwordRule = MinLengthRule(length: 8, message: Error.PasswordRule)
        validator.registerField(passwordInputTextField, errorLabel: passwordErrorLabel, rules: [passwordRequiredRule, passwordRule])
    }
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: "createUserCompleted:", name: NotificationNames.CreateUserCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NotificationNames.CreateUserCompleted, object: nil)
    }
    
    // MARK: - REST calls and response handler methods.
    
    func createUser(username: String, email: String, password: String, profilePicture: UIImage?) {
        toggleRequestProgress(true)
        DataModel.createUser(username, email: email, password: password, profilePicture: profilePicture)
    }
    
    func createUserCompleted(notification: NSNotification) {
        toggleRequestProgress(false)
        if let userInfo = notification.userInfo {
            let message = userInfo[NotificationData.Message] as! String
            createAuthenticationAlertController(Title.Error, message: message)
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func toggleRequestProgress(inProgress: Bool) {
        inProgress ? activityIndicatorUtils.showProgressView(view) : activityIndicatorUtils.hideProgressView()
        usernameValidationView.enabled = !inProgress
        emailValidationView.enabled = !inProgress
        passwordValidationView.enabled = !inProgress
        registerButton.enabled = !inProgress
    }
}
