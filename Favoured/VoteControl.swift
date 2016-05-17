//
//  VoteControl.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/11.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VoteControl: UIControl {

    enum VoteOption: Int {
        case OptionA = 0
        case OptionB = 1
        case OptionC = 2
        case OptionD = 3
    }
    
    let buttons = 4
    let spacing = 30
    
    var voteValue: String? = nil
    var voteButtons = [UIButton]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func intrinsicContentSize() -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize * buttons) + (spacing * (buttons - 1))
        return CGSize(width: width, height: buttonSize)
    }
    
    override func layoutSubviews() {
        let buttonSize = Int(frame.size.height)
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        for (index, button) in voteButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
//            button.layer.cornerRadius = 0.5 * button.bounds.size.width
        }
    }
    
    func setup() {
//        let controlWidth = frame.size.width
//        let controlHeight = frame.size.height
        let buttonNormal = UIImage(named: "VoteButtonNormal")
        let buttonSelected = UIImage(named: "VoteButtonSelected")
        
        for _ in 0 ..< buttons {
            let button = UIButton()
//            button.backgroundColor = UIColor.redColor()
            button.addTarget(self, action: #selector(VoteControl.voteButtonClicked(_:)), forControlEvents: .TouchDown)
            button.setBackgroundImage(buttonNormal, forState: .Normal)
            button.setBackgroundImage(buttonSelected, forState: .Highlighted)
            button.setTitle("A", forState: .Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            button.adjustsImageWhenHighlighted = false
            voteButtons += [button]
            addSubview(button)
        }
    }
    
    func voteButtonClicked(button: UIButton) {
        let voteButtonIndex = voteButtons.indexOf(button)!
        let voteOption = VoteOption(rawValue: voteButtonIndex)
    }
}
