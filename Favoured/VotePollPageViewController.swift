//
//  PollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VotePollPageViewController: FavouredViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, VotePollViewControllerDelegate {
    
    static let Identifier = "VotePollPageViewController"
    
    var poll: Poll!
    var pollOptionIndex: Int?
    var pollPictureThumbnails:[UIImage?]!
    var pollPictures: [UIImage?]!
    var pageViewController: UIPageViewController!
    var votePollViewControllers = [UIViewController]()
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbnailsStackView: UIStackView!
    @IBOutlet weak var pageViewControllerView: UIView!
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = poll.question
        initPollPictureButtons()
        initPageViewController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: - UIPageViewControllerDataSource and UIPageViewControllerDelegate methods.
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let votePollViewController = viewController as! VotePollViewController
        let pageIndex = votePollViewController.pageIndex - 1
        
        return viewControllerAtIndex(pageIndex)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let votePollViewController = viewController as! VotePollViewController
        let pageIndex = votePollViewController.pageIndex + 1
        
        return viewControllerAtIndex(pageIndex)
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let votePollViewController = pageViewController.viewControllers?[0] as! VotePollViewController
            updatePollPictureButtons(votePollViewController.pageIndex)
        }
    }
    
    // MARK: - VotePollViewControllerDelegate methods.
    
    func voteSelected(pageIndex: Int) {
        DataModel.voteOnPoll(poll, pollOptionIndex: pageIndex)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Initialisation methods.
    
    func initPollPictureButtons() {
        pollPictureThumbnails = DataModel.getPollPictures(poll, isThumbnail: true, rowIndex: nil)
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerate() {
            // Check if there is an image for the current poll picture thumbnail
            let hasImage = index < pollPictureThumbnails.count
            if hasImage {
                let pollPictureThumbnail = pollPictureThumbnails[index]
                let image = pollPictureThumbnail != nil ? pollPictureThumbnail! : UIImage(named: "PollPicture")!
                updatePollPictureButton(subview, image: image, highlighted: index == 0)
            } else {
                subview.removeFromSuperview()
            }
        }
    }
    
    func initPageViewController() {
        pollPictures = DataModel.getPollPictures(poll, isThumbnail: false, rowIndex: 0)
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([viewControllerAtIndex(0)], direction: .Forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: pageViewControllerView.frame.width, height: pageViewControllerView.frame.height)
        
        addChildViewController(pageViewController)
        pageViewControllerView.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NotificationNames.PhotoDownloadCompleted, object: nil)
        defaultCenter.addObserver(self, selector: #selector(getPollOptionIndexCompleted(_:)), name: NotificationNames.GetPollOptionIndexCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NotificationNames.PhotoDownloadCompleted, object: nil)
        defaultCenter.removeObserver(self, name: NotificationNames.GetPollOptionIndexCompleted, object: nil)
    }
    
    // MARK: - REST calls and response methods.
    
    func photoDownloadCompleted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        let photo = userInfo[NotificationData.Photo] as! Photo
        let currentVotePollViewController = pageViewController.viewControllers![0] as! VotePollViewController
        let pollPictureIndex = getPollPictureIndex(photo)
        
        if photo.isThumbnail {
            pollPictureThumbnails[pollPictureIndex] = photo.image
            let pollPictureButton = thumbnailsStackView.arrangedSubviews[pollPictureIndex] as! UIButton
            pollPictureButton.setImage(photo.image, forState: .Normal)
        } else {
            pollPictures[pollPictureIndex] = photo.image
            let pageIndex = currentVotePollViewController.pageIndex
            if (pageIndex == pollPictureIndex) {
                currentVotePollViewController.pollPicture = photo.image
                currentVotePollViewController.updatePollPicture()
            }
        }
    }
    
    func getPollOptionIndexCompleted(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            pollOptionIndex = userInfo[NotificationData.PollOptionIndex] as! Int
        }
        
        
    }

    // MARK: - Update methods.
    
    func updatePollPictureButtons(pollOptionIndex: Int) {
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerate() {
            updatePollPictureButton(subview, image: nil, highlighted: index == pollOptionIndex)
        }
    }
    
    func updatePollPictureButton(subview: UIView, image: UIImage?, highlighted: Bool) {
        let pollPictureButton = subview as! UIButton
        pollPictureButton.highlighted = highlighted
        pollPictureButton.enabled = !highlighted
        if let image = image {
            pollPictureButton.setImage(image, forState: .Normal)
        }
    }
    
    func updatePollPictureButtonVotes() {
        let voteCountTotal = getVoteCountTotal()
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerate() {
            let pollOption = poll.pollOptions[index]
            let pollPictureButton = subview as! UIButton
            pollPictureButton.titleLabel?.text = getVotePercentage(pollOption.voteCount, voteCountTotal: voteCountTotal)
        }
    }
    
    func updateVotePollViewController() {
        let votePollViewController = pageViewController.viewControllers?[0] as! VotePollViewController
        
    }
    
    // MARK: - Convenience methods.
    
    func viewControllerAtIndex(index: Int) -> VotePollViewController {
        let pollOptions = poll.pollOptions
        
        var currentIndex = index
        if currentIndex < 0 {
            currentIndex = pollOptions.count - 1
        } else if currentIndex >= pollOptions.count {
            currentIndex = 0
        }
        
        let votePollViewController = storyboard?.instantiateViewControllerWithIdentifier(VotePollViewController.Identifier) as! VotePollViewController
        votePollViewController.pageIndex = currentIndex
        votePollViewController.pollPicture = pollPictures[currentIndex]
        votePollViewController.hasVoted = false
        votePollViewController.delegate = self
        
        return votePollViewController
    }
    
    func getPollPictureIndex(photo: Photo) -> Int {
        var pollPictureIndex = 0
        for (index, pollOption) in poll.pollOptions.enumerate() {
            let id = photo.isThumbnail ? pollOption.pollPictureThumbnailId : pollOption.pollPictureId
            if photo.id == id {
                pollPictureIndex = index
            }
        }
        
        return pollPictureIndex
    }
    
    func getVoteCountTotal() -> Int {
        var voteCountTotal = 0
        for pollOption in poll.pollOptions {
            voteCountTotal += pollOption.voteCount
        }
        
        return voteCountTotal
    }
    
    func getVotePercentage(voteCount: Int, voteCountTotal: Int) -> String {
        let voteCountFraction = voteCountTotal > 0 ? Float(voteCount) * 100 / Float(voteCountTotal) : 0.0
        return String(format: "%.0f", voteCountFraction)
    }
}
