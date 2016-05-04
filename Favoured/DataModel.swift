//
//  DataModel.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/05/04.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation
import Firebase

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
                userInfo = [NotificationData.Message: getAuthenticationError(error)]
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
    
    class func createUser(username: String, email: String, password: String, profilePicturePath: String?) {
        firebase.createUser(email, password: password) { error, result in
            if error != nil {
                let message = getAuthenticationError(error)
                // TODO - Send notification
            } else {
                let uid = result["uid"] as? String
                print("Successfully logged in with uid: \(uid)")
                setUserDetails(uid!, username: username, profilePicturePath: profilePicturePath)
            }
        }
    }
    
    class func setUserDetails(uid: String, username: String, profilePicturePath: String?) {
        // Set the user details.
        let users = firebase.childByAppendingPath(FirebaseConstants.Users)
        var userDetails = [FirebaseConstants.Username: username]
//        if let image = profilePictureUrl {
//            userDetails[FirebaseConstants.ProfilePicture] = image
//        }
        let user = [uid: userDetails]
        users.setValue(user) { error, firebase in
            if error != nil {
                // TODO - Send notification
            } else {
                print("User details uploaded successfully")
                // TODO - Upload profile picture
            }
        }
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
}