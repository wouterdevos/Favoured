//
//  VotePollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/01.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VotePollViewController: FavouredViewController {

    static let Identifier = "VotePollViewController"
    
    var pageIndex: Int!
    var pollOption: PollOption!
    var voteSelected = false
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var pollPictureImageView: UIImageView!
    @IBOutlet weak var voteButton: UIButton!
    
    @IBAction func vote(sender: UIButton) {
        voteSelected = !voteSelected
        voteButton.selected = voteSelected
    }

    // MARK: - Lifecycle methods.

    override func viewDidLoad() {
        super.viewDidLoad()
        initPollPictureImageView()
        initVoteButton()
    }
    
    // MARK: - Initialisation methods.
    
    func initPollPictureImageView() {
//        pollPictureImageView.image = image
    }
    
    func initVoteButton() {
        voteButton.setImage(UIImage(named:"TickNormal"), forState: .Normal)
        voteButton.setImage(UIImage(named:"TickSelected"), forState: .Selected)
        voteButton.setImage(UIImage(named:"TickSelected"), forState: .Highlighted)
    }
    
    
}
