//
//  Poll.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/08.
//  Copyright © 2016 Wouter. All rights reserved.
//

import CoreData
import Firebase

class Poll: NSManagedObject {
    
    @NSManaged var question: String
    @NSManaged var userId: String
    @NSManaged var selectedOption: String?
    @NSManaged var creationDate: NSNumber
    @NSManaged var closed: Bool
    @NSManaged var photosUploaded: Bool
    @NSManaged var profilePicture: Photo?
    @NSManaged var pollOptions: [PollOption]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(question: String, userId: String, profilePicture: Photo?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Poll", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.question = question
        self.userId = userId
        self.creationDate = NSNumber(double: Utils.getTimeIntervalSince1970())
        self.closed = false
        self.photosUploaded = false
        self.profilePicture = profilePicture
    }
    
    init(snapshot: FIRDataSnapshot, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Poll", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let closedNumber = snapshot.value!.objectForKey(FirebaseConstants.Closed) as! NSNumber
        let photosUploadedNumber = snapshot.value!.objectForKey(FirebaseConstants.PhotosUploaded) as! NSNumber
        let profilePictureId = snapshot.value!.objectForKey(FirebaseConstants.ProfilePictureId) as! String
        
        question = snapshot.value!.objectForKey(FirebaseConstants.Question) as! String
        userId = snapshot.value!.objectForKey(FirebaseConstants.UserId) as! String
        selectedOption = snapshot.value!.objectForKey(FirebaseConstants.SelectedOption) as? String
        creationDate = snapshot.value!.objectForKey(FirebaseConstants.CreationDate) as! NSNumber
        closed = Bool(closedNumber)
        photosUploaded = Bool(photosUploadedNumber)
        profilePicture = Photo.getPhoto(profilePictureId, image: nil, uploaded: true, context: context)
        
        let pollOptionsSnapshot = snapshot.childSnapshotForPath(FirebaseConstants.PollOptions)
        for index in 0..<pollOptionsSnapshot.childrenCount {
            let pollOptionSnapshot = pollOptionsSnapshot.childSnapshotForPath(String(index))
            let pollOption = PollOption(snapshot: pollOptionSnapshot, context: context)
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
        if let profilePictureId = profilePicture?.id {
            data[FirebaseConstants.ProfilePictureId] = profilePictureId
        }
        
        return data
    }
}