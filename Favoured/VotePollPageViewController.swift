//
//  PollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VotePollPageViewController: FavouredViewController, UIPageViewControllerDataSource {
    
    static let Identifier = "VotePollPageViewController"
    
    var poll: Poll!
    var pageViewController: UIPageViewController!
    var votePollViewControllers = [UIViewController]()
    
    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var questionLabel: UILabel!
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        poll = Poll(question: "", userId: "")
//        poll.pollOptions.append(PollOption(pollPictureId: "", pollPictureThumbnailId: ""))
//        poll.pollOptions.append(PollOption(pollPictureId: "", pollPictureThumbnailId: ""))
//        poll.pollOptions.append(PollOption(pollPictureId: "", pollPictureThumbnailId: ""))
//        poll.pollOptions.append(PollOption(pollPictureId: "", pollPictureThumbnailId: ""))
        questionLabel.text = poll.question
        initPageViewController()
    }
    
    // MARK: - UIPageViewControllerDataSource methods.
    
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
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return poll.pollOptions.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - Initialisation methods.
    
    func initPageViewController() {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navigationBarHeight = navigationController!.navigationBar.frame.size.height
        let questionLabelTopMargin = CGFloat(8)
        let questionLabelHeight = CGFloat(40)
        
        let heightOffset = statusBarHeight + navigationBarHeight + questionLabelTopMargin + questionLabelHeight
        let firstVotePollViewController = viewControllerAtIndex(0)
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.setViewControllers([firstVotePollViewController], direction: .Forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: heightOffset, width: view.frame.width, height: view.frame.height - heightOffset)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    func addObservers() {
//        defaultCenter.addObserver(self, selector: "authUserCompleted:", name: NotificationNames.AuthUserCompleted, object: nil)
//        defaultCenter.addObserver(self, selector: "resetPasswordForUserCompleted:", name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    func removeObservers() {
//        defaultCenter.removeObserver(self, name: NotificationNames.AuthUserCompleted, object: nil)
//        defaultCenter.removeObserver(self, name: NotificationNames.ResetPasswordForUserCompleted, object: nil)
    }
    
    // MARK: - REST calls and response methods.
    
    
    
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
        votePollViewController.pollOption = pollOptions[currentIndex]
        
        return votePollViewController
    }
}
