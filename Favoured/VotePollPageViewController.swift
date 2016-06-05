//
//  PollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VotePollPageViewController: FavouredViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    static let Identifier = "VotePollPageViewController"
    
    var poll: Poll!
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
        initPageViewController()
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
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        let currentVotePollViewController = pageViewController.viewControllers?[0] as! VotePollViewController
        let pendingVotePollViewController = pendingViewControllers[0] as! VotePollViewController
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let votePollViewController = pageViewController.viewControllers?[0] as! VotePollViewController
        print("votePollViewController pageIndex \(votePollViewController.pageIndex)")
    }
    
    // MARK: - Initialisation methods.
    
    func initPageViewController() {
//        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
//        let navigationBarHeight = navigationController!.navigationBar.frame.size.height
//        let questionLabelTopMargin = CGFloat(8)
//        let questionLabelHeight = questionLabel.frame.size.height
//        
//        let heightOffset = statusBarHeight + navigationBarHeight + questionLabelTopMargin + questionLabelHeight
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
        defaultCenter.addObserver(self, selector: #selector(photoDownloadCompleted(_:)), name: NotificationNames.AuthUserCompleted, object: nil)
    }
    
    func removeObservers() {
        defaultCenter.removeObserver(self, name: NotificationNames.AuthUserCompleted, object: nil)
    }
    
    // MARK: - REST calls and response methods.
    
    func photoDownloadCompleted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
        let rowIndex = userInfo[NotificationData.RowIndex] as! Int
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
        votePollViewController.pollPicture = UIImage(named: "PollPicture")
        votePollViewController.hasVoted = false
        
        return votePollViewController
    }
}
