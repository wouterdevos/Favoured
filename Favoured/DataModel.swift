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
    
    class func addPoll(question: String, images: [UIImage]) {
        let pollRef = fireDatabase.child(FirebaseConstants.Polls).childByAutoId()
        let pollId = pollRef.key
        
        // Store the images with core data.
        var pollOptions = [PollOption]()
        var photos = [Photo]()
        for (index, image) in images.enumerate() {
            // Add the full image to the list.
            let pollPicture = Photo.getPhoto(pollId, imageName: ImageConstants.PollPictureJPEG, index: index, image: image, isThumbnail: false, context: context)
            photos.append(pollPicture)
            
            // Create a thumbnail image and add it to the list.
            let targetSize = CGSize(width: ImageConstants.PollPictureThumbnailWidth, height: ImageConstants.PollPictureThumbnailHeight)
            let imageThumbnail = Utils.resizeImage(image, targetSize: targetSize)
            let pollPictureThumbnail = Photo.getPhoto(pollId, imageName: ImageConstants.PollPictureThumbnailJPEG, index: index, image: imageThumbnail, isThumbnail: true, context: context)
            photos.append(pollPictureThumbnail)
            
            // Append a new poll option using the image and thumbnail.
            let pollOption = PollOption(pollPictureId: pollPicture.id, pollPictureThumbnailId: pollPictureThumbnail.id)
            pollOptions.append(pollOption)
        }
        saveContext()
        
        // Create and save the poll.
        let poll = Poll(question: question, userId: DataModel.getUserId())
        if let profilePicture = getProfilePicture() {
            poll.profilePictureId = profilePicture.id
        }
        poll.pollOptions = pollOptions
        
        pollRef.setValue(poll.getPollData())
        
        uploadPollPictures(pollId, photos: photos)
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
    
    class func getProfilePicture(id: String, rowIndex: Int?) -> UIImage {
        let photo = fetchProfilePicture(Photo.KeyId, value: id)
        guard photo != nil, let image = photo!.image else {
            downloadProfilePicture(id, isThumbnail: nil, rowIndex: rowIndex)
            return UIImage(named: "ProfilePicture")!
        }
        
        return image
    }
    
    class func getPollPictures(poll: Poll, isThumbnail: Bool, rowIndex: Int?) -> [UIImage] {
        var images = [UIImage]()
        let photos = fetchPollPictures(Photo.KeyPollId, value: poll.id!, isThumbnail: isThumbnail)
        if photos?.count > 0 {
            for pollOption in poll.pollOptions {
                var hasPhoto = false
                for photo in photos! {
                    // Add thumbnail images to the array if they are stored locally.
                    if pollOption.pollPictureThumbnailId == photo.id, let image = photo.image {
                        images.append(image)
                        hasPhoto = true
                        break
                    }
                }
                
                if !hasPhoto {
                    // If the photo is not saved locally then download it.
                    images.append(UIImage(named: "PollPicture")!)
                    let id = isThumbnail ? pollOption.pollPictureThumbnailId : pollOption.pollPictureId
                    downloadPollPicture(id, pollId: poll.id!, isThumbnail: isThumbnail, rowIndex: rowIndex)
                }
            }
        }
        
        
        return images
    }
    
    private class func downloadProfilePicture(id: String, isThumbnail: Bool?, rowIndex: Int?) {
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(id)
        profilePictureRef.dataWithMaxSize(1 * 8192 * 8192) { data, error in
            if error == nil {
                let image = UIImage(data: data!)
                let photo = Photo.getPhoto(id, pollId: nil, image: image, uploaded: true, isThumbnail: false, context: context)
                saveContext()
                let userInfo = [NotificationData.Photo: photo]
                defaultCenter.postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil, userInfo: userInfo)
            }
        }
    }
    
    private class func downloadPollPicture(id: String, pollId: String, isThumbnail: Bool?, rowIndex: Int?) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures).child(id)
        pollPicturesRef.dataWithMaxSize(1 * 8192 * 8192) { data, error in
            if error == nil {
                let image = UIImage(data: data!)
                let photo = Photo.getPhoto(id, pollId: pollId, image: image, uploaded: true, isThumbnail: false, context: context)
                saveContext()
                let userInfo = [NotificationData.Photo: photo]
                defaultCenter.postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil, userInfo: userInfo)
            }
        }
    }
    
    private class func fetchProfilePicture(key: String, value: String) -> Photo? {
        let predicate = NSPredicate(format: "%@ == %@", key, value)
        let photos = fetchPhotos(predicate)
        
        return photos?.count > 0 ? photos![0] : nil
    }
    
    private class func fetchPollPictures(key: String, value: String, isThumbnail: Bool) -> [Photo]? {
        let predicate = NSPredicate(format: "(%@ == %@) AND (isThumbnail == %@)", key, value, isThumbnail)
        let photos = fetchPhotos(predicate)
        
        return photos
    }
    
    private class func fetchPhotos(predicate: NSPredicate) -> [Photo]? {
        let request = NSFetchRequest(entityName: Photo.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.predicate = predicate
        
        var photos: [Photo]? = nil
        do {
            photos = try context.executeFetchRequest(request) as? [Photo]
        } catch let error as NSError {
            print("Error in fetchPhoto \(error)")
        }
        
        return photos
    }
    
    private class func uploadProfilePicture(id: String, profilePicture: UIImage?) {
        guard let profilePictureImage = profilePicture else {
            return
        }
        
        let targetSize = CGSize(width: ImageConstants.ProfilePictureThumbnailWidth, height: ImageConstants.ProfilePictureThumbnailHeight)
        let thumbnail = Utils.resizeImage(profilePictureImage, targetSize: targetSize)
        let profilePictureId = id + ImageConstants.ProfilePictureJPEG
        let photo = Photo.getPhoto(profilePictureId, pollId: nil, image: thumbnail, uploaded: false, isThumbnail: false, context: context)
        saveContext()
        
        // NB - For testing core data.
        let testPhoto = getProfilePicture()
        
        let file = NSURL(fileURLWithPath: photo.path!)
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(photo.id)
        profilePictureRef.putFile(file, metadata: nil) { metadata, error in
            if error == nil {
                photo.uploaded = true
                saveContext()
                let userDetails = [FirebaseConstants.ProfilePictureId: photo.id]
                updateUserDetails(id, userDetails: userDetails)
                
            }
        }
        
    }
    
    private class func uploadPollPictures(pollId: String, photos: [Photo]) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures)
        
        var count = 0
        for photo in photos {
            let file = NSURL(fileURLWithPath: photo.path!)
            let pollPictureRef = pollPicturesRef.child(photo.id)
            pollPictureRef.putFile(file, metadata: nil) { metadata, error in
                if error == nil {
                    photo.uploaded = true
                    saveContext()
                    count += 1
                    if count == photos.count {
                        let pollDetails = [FirebaseConstants.PhotosUploaded: true]
                        updatePollDetails(pollId, pollDetails: pollDetails)
                    }
                }
            }
        }
    }
    
//    private class func getImage(pollId: String, imageName: String, index: Int, pollPicture: UIImage) -> Image {
//        let id = pollId + String(format: imageName, index)
//        let image = Image(id: id, uploaded: false, context: context)
//        image.image = pollPicture
//        return image
//    }
    
    // MARK: - Convenience.
    
    class func getProfilePicture() -> Photo? {
        let uid = getUserId()
        let profilePictureId = uid + ImageConstants.ProfilePictureJPEG
        let photo = fetchProfilePicture(Photo.KeyId, value: profilePictureId)
        return photo
    }
}