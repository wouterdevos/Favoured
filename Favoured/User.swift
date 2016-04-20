//
//  User.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/20.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation

class User: AnyObject {
    
    var username: String?
    var profilePicture: String?
    
    init(username: String?, profilePicture: String?) {
        self.username = username
        self.profilePicture = profilePicture
    }
}