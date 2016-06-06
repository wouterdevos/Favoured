//
//  TestViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/03.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class TestViewController: FavouredViewController, UIScrollViewDelegate {
    
    var poll: Poll!
    var pollPictureViews = [PollPictureView]()
    var currentPage = 0
    var pollPictures: [UIImage?]!
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbnailsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func scrollToPollPicture(sender: UIButton) {
        sender.highlighted = true
        let tag = sender.tag
        if tag == currentPage {
            return
        }
        
        let x = CGFloat(tag) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pollPictures = [UIImage(named: "Shoes")!, UIImage(named: "Shoes")!, UIImage(named: "Shoes")!]
        initPollPictureViews()
        initPollPictureButtons()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    // MARK: - UIScrollViewDelegate methods.
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        currentPage = Int(pageNumber)
        updatePollPictureButtons()
    }
    
    // MARK: - Initialisation methods.
    
    func initPollPictureViews() {
        let pollOptionsCount = CGFloat(pollPictures.count)//CGFloat(poll.pollOptions.count)
        scrollView.delegate = self
        scrollView.frame.size.width = view.frame.width
        print("view width \(view.frame.width)")
        print("scrollView width \(scrollView.frame.width)")
        print("scrollView minX \(scrollView.frame.minX)")
        
        let colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.brownColor()]
        let scrollViewWidth = scrollView.frame.width
        let scrollViewHeight = scrollView.frame.height
//        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: false, rowIndex: 0)
        for (index, pollPicture) in pollPictures.enumerate() {
            print("pollPictureView x \(scrollViewWidth * CGFloat(index))")
            let frame = CGRectMake(scrollViewWidth * CGFloat(index), 0, scrollViewWidth, scrollViewHeight)
            let pollPictureView = PollPictureView(frame: frame)
            pollPictureView.view.backgroundColor = colors[index]
            pollPictureView.setImage(pollPicture)
            pollPictureViews.append(pollPictureView)
            scrollView.addSubview(pollPictureView)
        }
        scrollView.contentSize = CGSizeMake(scrollView.frame.width * pollOptionsCount, scrollView.frame.height)
    }
    
    func initPollPictureButtons() {
//        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: true, rowIndex: nil)
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
    
    // To change while clicking on a page control
//    func changePage(sender: AnyObject) -> () {
//        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
//        scrollView.setContentOffset(CGPointMake(x, 0), animated: true)
//    }
    
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
            updatePollPictureButton(subview, image: nil, highlighted: index == currentPage)
        }
    }
}
