//
//  FirebaseUtils.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/04.
//  Copyright © 2016 Wouter. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Firebase {
        static let URL = "https://flickering-inferno-7778.firebaseio.com/"
    }
    
    struct Title {
        static let ResetPassword = "Reset Password"
        static let PasswordReset = "Password Reset"
        static let Error = "Error"
        static let SelectProfilePicture = "Select Profile Picture"
        static let SelectPicture = "Select Picture"
    }
    
    struct Message {
        static let EmailEnter = "Please enter your email."
        static let CheckEmailForPassword = "Please check your email to get your temporary password."
    }
    
    struct Error {
        static let EmailInvalid = "Invalid email address."
        static let EmailRequired = "Email is required."
        static let EmailTaken = "An account already exists for that email address."
        static let PasswordRequired = "Password is required."
        static let PasswordRule = "Must be at least 8 characters long."
        static let UsernameRequired = "Username is required."
        static let ErrorResettingPassword = "There was an error resetting your password."
        static let EmailInvalidTryAgain = "Invalid email address. Please try again."
        static let PasswordIncorrectTryAgain = "Incorrect password. Please try again."
        static let UserDoesNotExist = "That user does not exist. Please try again."
        static let UnexpectedError = "An unexpected error occured. Please try again."
    }
    
    struct Button {
        static let Ok = "Ok"
        static let Cancel = "Cancel"
        static let Reset = "Reset"
        static let Camera = "Camera"
        static let PhotoLibrary = "Photo Library"
    }
    
    struct Placeholder {
        static let Email = "Email"
    }
}