//
//  PollOption.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Firebase

class PollOption {
    
    let DefaultVoteCount = 0
    
    var pollPictureId: String
    var pollPictureThumbnailId: String
    var voteCount: Int
    
    init(pollPictureId: String, pollPictureThumbnailId: String) {
        self.pollPictureId = pollPictureId
        self.pollPictureThumbnailId = pollPictureThumbnailId
        self.voteCount = DefaultVoteCount
    }
    
    init(snapshot: FIRDataSnapshot) {
        let voteCountNumber = snapshot.value!.objectForKey(FirebaseConstants.VoteCount) as! NSNumber
        
        pollPictureId = snapshot.value!.objectForKey(FirebaseConstants.PollPictureId) as! String
        pollPictureThumbnailId = snapshot.value!.objectForKey(FirebaseConstants.PollPictureThumbnailId) as! String
        voteCount = Int(voteCountNumber)
    }
    
    func getPollOptionData() -> [String:AnyObject] {
        var data = [String: AnyObject]()
        data[FirebaseConstants.PollPictureId] = pollPictureId
        data[FirebaseConstants.PollPictureThumbnailId] = pollPictureThumbnailId
        data[FirebaseConstants.VoteCount] = voteCount
        
        return data
    }
}