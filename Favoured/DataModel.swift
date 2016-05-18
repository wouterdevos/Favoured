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
    
    private class var firebase: Firebase {
        return Firebase(url: FirebaseConstants.URL)
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
    
    // MARK:- Firebase
    
    class func getUserId() -> String {
        return firebase.authData.uid
    }
    
    class func authUser() {
        if let _ = firebase.authData {
            defaultCenter.postNotificationName(NotificationNames.AuthUserCompleted, object: nil, userInfo: nil)
        }
    }
    
    class func authUser(email: String, password: String) {
        firebase.authUser(email, password: password) { error, authData in
            var userInfo: [String: String]? = nil
            if error != nil {
                userInfo = [String: String]()
                userInfo![NotificationData.Message] = getAuthenticationError(error)
            }
            
            defaultCenter.postNotificationName(NotificationNames.AuthUserCompleted, object: nil, userInfo: userInfo)
        }
    }
    
    class func resetPasswordForUser(email: String) {
        firebase.resetPasswordForUser(email) { error in
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
    
    class func createUser(username: String, email: String, password: String, profilePicture: UIImage?) {
        firebase.createUser(email, password: password) { error, result in
            var userInfo: [String: String]? = nil
            if error != nil {
                userInfo = [String: String]()
                userInfo![NotificationData.Message] = getAuthenticationError(error)
            } else {
                let uid = result["uid"] as? String
                setUserDetails(uid!, username: username, profilePicture: profilePicture)
            }
            
            defaultCenter.postNotificationName(NotificationNames.CreateUserCompleted, object: nil, userInfo: userInfo)
        }
    }
    
    class func setUserDetails(uid: String, username: String, profilePicture: UIImage?) {
        // Set the user details.
        let users = firebase.childByAppendingPath(FirebaseConstants.Users).childByAppendingPath(uid)
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
        let polls = firebase.childByAppendingPath(FirebaseConstants.Polls)
        polls.observeEventType(.Value, withBlock: { snapshot in
            var polls = [Poll]()
            for snapshotItem in snapshot.children.allObjects as! [FDataSnapshot] {
                let poll = Poll(snapshot: snapshotItem)
                polls.append(poll)
            }
            
            let userInfo = [NotificationData.Polls: polls]
            defaultCenter.postNotificationName(NotificationNames.GetPollsCompleted, object: nil, userInfo: userInfo)
        })
    }
    
    class func removePollListObserver() {
        let polls = firebase.childByAppendingPath(FirebaseConstants.Polls)
        polls.removeAllObservers()
    }
    
    class func addPoll(pollDetails: [String:AnyObject], pollPictures: [UIImage]) {
        let newPoll = firebase.childByAppendingPath(FirebaseConstants.Polls).childByAutoId()
        let pollId = newPoll.key!
        newPoll.setValue(pollDetails)
        uploadPollPictures(pollId, pollPictures: pollPictures)
    }
    
    private class func updateUserDetails(uid: String, userDetails: [String: AnyObject]) {
        let users = firebase.childByAppendingPath(FirebaseConstants.Users).childByAppendingPath(uid)
        users.updateChildValues(userDetails)
    }
    
    private class func updatePollDetails(pollId: String, pollDetails: [String: AnyObject]) {
        let poll = firebase.childByAppendingPath(FirebaseConstants.Polls).childByAppendingPath(pollId)
        poll.updateChildValues(pollDetails)
    }
    
    private class func getAuthenticationError(error: NSError) -> String {
        if let errorCode = FAuthenticationError(rawValue: error.code) {
            switch errorCode {
            case .UserDoesNotExist:
                return Error.UserDoesNotExist
            case .InvalidEmail:
                return Error.EmailInvalidTryAgain
            case .InvalidPassword:
                return Error.PasswordIncorrectTryAgain
            case .EmailTaken:
                return Error.EmailTaken
            default:
                return Error.UnexpectedError
            }
        }
        
        return Error.UnexpectedError
    }
    
    // MARK:- AWS S3
    
    private class func uploadProfilePicture(id: String, profilePicture: UIImage?) {
        guard let profilePictureImage = profilePicture else {
            return
        }
        
        let targetSize = CGSize(width: ImageConstants.ThumbnailWidth, height: ImageConstants.ThumbnailHeight)
        let thumbnail = Utils.resizeImage(profilePictureImage, targetSize: targetSize)
        let profilePictureId = id + ImageConstants.ProfilePictureJPEG
        let image = Image(id: profilePictureId, uploaded: false, context: context)
        image.image = thumbnail
        saveContext()
        
        let uploadRequest = getUploadRequest(image)
        upload(uploadRequest) { success, key in
            if success {
                image.uploaded = true
                saveContext()
                let userDetails = [FirebaseConstants.ProfilePicture: image.id]
                updateUserDetails(id, userDetails: userDetails)
            }
        }
    }
    
    private class func uploadPollPictures(pollId: String, pollPictures: [UIImage]) {
        // Store the image in with core data.
        var images = [Image]()
        for (index, pollPicture) in pollPictures.enumerate() {
            let image = getImage(pollId, index: index, pollPicture: pollPicture)
            images.append(image)
        }
        saveContext()
        
        var count = 0
        for image in images {
            let uploadRequest = getUploadRequest(image)
            upload(uploadRequest) { success, key in
                if success {
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
    
    private class func upload(uploadRequest: AWSS3TransferManagerUploadRequest, handler: ((success: Bool, key: String) -> Void)) {
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                if error.domain == AWSS3TransferManagerErrorDomain as String {
                    if let errorCode = AWSS3TransferManagerErrorType(rawValue: error.code) {
                        switch (errorCode) {
                        case .Cancelled, .Paused:
                            handler(success: false, key: uploadRequest.key!)
                            print("upload() cancelled or paused: [\(error)]")
                            break;
                            
                        default:
                            handler(success: false, key: uploadRequest.key!)
                            print("upload() failed: [\(error)]")
                            break;
                        }
                    } else {
                        handler(success: false, key: uploadRequest.key!)
                        print("upload() failed: [\(error)]")
                    }
                } else {
                    handler(success: false, key: uploadRequest.key!)
                    print("upload() failed: [\(error)]")
                }
            }
            
            if let exception = task.exception {
                handler(success: false, key: uploadRequest.key!)
                print("upload() failed: [\(exception)]")
            }
            
            if task.result != nil {
                handler(success: true, key: uploadRequest.key!)
            }
            return nil
        }
    }
    
    private class func getUploadRequest(image: Image) -> AWSS3TransferManagerUploadRequest {
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = NSURL(fileURLWithPath: image.path!)
        uploadRequest.key = image.id
        uploadRequest.bucket = AWSConstants.BucketProfilePictures
        return uploadRequest
    }
    
    private class func getImage(pollId: String, index: Int, pollPicture: UIImage) -> Image {
        let id = pollId + String(format: ImageConstants.PollPictureJPEG, index)
        let image = Image(id: id, uploaded: false, context: context)
        image.image = pollPicture
        return image
    }
}