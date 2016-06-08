//
//  TestViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/03.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class TestViewController: FavouredViewController, UIScrollViewDelegate, PollPictureViewDelegate {
    
    var poll: Poll!
    var pollPictureViews = [PollPictureView]()
    var pollOptionIndex = 0
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbnailsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func scrollToPollPicture(sender: UIButton) {
        sender.highlighted = true
        let tag = sender.tag
        if tag == pollOptionIndex {
            return
        }
        
        let x = CGFloat(tag) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initPollPictureViews()
        initPollPictureButtons()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: - UIScrollViewDelegate methods.
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pollOptionIndex = Int(pageNumber)
        updatePollPictureButtons()
    }
    
    // MARK: - PollPictureViewDelegate methods.
    
    func pollPictureSelected() {
        DataModel.voteOnPoll(poll, pollOptionIndex: pollOptionIndex)
    }
    
    // MARK: - Initialisation methods.
    
    func initPollPictureViews() {
        scrollView.delegate = self
        scrollView.frame.size.width = view.frame.width
        
        let scrollViewWidth = scrollView.frame.width
        let scrollViewHeight = scrollView.frame.height
        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: false, rowIndex: 0)
        
        for (index, pollPicture) in pollPictures.enumerate() {
            let frame = CGRectMake(scrollViewWidth * CGFloat(index), 0, scrollViewWidth, scrollViewHeight)
            let pollPictureView = PollPictureView(frame: frame)
            pollPictureView.setImage(pollPicture)
            pollPictureViews.append(pollPictureView)
            scrollView.addSubview(pollPictureView)
        }
        
        let pollOptionsCount = CGFloat(pollPictures.count)
        scrollView.contentSize = CGSizeMake(scrollView.frame.width * pollOptionsCount, scrollView.frame.height)
    }
    
    func initPollPictureButtons() {
        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: true, rowIndex: nil)
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerate() {
            // Check if there is an image for the current poll picture thumbnail
            let hasImage = index < pollPictures.count
            if hasImage {
                let pollPicture = pollPictures[index]
                let image = pollPicture != nil ? pollPicture! : UIImage(named: "PollPicture")!
                updatePollPictureButton(subview, image: image, highlighted: index == 0)
            } else {
                subview.removeFromSuperview()
            }
        }
    }
    
    func addObservers() {
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NotificationNames.PhotoDownloadCompleted, object: nil)
    }
    
    // MARK: - REST response methods.
    
    func photoDownloadCompleted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        let photo = userInfo[NotificationData.Photo] as! Photo
        for (index, pollOption) in poll.pollOptions.enumerate() {
            if pollOption.pollPictureId == photo.id {
                let pollPictureView = pollPictureViews[index]
                pollPictureView.setImage(photo.image)
                break
            } else if pollOption.pollPictureThumbnailId == photo.id {
                
            }
        }
    }
    
    // MARK: - Convenience methods.
    
    func updatePollPictureButton(subview: UIView, image: UIImage?, highlighted: Bool) {
        let pollPictureThumbnailButton = subview as! UIButton
        pollPictureThumbnailButton.highlighted = highlighted
        pollPictureThumbnailButton.enabled = !highlighted
        if let image = image {
            pollPictureThumbnailButton.setImage(image, forState: .Normal)
        }
    }
    
    func updatePollPictureButtons() {
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerate() {
            updatePollPictureButton(subview, image: nil, highlighted: index == pollOptionIndex)
        }
    }
}
