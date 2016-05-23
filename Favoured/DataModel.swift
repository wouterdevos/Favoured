//
//  DataModel.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/04.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation
import Firebase
import AWSS3

class DataModel: NSObject {
    
    private class var fireAuth: FIRAuth {
        return FIRAuth.auth()!
    }
    
    private class var fireDatabase: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    private class var fireStorage: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    private class var defaultCenter: NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    private class var context: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    private class func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK:- Firebase Authentication
    
    class func getUserId() -> String {
        return fireAuth.currentUser!.uid
    }
    
    class func authUser() {
        if let _ = fireAuth.currentUser {
            defaultCenter.postNotificationName(NotificationNames.AuthUserCompleted, object: nil, userInfo: nil)
        }
    }
    
    class func signInWithEmail(email: String, password: String) {
        fireAuth.signInWithEmail(email, password: password) { user, error in
            var userInfo: [String: String]? = nil
            if let error = error {
                userInfo = [String: String]()
                userInfo![NotificationData.Message] = getAuthenticationError(error)
            }
            
            defaultCenter.postNotificationName(NotificationNames.AuthUserCompleted, object: nil, userInfo: userInfo)
        }
    }
    
    class func signOut() {
        try! fireAuth.signOut()
    }
    
    class func sendPasswordResetWithEmail(email: String) {
        fireAuth.sendPasswordResetWithEmail(email) { error in
            var userInfo: [String: String] = [String: String]()
            if error != nil {
                userInfo[NotificationData.Title] = Title.Error
                userInfo[NotificationData.Message] = Error.ErrorResettingPassword
            } else {
                userInfo[NotificationData.Title] = Title.PasswordReset
                userInfo[NotificationData.Message] = Message.CheckEmailForPassword
            }
            
            defaultCenter.postNotificationName(NotificationNames.ResetPasswordForUserCompleted, object: nil, userInfo: userInfo)
        }
    }
    
    class func createUserWithEmail(username: String, email: String, password: String, profilePicture: UIImage?) {
        fireAuth.createUserWithEmail(email, password: password) { user, error in
            var userInfo: [String: String]? = nil
            if error != nil {
                userInfo = [String: String]()
                userInfo![NotificationData.Message] = getAuthenticationError(error!)
            } else {
                setUserDetails(user!.uid, username: username, profilePicture: profilePicture)
            }
            
            defaultCenter.postNotificationName(NotificationNames.CreateUserCompleted, object: nil, userInfo: userInfo)
        }
    }
    
    // MARK: - Firebase database.
    
    class func setUserDetails(uid: String, username: String, profilePicture: UIImage?) {
        // Set the user details.
        let users = fireDatabase.child(FirebaseConstants.Users).child(uid)
        let userDetails = [FirebaseConstants.Username: username]

        users.setValue(userDetails) { error, firebase in
            if error != nil {
                // TODO - Send notification
            } else {
                uploadProfilePicture(uid, profilePicture: profilePicture)
            }
        }
    }
    
