//
//  PollListViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/05.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum PollsType {
        case MyPolls
        case OpenPolls
        case ClosedPolls
    }
    
    let defaultCenter = NSNotificationCenter.defaultCenter()
    var polls = [Poll]()
    var pollsType = PollsType.MyPolls
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
        
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
    
    // MARK: - UITableViewDelegate and UITableViewDatasource methods.
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return polls.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let poll = polls[indexPath.row]
        let CellIdentifier = "PollTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! PollTableViewCell
        configureCell(cell, poll: poll, rowIndex: indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func configureCell(cell: PollTableViewCell, poll: Poll, rowIndex: Int) {
        cell.pollLabel.text = poll.question
        
//        let profilePicture = DataModel.getProfilePicture(poll.profilePictureId!, rowIndex: rowIndex)
        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: true, rowIndex: rowIndex)
        
//        cell.profileImageView.image = profilePicture
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
        DataModel.addPollListObserver()
        defaultCenter.addObserver(self, selector: #selector(getPollsCompleted(_:)), name: NotificationNames.GetPollsCompleted, object: nil)
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    func removeObservers() {
        DataModel.removePollListObserver()
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
    }
    
    // MARK: - Convenience methods.
    
}
