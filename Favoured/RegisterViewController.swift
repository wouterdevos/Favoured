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
import AWSS3

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ValidationDelegate {

    var firebase = Firebase(url: FirebaseConstants.URL)
    var activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    var validator = Validator()
    var alertController: UIAlertController?
    var uid: String?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var usernameValidationView: ValidationView!
    @IBOutlet weak var emailValidationView: ValidationView!
    @IBOutlet weak var passwordValidationView: ValidationView!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBAction func selectProfilePicture(sender: AnyObject) {
        let isCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if isCamera {
            alertController = Utils.createImagePickerAlertController(Title.AddProfilePicture, cameraHandler: cameraHandler, photoLibraryHandler: photoLibraryHandler)
            presentViewController(alertController!, animated: true, completion: nil)
        } else {
            let imagePickerController = Utils.getImagePickerController(.PhotoLibrary, delegate: self)
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
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
    
    // MARK: - REST calls and response handler methods.
    
    func createUser(email: String, password: String) {
        requestStarted()
        firebase.createUser(email, password: password) { error, result in
            self.handleCreateUser(error, result: result)
        }
    }
    
    func handleCreateUser(error: NSError!, result: [NSObject:AnyObject]!) {
        dispatch_async(dispatch_get_main_queue(), {
            if error != nil {
                self.requestFinished()
                let message = self.getCreateUserError(error)
                self.createAuthenticationAlertController(Title.Error, message: message)
            } else {
                self.uid = result["uid"] as? String
                print("Successfully logged in with uid: \(self.uid!)")
                self.uploadProfilePicture()
            }
        })
    }
    
    func getCreateUserError(error: NSError) -> String {
        if let errorCode = FAuthenticationError(rawValue: error.code) {
            switch errorCode {
            case .EmailTaken:
                return Error.EmailTaken
            default:
                return Error.UnexpectedError
            }
        }
        
        return Error.UnexpectedError
    }
    
    func setUserDetails(username: String, profilePictureUrl: String?) {
        // Set the user details.
        let users = firebase.childByAppendingPath(FirebaseConstants.Users)
        var userDetails = [FirebaseConstants.Username: username]
        if let image = profilePictureUrl {
            userDetails[FirebaseConstants.ProfilePicture] = image
        }
        let user = [uid!: userDetails]
        users.setValue(user) { error, firebase in
            self.handleUserDetails(error, firebase: firebase)
        }
    }
    
    func handleUserDetails(error: NSError?, firebase: Firebase?) {
        dispatch_async(dispatch_get_main_queue(), {
            if error != nil {
                self.requestFinished()
                self.createAuthenticationAlertController(Title.Error, message: "")
            } else {
                print("User details uploaded successfull")
            }
        })
    }
    
    func uploadProfilePicture() {
        guard let profilePicture = profilePictureButton.currentImage else {
            let username = usernameValidationView.inputTextField.text!
            setUserDetails(username, profilePictureUrl: nil)
            return
        }
        
        let targetSize = CGSize(width: Image.ThumbnailWidth, height: Image.ThumbnailHeight)
        let thumbnail = Utils.resizeImage(profilePicture, targetSize: targetSize)
        let directoryURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("favoured", isDirectory: true)
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // ...
        }
        
        let fileName = uid! + Image.ProfilePictureJPEG
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        let imageData = UIImageJPEGRepresentation(thumbnail, 0.8)
        imageData!.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = AWSConstants.BucketProfilePictures
        
        upload(uploadRequest)
    }
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            self.requestFinished()
                            print("upload() cancelled or paused: [\(error)]")
                            break;
                            
                        default:
                            self.requestFinished()
                            print("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        self.requestFinished()
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    self.requestFinished()
                    print("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                self.requestFinished()
                print("upload() failed: [\(exception)]")
            }
            
            if task.result != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    print("upload() completed")
                    let username = self.usernameValidationView.inputTextField.text!
                    self.setUserDetails(username, profilePictureUrl: uploadRequest.key)
                })
            }
            return nil
        }
    }
    
    func requestStarted() {
        activityIndicatorUtils.showProgressView(view)
        enableViews(false)
    }
    
    func requestFinished() {
        activityIndicatorUtils.hideProgressView()
        enableViews(true)
    }
    
    // MARK: - Handler methods for alert controller.
    
    func cameraHandler(alertAction: UIAlertAction) {
        let imagePickerController = Utils.getImagePickerController(.Camera, delegate: self)
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func photoLibraryHandler(alertAction: UIAlertAction) {
        let imagePickerController = Utils.getImagePickerController(.PhotoLibrary, delegate: self)
        presentViewController(imagePickerController, animated: true, completion: nil)
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
