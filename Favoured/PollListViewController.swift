//
//  PollListViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/05.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum PollsType: Int {
        case MyPolls = 0
        case AllPolls = 1
    }
    
    let VotePollSegue = "VotePollSegue"
    
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var polls = [Poll]()
    var pollsType = PollsType.MyPolls
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case PollsType.MyPolls.rawValue:
            DataModel.addMyPollsListObserver()
        default:
            DataModel.addAllPollsListObserver()
        }
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == VotePollSegue {
            let viewController = segue.destinationViewController as! VotePollPageViewController
            let poll = sender as! Poll
            viewController.poll = poll
        }
    }
    
    // MARK: - UITableViewDelegate and UITableViewDatasource methods.
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return polls.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let poll = polls[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(PollTableViewCell.Identifier, forIndexPath: indexPath) as! PollTableViewCell
        configureCell(cell, poll: poll, rowIndex: indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let poll = polls[indexPath.row]
        performSegueWithIdentifier(VotePollSegue, sender: poll)
    }
    
    func configureCell(cell: PollTableViewCell, poll: Poll, rowIndex: Int) {
        cell.pollLabel.text = poll.question
        
        let profilePicture = DataModel.getProfilePicture(poll.profilePictureId!, rowIndex: rowIndex)
        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: true, rowIndex: rowIndex)
        
        cell.profileImageView.image = profilePicture
        let pollImageViews = cell.getPollImageViews()
        for (index, pollImageView) in pollImageViews.enumerate() {
            let hasImage = index < pollPictures.count
            pollImageView.hidden = !hasImage
            if hasImage {
                pollImageView.image = pollPictures[index]
            }
        }
    }
    
    // MARK: - Initialisation methods.
    
    func addObservers() {
        DataModel.addMyPollsListObserver()
        DataModel.addConnectionStateObserver()
        defaultCenter.addObserver(self, selector: #selector(getPollsCompleted(_:)), name: NotificationNames.GetPollsCompleted, object: nil)
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    func removeObservers() {
        DataModel.removePollListObserver()
        DataModel.removeConnectionStateObserver()
        defaultCenter.removeObserver(self, name: NotificationNames.GetPollsCompleted, object: nil)
        defaultCenter.removeObserver(self, name: NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    // MARK: - REST response methods.
    
    func getPollsCompleted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        polls.removeAll()
        polls = userInfo[NotificationData.Polls] as! [Poll]
        tableView.reloadData()
    }
    
    func photoDownloadCompleted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
//        let photo = userInfo[NotificationData.Photo] as! Photo
        let rowIndex = userInfo[NotificationData.RowIndex] as! Int
        let indexPath = NSIndexPath(forRow: rowIndex, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    // MARK: - Convenience methods.
    
}
