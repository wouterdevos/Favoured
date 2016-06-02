//
//  ThumbnailPageControl.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/01.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class ThumbnailPageControl: UIPageControl {

    var selectedImage: UIImage!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        selectedImage = UIImage(named: "ProfilePicture")!
    }
    
    func updatePageIndicator() {
        for index in 0..<subviews.count - 1 {
            let imageView = subviews[index] as! UIImageView
            imageView.image = selectedImage
            imageView.alpha = index == currentPage ? 1.0 : 0.5
        }
    }
}
