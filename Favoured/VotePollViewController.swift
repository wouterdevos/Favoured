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
    var voteSelected = false
    var isError = false
    var voteState = VoteState.Disabled
    var delegate: VotePollViewControllerDelegate?
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var pollPictureImageView: UIImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var imageUnavailableLabel: UILabel!
    @IBAction func vote(sender: UIButton) {
        voteSelected = !voteSelected
        voteButton.selected = voteSelected
        delegate?.voteSelected(pageIndex)
    }

    // MARK: - Lifecycle methods.

    override func viewDidLoad() {
        super.viewDidLoad()
        initVoteButton()
        updatePollPicture()
    }
    
    // MARK: - Initialisation methods.
    
    func initVoteButton() {
        voteButton.setImage(UIImage(named: "TickNormal"), forState: .Normal)
        voteButton.setImage(UIImage(named: "TickSelected"), forState: .Selected)
        voteButton.setImage(UIImage(named: "TickSelected"), forState: .Highlighted)
        updateVoteButton()
    }
    
    // MARK: - Update methods.
    
    func updatePollPicture() {
        let loading = pollPicture == nil && !isError
        loading ? imageActivityIndicator.startAnimating() : imageActivityIndicator.stopAnimating()
        imageActivityIndicator.hidden = !loading
        imageUnavailableLabel.hidden = !isError
        pollPictureImageView.image = pollPicture
    }
    
    func updateVoteButton() {
        switch voteState {
        case VoteState.Disabled:
            updateVoteButton(false, enabled: false, hidden: true)
        case VoteState.Pending:
            updateVoteButton(false, enabled: true, hidden: false)
        case VoteState.Cast(let pollOptionIndex):
            updateVoteButton(pageIndex == pollOptionIndex, enabled: false, hidden: false)
        }
    }
    
    func updateVoteButton(selected: Bool, enabled: Bool, hidden: Bool) {
        voteSelected = selected
        let normalImageNamed = voteSelected ? "TickSelected" : "TickNormal"
        voteButton.setImage(UIImage(named: normalImageNamed), forState: .Normal)
        voteButton.selected = voteSelected
        voteButton.enabled = enabled
        voteButton.hidden = hidden
    }
}
