//
//  VoteControl.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/11.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VoteControl: UIView {

    let MaxButtons = 4
    
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
        return CGSize(width: 240, height: 44)
    }
    
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
        for (index, button) in voteButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (44 + 5))
            button.frame = buttonFrame
        }
    }
    
    func setup() {
        let controlWidth = frame.size.width
        let controlHeight = frame.size.height
        
        for _ in 0 ..< MaxButtons {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            button.addTarget(self, action: "voteButtonClicked:", forControlEvents: .TouchDown)
            button.backgroundColor = UIColor.redColor()
            button.titleLabel?.text = "A"
            voteButtons += [button]
            addSubview(button)
        }
        
    }
    
    
    
    func voteButtonClicked(sender: UIButton) {
        print("vote button clicked")
    }
}
