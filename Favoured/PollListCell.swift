//
//  ThumbnailView.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/23.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollListCell: UITableViewCell {
    
    let MaxThumbnails = 4
    let spacing = 8
    
    var voteValue: String? = nil
    var thumbnails = [UIImageView]()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var pollLabel: UILabel!
    @IBOutlet weak var thumbnailsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let thumbnailSize = Int(thumbnailsView.frame.size.height)
        var thumbnailFrame = CGRect(x: 0, y: 0, width: thumbnailSize, height: thumbnailSize)
        for (index, thumbnail) in thumbnails.enumerate() {
            thumbnailFrame.origin.x = CGFloat(index * (thumbnailSize + spacing))
            thumbnail.frame = thumbnailFrame
        }
    }
    
    func setup() {
        for index in 0 ..< MaxThumbnails {
            let thumbnail = UIImageView()
            thumbnail.backgroundColor = index % 2 == 0 ? UIColor.redColor() : UIColor.blueColor()
            thumbnails += [thumbnail]
            addSubview(thumbnail)
        }
    }
}
