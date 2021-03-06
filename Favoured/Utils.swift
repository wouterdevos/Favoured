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
        
        let positiveButtonName = Button.Ok
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
    static func createImagePickerAlertController(title: String, cameraHandler: ((UIAlertAction) -> Void), photoLibraryHandler: ((UIAlertAction) -> Void)) -> UIAlertController {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
        
        let cameraAction = UIAlertAction(title: Button.Camera, style: .Default, handler: cameraHandler)
        alertController.addAction(cameraAction)
        
        let photoLibraryAction = UIAlertAction(title: Button.PhotoLibrary, style: .Default, handler: photoLibraryHandler)
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: Button.Cancel, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    // Get an image picker controller with the provided source type.
    static func getImagePickerController(sourceType : UIImagePickerControllerSourceType, delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> UIImagePickerController {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = delegate
        return imagePickerController
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else if widthRatio < heightRatio {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        } else {
            newSize = CGSizeMake(targetSize.width, targetSize.height)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func getTimeIntervalSince1970() -> Double {
        let date = NSDate()
        return date.timeIntervalSince1970
    }
    
    static func formatDate(timeIntervalSince1970: Double) -> String {
        let date = NSDate(timeIntervalSince1970: timeIntervalSince1970)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
}