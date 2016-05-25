//
//  ThumbnailView.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/23.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var pollLabel: UILabel!
    @IBOutlet weak var pollOption1: UIImageView!
    @IBOutlet weak var pollOption2: UIImageView!
    @IBOutlet weak var pollOption3: UIImageView!
    @IBOutlet weak var pollOption4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
