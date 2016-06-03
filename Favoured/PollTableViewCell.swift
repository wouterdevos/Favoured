//
//  ThumbnailView.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/23.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollTableViewCell: UITableViewCell {
    
    static let Identifier = "PollTableViewCell"
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var pollLabel: UILabel!
    @IBOutlet weak var pollImageView1: UIImageView!
    @IBOutlet weak var pollImageView2: UIImageView!
    @IBOutlet weak var pollImageView3: UIImageView!
    @IBOutlet weak var pollImageView4: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getPollImageViews() -> [UIImageView] {
        var pollImageViews = [UIImageView]()
        pollImageViews.append(pollImageView1)
        pollImageViews.append(pollImageView2)
        pollImageViews.append(pollImageView3)
        pollImageViews.append(pollImageView4)
        
        return pollImageViews
    }
}
