//
//  PollOptionView.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/03.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

protocol PollPictureViewDelegate {
    func pollPictureSelected()
}

@IBDesignable
class PollPictureView: UIView {

    let nibName = "PollPictureView"
    var pollPictureSelected = false
    var view: UIView!
    var delegate: PollPictureViewDelegate?
    
    @IBOutlet weak var pollPictureImageView: UIImageView!
    @IBOutlet weak var activityindicator: UIActivityIndicatorView!
    
    @IBAction func pollPictureSelected(sender: UIButton) {
        pollPictureSelected = !pollPictureSelected
        sender.selected = pollPictureSelected
        if pollPictureSelected {
            delegate?.pollPictureSelected()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func layoutSubviews() {
        pollPictureImageView.hidden = true
        activityindicator.hidden = false
        activityindicator.startAnimating()
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
    
    func setImage(image: UIImage?) {
        pollPictureImageView.image = image
        pollPictureImageView.hidden = image == nil
        activityindicator.hidden = image != nil
        image == nil ? activityindicator.startAnimating() : activityindicator.stopAnimating()
    }
}
