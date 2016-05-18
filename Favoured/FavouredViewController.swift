//
//  FavouredViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/16.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class FavouredViewController: UIViewController {

    let activityIndicatorUtils = ActivityIndicatorUtils.sharedInstance()
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var alertController: UIAlertController?
    
    // MARK: - Lifecycle methods.
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        alertController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - Convenience methods.
    
    func createAlertController(title: String, message: String) {
        alertController = Utils.createAlertController(title, message: message)
        presentViewController(alertController!, animated: true, completion: nil)
    }
}
