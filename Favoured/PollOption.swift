//
//  PollOption.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation
import Firebase

class PollOption {
    
    let DefaultVoteCount = 0
    
    var pollPicture: String
    var pollPictureThumbnail: String
    var voteCount: Int
    
    init(pollPicture: String, pollPictureThumbnail: String) {
        self.pollPicture = pollPicture
        self.pollPictureThumbnail = pollPictureThumbnail
        self.voteCount = DefaultVoteCount
    }
    
    init(snapshot: FIRDataSnapshot) {
        pollPicture = snapshot.value!.objectForKey(FirebaseConstants.PollPicture) as! String
        pollPictureThumbnail = snapshot.value!.objectForKey(FirebaseConstants.PollPictureThumbnail) as! String
        voteCount = snapshot.value!.objectForKey(FirebaseConstants.VoteCount) as! Int
    }
    
    func getPollOptionData() -> [String:AnyObject] {
        var data = [String: AnyObject]()
        data[FirebaseConstants.PollPicture] = pollPicture
        data[FirebaseConstants.PollPictureThumbnail] = pollPictureThumbnail
        data[FirebaseConstants.VoteCount] = voteCount
        
        return data
    }
}