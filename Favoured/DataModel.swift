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
    
    class func setUserDetails(userId: String, username: String, profilePicture: UIImage?) {
        // Set the user details.
        let users = fireDatabase.child(FirebaseConstants.Users).child(userId)
        let userDetails = [FirebaseConstants.Username: username]

        users.setValue(userDetails) { error, firebase in
            if error == nil {
                let photo = createProfilePicturePhoto(userId, image: profilePicture)
                uploadProfilePicture(userId, photo: photo)
            }
        }
    }
    
    class func addMyPollsListObserver() {
        removePollListObserver()
        let myPolls = fireDatabase.child(FirebaseConstants.Polls)
        let myPollsQuery = myPolls.queryOrderedByChild(FirebaseConstants.CreationDate)//.queryEqualToValue(FirebaseConstants.UserId, childKey: getUserId())
        observePollsList(myPollsQuery)
    }
    
    class func addAllPollsListObserver() {
        removePollListObserver()
        let allPolls = fireDatabase.child(FirebaseConstants.Polls)
        let allPollsQuery = allPolls.queryOrderedByChild(FirebaseConstants.CreationDate)
        observePollsList(allPollsQuery)
    }
    
//    class func addPollListObserver() {
//        let polls = fireDatabase.child(FirebaseConstants.Polls)
//        polls.observeEventType(.Value, withBlock: { snapshot in
//            var polls = [Poll]()
//            for snapshotItem in snapshot.children.allObjects as! [FIRDataSnapshot] {
//                let poll = Poll(snapshot: snapshotItem)
//                polls.append(poll)
//            }
//            
//            let userInfo = [NotificationData.Polls: polls]
//            defaultCenter.postNotificationName(NotificationNames.GetPollsCompleted, object: nil, userInfo: userInfo)
//        })
//    }
    
    class func removePollListObserver() {
        let polls = fireDatabase.child(FirebaseConstants.Polls)
        polls.removeAllObservers()
    }
    
    class func observePollsList(query: FIRDatabaseQuery) {
        query.observeEventType(.Value, withBlock: { snapshot in
            var polls = [Poll]()
            for snapshotItem in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let poll = Poll(snapshot: snapshotItem)
                polls.append(poll)
            }
            
            let userInfo = [NotificationData.Polls: polls]
            defaultCenter.postNotificationName(NotificationNames.GetPollsCompleted, object: nil, userInfo: userInfo)
        })
    }
    
    class func addConnectionStateObserver() {
        let connectedRef = FIRDatabase.database().referenceWithPath(FirebaseConstants.InfoConnected)
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
            if let connected = snapshot.value as? Bool where connected {
                print("Connected")
                uploadLocalOnlyPhotos()
            } else {
                print("Not connected")
            }
        })
    }
    
    class func removeConnectionStateObserver() {
        let connectedRef = FIRDatabase.database().referenceWithPath(FirebaseConstants.InfoConnected)
        connectedRef.removeAllObservers()
    }
    
    class func addPoll(question: String, images: [UIImage]) {
        let pollRef = fireDatabase.child(FirebaseConstants.Polls).childByAutoId()
        let pollId = pollRef.key
        
        // Store the images with core data.
        var pollOptions = [PollOption]()
        var photos = [Photo]()
        for (index, image) in images.enumerate() {
            // Add the full image to the list of photos.
            let pollPicture = createPollPicturePhoto(pollId, image: image, index: index)
            photos.append(pollPicture)
            
            // Create a thumbnail image and add it to the photos list.
            let pollPictureThumbnail = createPollPictureThumbnailPhoto(pollId, image: image, index: index)
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
    
    private class func uploadLocalOnlyPhotos() {
        // Upload the profile picture if it is only stored locally.
        if let profilePicture = getProfilePicture() where !profilePicture.uploaded {
            print("profilePicture.uploaded \(profilePicture.uploaded)")
            uploadProfilePicture(getUserId(), photo: profilePicture)
        }
        
        // Uploaded poll pictures if they are only stored locally.
        if let photos = fetchLocalOnlyPhotos() where photos.count > 0 {
            for photo in photos {
                print("photo.uploaded \(photo.uploaded)")
            }
            uploadPollPictures(photos)
        }
    }
    
    //MARK: - Firebase storage.
    
    class func getProfilePicture(id: String, rowIndex: Int?) -> UIImage {
        let photo = fetchPhotoById(id)
        guard photo != nil, let image = photo!.image else {
            downloadProfilePicture(id, isThumbnail: true, rowIndex: rowIndex)
            return UIImage(named: "ProfilePicture")!
        }
        
        return image
    }
    
    class func getPollPictures(poll: Poll, isThumbnail: Bool, rowIndex: Int?) -> [UIImage] {
        var images = [UIImage]()
        let photos = fetchPhotosByPollId(poll.id!, isThumbnail: isThumbnail)
        
        for pollOption in poll.pollOptions {
            var hasPhoto = false
            if photos?.count > 0 {
                for photo in photos! {
                    // Add thumbnail images to the array if they are stored locally.
                    if pollOption.pollPictureThumbnailId == photo.id, let image = photo.image {
                        images.append(image)
                        hasPhoto = true
                        break
                    }
                }
            }
            
            if !hasPhoto {
                // If the photo is not saved locally then download it.
                images.append(UIImage(named: "PollPicture")!)
                let id = isThumbnail ? pollOption.pollPictureThumbnailId : pollOption.pollPictureId
                downloadPollPicture(id, pollId: poll.id!, isThumbnail: isThumbnail, rowIndex: rowIndex)
            }
        }
        
        return images
    }
    
    private class func downloadProfilePicture(id: String, isThumbnail: Bool, rowIndex: Int?) {
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(id)
        profilePictureRef.dataWithMaxSize(1 * 8192 * 8192) { data, error in
            if error == nil {
                let image = UIImage(data: data!)
                let photo = Photo(id: id, pollId: nil, uploaded: true, isThumbnail: true, image: image, context: context)
                saveContext()
                let userInfo = [NotificationData.Photo: photo]
                defaultCenter.postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil, userInfo: userInfo)
            }
        }
    }
    
    private class func downloadPollPicture(id: String, pollId: String, isThumbnail: Bool, rowIndex: Int?) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures).child(id)
        pollPicturesRef.dataWithMaxSize(1 * 8192 * 8192) { data, error in
            if error == nil {
                let image = UIImage(data: data!)
                let photo = Photo(id: id, pollId: pollId, uploaded: true, isThumbnail: isThumbnail, image: image, context: context)
                saveContext()
                let userInfo = [NotificationData.Photo: photo,
                                NotificationData.RowIndex: rowIndex!] as [String:AnyObject]
                defaultCenter.postNotificationName(NotificationNames.PhotoDownloadCompleted, object: nil, userInfo: userInfo)
            }
        }
    }
    
    private class func uploadProfilePicture(userId: String, photo: Photo?) {
        guard let profilePicturePhoto = photo else {
            return
        }
        
        let file = NSURL(fileURLWithPath: profilePicturePhoto.path!)
        let profilePictureRef = fireStorage.child(FirebaseConstants.BucketProfilePictures).child(profilePicturePhoto.id)
        profilePictureRef.putFile(file, metadata: nil) { metadata, error in
            if error == nil {
                profilePicturePhoto.uploaded = true
                saveContext()
                let userDetails = [FirebaseConstants.ProfilePictureId: profilePicturePhoto.id]
                updateUserDetails(userId, userDetails: userDetails)
            }
        }
    }
    
    private class func uploadPollPictures(photos: [Photo]) {
        let pollPicturesRef = fireStorage.child(FirebaseConstants.BucketPollPictures)
        
//        var count = 0
        for photo in photos {
            let file = NSURL(fileURLWithPath: photo.path!)
            let pollPictureRef = pollPicturesRef.child(photo.id)
            pollPictureRef.putFile(file, metadata: nil) { metadata, error in
                if error == nil {
                    photo.uploaded = true
                    saveContext()
//                    count += 1
//                    if count == photos.count {
//                        let pollDetails = [FirebaseConstants.PhotosUploaded: true]
//                        updatePollDetails(photo.pollId!, pollDetails: pollDetails)
//                    }
                }
            }
        }
    }
    
    // MARK: - Core data fetch requests.
    
    private class func fetchPhotoById(id: String) -> Photo? {
        let predicate = NSPredicate(format: "id == %@", id)
        let photos = fetchPhotos(predicate)
        
        return photos?.count > 0 ? photos![0] : nil
    }
    
    private class func fetchPhotosByPollId(pollId: String, isThumbnail: Bool) -> [Photo]? {
        let predicate = NSPredicate(format: "(pollId == %@) AND (isThumbnail == %@)", pollId, isThumbnail)
        let photos = fetchPhotos(predicate)
        
        return photos
    }
    
    private class func fetchLocalOnlyPhotos() -> [Photo]? {
        let profilePictureId = getProfilePictureId()
        let predicate = NSPredicate(format: "(id != %@) AND (uploaded == %@)", profilePictureId, false)
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
    
    // MARK: - Convenience methods.
    
    private class func createProfilePicturePhoto(id: String, image: UIImage?) -> Photo? {
        guard let profilePictureImage = image else {
            return nil
        }
        
        let targetSize = CGSize(width: ImageConstants.ProfilePictureThumbnailWidth, height: ImageConstants.ProfilePictureThumbnailHeight)
        let thumbnail = Utils.resizeImage(profilePictureImage, targetSize: targetSize)
        let profilePictureId = id + ImageConstants.ProfilePictureJPEG
        let photo = Photo(id: profilePictureId, pollId: nil, uploaded: false, isThumbnail: true, image: thumbnail, context: context)
        saveContext()
        return photo
    }
    
    private class func createPollPicturePhoto(pollId: String, image: UIImage, index: Int) -> Photo {
        let id = pollId + String(format: ImageConstants.PollPictureJPEG, index)
        return Photo(id: id, pollId: pollId, uploaded: false, isThumbnail: false, image: image, context: context)
    }
    
    private class func createPollPictureThumbnailPhoto(pollId: String, image: UIImage, index: Int) -> Photo {
        let targetSize = CGSize(width: ImageConstants.PollPictureThumbnailWidth, height: ImageConstants.PollPictureThumbnailHeight)
        let imageThumbnail = Utils.resizeImage(image, targetSize: targetSize)
        let id = pollId + String(format: ImageConstants.PollPictureThumbnailJPEG, index)
        return Photo(id: id, pollId: pollId, uploaded: false, isThumbnail: true, image: imageThumbnail, context: context)
    }
    
    private class func getProfilePictureId() -> String {
        let userId = getUserId()
        return userId + ImageConstants.ProfilePictureJPEG
    }
    
    private class func getProfilePicture() -> Photo? {
        let photo = fetchPhotoById(getProfilePictureId())
        return photo
    }
}