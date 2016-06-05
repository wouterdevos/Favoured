//
//  VotePollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/01.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

protocol VotePollViewControllerDelegate {
    func voteSelected(pageIndex: Int)
}

class VotePollViewController: FavouredViewController {

    static let Identifier = "VotePollViewController"
    
    var pageIndex: Int!
    var pollPicture: UIImage?
    var hasVoted: Bool!
    var voteSelected = false
    var delegate: VotePollViewControllerDelegate?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var pollPictureImageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var voteButton: UIButton!
    
    @IBAction func vote(sender: UIButton) {
        voteSelected = !voteSelected
        voteButton.selected = voteSelected
        delegate?.voteSelected(pageIndex)
    }

    // MARK: - Lifecycle methods.

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePollPicture()
        initVoteButton()
    }
    
    // MARK: - Initialisation methods.
    
    func initVoteButton() {
        voteButton.setImage(UIImage(named:"TickNormal"), forState: .Normal)
        voteButton.setImage(UIImage(named:"TickSelected"), forState: .Selected)
        voteButton.setImage(UIImage(named:"TickSelected"), forState: .Highlighted)
        voteButton.selected = voteSelected
        voteButton.enabled = !hasVoted
    }
    
    // MARK: - Convenience methods.
    
    func updatePollPicture() {
        pollPicture == nil ? imageActivityIndicator.startAnimating() : imageActivityIndicator.stopAnimating()
        pollPictureImageView.image = pollPicture
    }
}
