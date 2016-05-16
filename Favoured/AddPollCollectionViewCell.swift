//
//  AddPollCollectionViewCell.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/09.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class AddPollCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame.size.width = frame.width
        imageView.frame.size.height = frame.height
    }
}
