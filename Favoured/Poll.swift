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
    var creationDate: String
    var selectedOption: String
    var closed: Bool
    var photosUploaded: Bool
    var optionA: PollOption
    var optionB: PollOption
    var optionC: PollOption
    var optionD: PollOption
    
    init(snapshot: FDataSnapshot) {
        question = snapshot.value[FirebaseConstants.Question] as! String
        userId = snapshot.value[FirebaseConstants.UserId] as! String
        creationDate = snapshot.value[FirebaseConstants.CreationDate] as! String
        selectedOption = snapshot.value[FirebaseConstants.SelectedOption] as! String
        closed = snapshot.value[FirebaseConstants.Question] as! Bool
        photosUploaded = snapshot.value[FirebaseConstants.Question] as! Bool
        optionA = PollOption(snapshot: snapshot.childSnapshotForPath(FirebaseConstants.OptionA))
        optionB = PollOption(snapshot: snapshot.childSnapshotForPath(FirebaseConstants.OptionB))
        optionC = PollOption(snapshot: snapshot.childSnapshotForPath(FirebaseConstants.OptionC))
        optionD = PollOption(snapshot: snapshot.childSnapshotForPath(FirebaseConstants.OptionD))
    }
}