    class func addPollListObserver() {
        let polls = fireDatabase.child(FirebaseConstants.Polls)
        polls.observeEventType(.Value, withBlock: { snapshot in
            var polls = [Poll]()
            for snapshotItem in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let poll = Poll(snapshot: snapshotItem)
                polls.append(poll)
            }
            
            let userInfo = [NotificationData.Polls: polls]
            defaultCenter.postNotificationName(NotificationNames.GetPollsCompleted, object: nil, userInfo: userInfo)
        })
    }
    
    class func removePollListObserver() {
        let polls = fireDatabase.child(FirebaseConstants.Polls)
        polls.removeAllObservers()
    }
    
    class func addPoll(question: String, pollPictures: [UIImage]) {
        let pollRef = fireDatabase.child(FirebaseConstants.Polls).childByAutoId()
        let pollId = pollRef.key
        
        // Store the images with core data.
        var pollOptions = [PollOption]()
        var images = [Image]()
        for (index, pollPicture) in pollPictures.enumerate() {
            // Add the full image to the list.
            let image = getImage(pollId, imageName: ImageConstants.PollPictureJPEG, index: index, pollPicture: pollPicture)
            images.append(image)
            
            // Create a thumbnail image and add it to the list.
            let targetSize = CGSize(width: ImageConstants.PollPictureThumbnailWidth, height: ImageConstants.PollPictureThumbnailHeight)
            let pollPictureThumbnail = Utils.resizeImage(pollPicture, targetSize: targetSize)
            let thumbnail = getImage(pollId, imageName: ImageConstants.PollPictureThumbnailJPEG, index: index, pollPicture: pollPictureThumbnail)
            images.append(thumbnail)
            
            // Append a new poll option using the image and thumbnail.
            pollOptions.append(PollOption(pollPicture: image.id, pollPictureThumbnail: thumbnail.id))
        }
        saveContext()
        
        // Create and save the poll.
        let poll = Poll(question: question, userId: DataModel.getUserId())
        poll.pollOptions = pollOptions
        pollRef.setValue(poll.getPollData())
        
        uploadPollPictures(pollId, images: images)
    }
    
    private class func updateUserDetails(uid: String, userDetails: [String: AnyObject]) {
        let users = fireDatabase.child(FirebaseConstants.Users).child(uid)
        users.updateChildValues(userDetails)
    }
    
    private class func updatePollDetails(pollId: String, pollDetails: [String: AnyObject]) {
        let poll = fireDatabase.child(FirebaseConstants.Polls).child(pollId)
        poll.updateChildValues(pollDetails)
    }
    
    private class func getAuthenticationError(error: NSError) -> String {
        if let errorCode = FIRAuthErrorCode(rawValue: error.code) {
            switch errorCode {
            case .ErrorCodeUserNotFound:
                return Error.UserDoesNotExist
            case .ErrorCodeInvalidEmail:
                return Error.EmailInvalidTryAgain
            case .ErrorCodeWrongPassword:
                return Error.PasswordIncorrectTryAgain
            case .ErrorCodeEmailAlreadyInUse:
                return Error.EmailTaken
            default:
                return Error.UnexpectedError
            }
        }
        
        return Error.UnexpectedError
    }
    
    //MARK: - Firebase storage.
    
    private class func uploadProfilePicture(id: String, profilePicture: UIImage?) {
        guard let profilePictureImage = profilePicture else {
            return
        }
        
        let targetSize = CGSize(width: ImageConstants.ProfilePictureThumbnailWidth, height: ImageConstants.ProfilePictureThumbnailHeight)
        let thumbnail = Utils.resizeImage(profilePictureImage, targetSize: targetSize)
        let profilePictureId = id + ImageConstants.ProfilePictureJPEG
        let image = Image(id: profilePictureId, uploaded: false, context: context)
        image.image = thumbnail
        saveContext()
        
        let file = NSURL(fileURLWithPath: image.path!)
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(image.id)
        profilePictureRef.putFile(file, metadata: nil) { metadata, error in
            if error == nil {
                image.uploaded = true
                saveContext()
                let userDetails = [FirebaseConstants.ProfilePicture: image.id]
                updateUserDetails(id, userDetails: userDetails)
            }
        }
        
    }
    
    private class func uploadPollPictures(pollId: String, images: [Image]) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures)
        
        var count = 0
        for image in images {
            let file = NSURL(fileURLWithPath: image.path!)
            let pollPictureRef = pollPicturesRef.child(image.id)
            pollPictureRef.putFile(file, metadata: nil) { metadata, error in
                if error == nil {
                    image.uploaded = true
                    saveContext()
                    count += 1
                    if count == images.count {
                        let pollDetails = [FirebaseConstants.PhotosUploaded: true]
                        updatePollDetails(pollId, pollDetails: pollDetails)
                    }
                }
            }
        }
    }
    
    private class func getImage(pollId: String, imageName: String, index: Int, pollPicture: UIImage) -> Image {
        let id = pollId + String(format: imageName, index)
        let image = Image(id: id, uploaded: false, context: context)
        image.image = pollPicture
        return image
    }
}