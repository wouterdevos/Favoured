//
//  PollListViewController.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/05.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Interface builder outlets and actions.
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
        
    }
    
    @IBAction func addPoll(sender: AnyObject) {
        
    }
    
    // MARK: - Lifecycle methods.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - UITableViewDelegate and UITableViewDatasource methods.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
