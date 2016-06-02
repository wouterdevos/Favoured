//
//  VotePollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/01.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VotePollViewController: FavouredViewController {

    static let VotePollViewControllerName = "VotePollViewController"
    
    var image: UIImage!
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
    }
    
    // MARK: - Initialisation methods.
    
    func initPollPictureImageView() {
//        pollPictureImageView.image = image
    }
}
