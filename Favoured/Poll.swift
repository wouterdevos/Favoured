//
//  Poll.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation
import Firebase

class Poll {
    
    var question: String
    var userId: String
    var selectedOption: String?
    var creationDate: Double
    var closed: Bool
    var photosUploaded: Bool
    var pollOptions = [PollOption]()
    
    init(question: String, userId: String) {
        self.question = question
        self.userId = userId
        creationDate = Utils.getTimeIntervalSince1970()
        closed = false
        photosUploaded = false
    }
    
    init(snapshot: FDataSnapshot) {
        question = snapshot.value[FirebaseConstants.Question] as! String
        userId = snapshot.value[FirebaseConstants.UserId] as! String
        selectedOption = snapshot.value[FirebaseConstants.SelectedOption] as? String
        creationDate = snapshot.value[FirebaseConstants.CreationDate] as! Double
        closed = snapshot.value[FirebaseConstants.Question] as! Bool
        photosUploaded = snapshot.value[FirebaseConstants.Question] as! Bool
        let pollOptionsSnapshot = snapshot.childSnapshotForPath(FirebaseConstants.PollOptions)
        for index in 0..<pollOptionsSnapshot.childrenCount {
            let pollOption = PollOption(snapshot: pollOptionsSnapshot.childSnapshotForPath(String(index)))
            pollOptions += [pollOption]
        }
    }
    
    func getPollData() -> [String:AnyObject] {
        var data = [String: AnyObject]()
        data[FirebaseConstants.Question] = question
        data[FirebaseConstants.UserId] = userId
        data[FirebaseConstants.Closed] = closed
        
        return data
    }
}