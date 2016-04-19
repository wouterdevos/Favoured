//
//  Utils.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/07.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    // Define UIColor from hex value
    static func uiColorFromHex(rgbValue: UInt32, alpha: Double = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 256.0
        let blue = CGFloat(rgbValue & 0xFF) / 256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Create an alert controller to display to the screen
    static func createAlertController(title: String?, message: String?) -> UIAlertController {
        
        let positiveButtonName = Constants.Button.Ok
        return createAlertController(title, message: message, positiveButtonName: positiveButtonName, negativeButtonName: nil, positiveButtonAction: nil, negativeButtonAction: nil, textFieldHandler: nil)
    }
    
    // Create an alert controller to display to the screen
    static func createAlertController(title: String?, message: String?, positiveButtonName: String?, positiveButtonAction: ((UIAlertAction) -> Void)?) -> UIAlertController {
        
        return createAlertController(title, message: message, positiveButtonName: positiveButtonName, negativeButtonName: nil, positiveButtonAction: positiveButtonAction, negativeButtonAction: nil, textFieldHandler: nil)
    }
    
    // Create an alert controller to display to the screen
    static func createAlertController(title: String?, message: String?, positiveButtonName: String?, negativeButtonName: String?, positiveButtonAction: ((UIAlertAction) -> Void)?, negativeButtonAction: ((UIAlertAction) -> Void)?, textFieldHandler: ((UITextField) -> Void)?) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        if positiveButtonName != nil {
            let positiveAction = UIAlertAction(title: positiveButtonName, style: .Default, handler: positiveButtonAction)
            alertController.addAction(positiveAction)
        }
        
        if negativeButtonName != nil {
            let negativeAction = UIAlertAction(title: negativeButtonName, style: .Cancel, handler: negativeButtonAction)
            alertController.addAction(negativeAction)
        }
        
        if textFieldHandler != nil {
            alertController.addTextFieldWithConfigurationHandler(textFieldHandler)
        }
        
        return alertController
    }
    
    // Create an image picker alert controller to display to the screen
    static func createImagePickerAlertController(title: String, viewController: UIViewController, delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        
        let isCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        if isCamera {
            let cameraAction = UIAlertAction(title: Constants.Button.Camera, style: .Default) { alertAction in
                let imagePickerController = getImagePickerController(.Camera, delegate: delegate)
                viewController.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: Constants.Button.PhotoLibrary, style: .Default) { alertAction in
            let imagePickerController = getImagePickerController(.PhotoLibrary, delegate: delegate)
            viewController.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: Constants.Button.Cancel, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    // Get an image picker controller with the provided source type.
    static func getImagePickerController(sourceType : UIImagePickerControllerSourceType, delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> UIImagePickerController {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = delegate
        return imagePickerController
    }
}