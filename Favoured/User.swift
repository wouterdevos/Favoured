//
//  User.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/20.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData
import Firebase

class User: NSManagedObject {
    
    static let EntityName = "User"
    
    @NSManaged var username: String
    @NSManaged var profilePictureId: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(snapshot: FIRDataSnapshot, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.username = snapshot.value!.objectForKey(FirebaseConstants.Username) as! String
        self.profilePictureId = snapshot.value!.objectForKey(FirebaseConstants.ProfilePictureId) as? String
    }
}