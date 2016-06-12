//
//  Enums.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/06/11.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation

enum TableViewState: Int {
    case Loading = 0
    case Empty = 1
    case Populated = 2
}

enum PollsType: Int {
    case MyPolls = 0
    case AllPolls = 1
}

enum VoteState {
    case Disabled
    case Pending
    case Cast(Int)
}