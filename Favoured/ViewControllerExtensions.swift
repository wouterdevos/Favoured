//
//  ViewControllerExtensions.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/16.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func dismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}