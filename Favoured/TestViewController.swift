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
    var colors:[UIColor] = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.yellowColor()]
    var frame: CGRect = CGRectMake(0, 0, 0, 0)
    var pageControl : UIPageControl = UIPageControl(frame: CGRectMake(50, 300, 200, 50))
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var thumbnailsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        scrollView.delegate = self
//        self.view.addSubview(scrollView)
//        for index in 0..<4 {
//            
//            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
//            frame.size = self.scrollView.frame.size
//            self.scrollView.pagingEnabled = true
//            
//            let subView = UIView(frame: frame)
//            subView.backgroundColor = colors[index]
//            self.scrollView .addSubview(subView)
//        }
//        
//        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 4, self.scrollView.frame.size.height)
//        pageControl.addTarget(self, action: #selector(changePage(_:)), forControlEvents: UIControlEvents.ValueChanged)
        initPollPictureViews()
        initPollPictureThumbnailViews()
        
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
//        pageControl.currentPage = Int(pageNumber)
    }
    
    // MARK: - Initialisation methods.
    
    func initPollPictureViews() {
        let pollOptionsCount = CGFloat(poll.pollOptions.count)
        scrollView.delegate = self
        scrollView.frame.size.width = view.frame.width
        
        let scrollViewWidth = scrollView.frame.width
        let scrollViewHeight = scrollView.frame.height
        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: false, rowIndex: 0)
        for (index, pollPicture) in pollPictures.enumerate() {
            let frame = CGRectMake(scrollViewWidth * CGFloat(index), 0, scrollViewWidth, scrollViewHeight)
            let pollPictureView = PollPictureView(frame: frame)
            pollPictureView.setPollPicture(pollPicture)
            pollPictureViews.append(pollPictureView)
            scrollView.addSubview(pollPictureView)
        }
        scrollView.contentSize = CGSizeMake(view.frame.width * pollOptionsCount, scrollView.frame.height)
    }
    
    func initPollPictureThumbnailViews() {
        let pollPictures = DataModel.getPollPictures(poll, isThumbnail: true, rowIndex: nil)
        for (index, pollPicture) in pollPictures.enumerate() {
            
        }
        
        for (index, subview) in thumbnailsStackView.arrangedSubviews.enumerate() {
            if index == 0 {
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
                pollPictureView.setPollPicture(photo.image)
                break
            } else if pollOption.pollPictureThumbnailId == photo.id {
                
            }
        }
    }
}
