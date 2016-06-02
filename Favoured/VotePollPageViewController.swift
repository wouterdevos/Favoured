//
//  PollViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class VotePollPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var poll: Poll!
    var votePollViewControllers = [UIViewController]()
    
    // MARK: - Interface builder outlets and actions.
    
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        initVotePollViewControllers()
    }
    
    // MARK: - UIPageViewControllerDataSource methods.
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = votePollViewControllers.indexOf(viewController) else {
            return nil
        }
        
        var previousIndex = viewControllerIndex - 1
        if previousIndex < 0 {
            previousIndex = votePollViewControllers.count - 1
        }
        
        return votePollViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = votePollViewControllers.indexOf(viewController) else {
            return nil
        }
        
        var nextIndex = viewControllerIndex + 1
        if nextIndex >= votePollViewControllers.count {
            nextIndex = 0
        }
        
        return votePollViewControllers[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return votePollViewControllers.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            firstViewControllerIndex = votePollViewControllers.indexOf(firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    
    // MARK: - Initialisation methods.
    
    func initVotePollViewControllers() {
        for _ in 0..<4 {
            votePollViewControllers.append(getVotePollViewController())
        }
        
        if let firstVotePollViewController = votePollViewControllers.first {
            setViewControllers([firstVotePollViewController], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    func getVotePollViewController() -> VotePollViewController {
        return storyboard?.instantiateViewControllerWithIdentifier(VotePollViewController.VotePollViewControllerName) as! VotePollViewController
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
    

    
    // MARK: - Handler methods for alert controller.
    

    
    // MARK: - Convenience methods.
    

}
