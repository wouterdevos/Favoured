//
//  ValidationTextView.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/10.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

@IBDesignable
class ValidationView: UIView {

    let nibName = "ValidationView"
    var view: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBInspectable var title: String?
    @IBInspectable var placeholder: String? 
    
    var enabled: Bool {
        get {
            return inputTextField.enabled
        }
        set(enabled) {
            inputTextField.enabled = enabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        setup()
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        setup()
    }
    
    override func layoutSubviews() {
        titleLabel.text = title
        inputTextField.placeholder = placeholder
        inputTextField.autocorrectionType = .No
        errorLabel.hidden = true
    }
    
    func setup() {
        view = loadViewFromNib()
        // Use bounds not frame or it'll be offset
        view.frame = bounds
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }

    func initInputTextField(keyboardType: UIKeyboardType, returnKeyType: UIReturnKeyType, spellCheckingType: UITextSpellCheckingType, delegate: UITextFieldDelegate, secureTextEntry: Bool) {
        inputTextField.keyboardType = keyboardType
        inputTextField.returnKeyType = returnKeyType
        inputTextField.spellCheckingType = spellCheckingType
        inputTextField.delegate = delegate
        inputTextField.secureTextEntry = secureTextEntry
    }
}
