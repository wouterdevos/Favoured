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
    
    var pollPicture: String
    var voteCount: Int
    
    init(snapshot: FDataSnapshot) {
        self.pollPicture = snapshot.value[FirebaseConstants.PollPicture] as! String
        self.voteCount = snapshot.value[FirebaseConstants.VoteCount] as! Int
    }
}