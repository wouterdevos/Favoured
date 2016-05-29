//
//  PollOption.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData
import Firebase

class PollOption: NSManagedObject {
    
    let DefaultVoteCount = 0
    
    @NSManaged var pollPicture: Photo
    @NSManaged var pollPictureThumbnail: Photo
    @NSManaged var voteCount: NSNumber
    @NSManaged var poll: Poll?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(pollPicture: Photo, pollPictureThumbnail: Photo, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("PollOption", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.pollPicture = pollPicture
        self.pollPictureThumbnail = pollPictureThumbnail
        self.voteCount = DefaultVoteCount
    }
    
    init(snapshot: FIRDataSnapshot, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("PollOption", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let pollPictureId = snapshot.value!.objectForKey(FirebaseConstants.PollPictureId) as! String
        let pollPictureThumbnailId = snapshot.value!.objectForKey(FirebaseConstants.PollPictureThumbnailId) as! String
        pollPicture = Photo.getPhoto(pollPictureId, image: nil, uploaded: true, context: context)
        pollPictureThumbnail = Photo.getPhoto(pollPictureThumbnailId, image: nil, uploaded: true, context: context)
        voteCount = snapshot.value!.objectForKey(FirebaseConstants.VoteCount) as! NSNumber
    }
    
    func getPollOptionData() -> [String:AnyObject] {
        var data = [String: AnyObject]()
        data[FirebaseConstants.PollPictureId] = pollPicture.id
        data[FirebaseConstants.PollPictureThumbnailId] = pollPictureThumbnail.id
        data[FirebaseConstants.VoteCount] = voteCount
        
        return data
    }
}