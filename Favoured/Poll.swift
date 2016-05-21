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
    
    init(snapshot: FIRDataSnapshot) {
        let creationDateNumber = snapshot.value!.objectForKey(FirebaseConstants.CreationDate) as! NSNumber
        let closedNumber = snapshot.value!.objectForKey(FirebaseConstants.Closed) as! NSNumber
        let photosUploadedNumber = snapshot.value!.objectForKey(FirebaseConstants.PhotosUploaded) as! NSNumber
        
        question = snapshot.value!.objectForKey(FirebaseConstants.Question) as! String
        userId = snapshot.value!.objectForKey(FirebaseConstants.UserId) as! String
        selectedOption = snapshot.value!.objectForKey(FirebaseConstants.SelectedOption) as? String
        creationDate = Double(creationDateNumber)
        closed = Bool(closedNumber)
        photosUploaded = Bool(photosUploadedNumber)
        let pollOptionsSnapshot = snapshot.childSnapshotForPath(FirebaseConstants.PollOptions)
        for index in 0..<pollOptionsSnapshot.childrenCount {
            let pollOption = PollOption(snapshot: pollOptionsSnapshot.childSnapshotForPath(String(index)))
            pollOptions += [pollOption]
        }
    }
    
    func getPollData() -> [String:AnyObject] {
        var pollOptionsData = [[String:AnyObject]]()
        for pollOption in pollOptions {
            pollOptionsData.append(pollOption.getPollOptionData())
        }
        
        var data = [String: AnyObject]()
        data[FirebaseConstants.Question] = question
        data[FirebaseConstants.UserId] = userId
        data[FirebaseConstants.CreationDate] = NSDate().timeIntervalSince1970
        data[FirebaseConstants.Closed] = closed
        data[FirebaseConstants.PhotosUploaded] = photosUploaded
        data[FirebaseConstants.PollOptions] = pollOptionsData
        
        return data
    }
}