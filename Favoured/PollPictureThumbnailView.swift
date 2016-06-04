//
//  PollPictureThumbnailView.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/04.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollPictureThumbnailView: UIView {

    let nibName = "PollPictureThumbnailView"
    var view: UIView!
    
    @IBOutlet weak var pollPictureThumbnailImageView: UIImageView!
    @IBOutlet weak var pollPictureThumbnailLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        pollPictureThumbnailLabel.hidden = true
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
}
