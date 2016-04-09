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
    
    // Check if a given text field has a value enterred in it
    static func isValid(textField: UITextField) -> Bool {
        guard let text = textField.text where !text.isEmpty else {
            return false
        }
        
        return true
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
}