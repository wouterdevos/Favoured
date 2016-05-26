//
//  PollListTableViewDataSource.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/26.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit

class PollListTableViewDataSource: NSObject {

    let defaultCenter = NSNotificationCenter.defaultCenter()
    
    override init() {
        super.init()
        DataModel.addPollListObserver()
        defaultCenter.addObserver(self, selector: #selector(PollListTableViewDataSource.getPollsCompleted(_:)), name: NotificationNames.GetPollsCompleted, object: nil)
    }
    
    func getPollsCompleted(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            print(Error.UserInfoNoData)
            return
        }
        
//        polls.removeAll()
//        let polls = userInfo[NotificationData.Polls] as! [Poll]
//        tableView.reloadData()
    }
}

extension PollListTableViewDataSource: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
