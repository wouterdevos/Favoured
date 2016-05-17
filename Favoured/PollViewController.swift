//
//  PollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    enum Button {
        case ButtonA
        case ButtonB
        case ButtonC
        case ButtonD
    }
    
    let activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var selectedButton: Button = Button.ButtonA
    var pollOptions = [String]()
    var alertController: UIAlertController?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var questionValidationView: ValidationView!
    @IBOutlet weak var addPollButton: UIButton!

    @IBAction func addPoll(sender: AnyObject) {
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - UIImagePickerControllerDelegate and UINavigationControllerDelegate methods.
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
//            profilePictureButton.setImage(pickedImage, forState: .Normal)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Initialisation methods.
    
    func addObservers() {
//        defaultCenter.addObserver(self, selector: "authUserCompleted:", name: NotificationNames.AuthUserCompleted, object: nil)
//        defaultCenter.addObserver(self, selector: "resetPasswordForUserCompleted:", name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    func removeObservers() {
//        defaultCenter.removeObserver(self, name: NotificationNames.AuthUserCompleted, object: nil)
//        defaultCenter.removeObserver(self, name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    // MARK: - REST calls and response methods.
    
    func addPoll() {
        
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
    
    func createImagePickerAlertController(selectedButton: Button) {
        self.selectedButton = selectedButton
        let isCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if isCamera {
            alertController = Utils.createImagePickerAlertController(Title.AddProfilePicture, cameraHandler: cameraHandler, photoLibraryHandler: photoLibraryHandler)
            presentViewController(alertController!, animated: true, completion: nil)
        } else {
            let imagePickerController = Utils.getImagePickerController(.PhotoLibrary, delegate: self)
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
}
