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
    }
    
    struct Message {
        static let EnterEmail = "Please enter your email address"
        static let EnterPassword = "Please enter your password"
        static let EnterEmailAndPassword = "Please enter your username and password"
        static let ErrorResettingPassword = "There was an error resetting your password"
        static let CheckEmailForPassword = "Please check your email to get your temporary password"
        static let EnterUserName = "Please enter a username"
        static let EnterConfirmPassword = "Please confirm your password"
        static let CompleteAllFields = "Please complete all fields"
    }
    
    struct Button {
        static let Ok = "Ok"
        static let Cancel = "Cancel"
        static let Reset = "Reset"
    }
    
    struct Placeholder {
        static let Email = "Email"
    }
    
//    static let AuthenticationDisabled = "AUTHENTICATION_DISABLED"
//    static let EmailTaken = "EMAIL_TAKEN"
//    static let InvalidArguments = "INVALID_ARGUMENTS"
//    static let InvalidConfiguration = "INVALID_CONFIGURATION"
//    static let InvalidCredentials = "INVALID_CREDENTIALS"
//    static let InvalidEmail = "INVALID_EMAIL"
//    static let InvalidOrigin = "INVALID_ORIGIN"
//    static let InvalidPassword = "INVALID_PASSWORD"
//    static let InvalidProvider = "INVALID_PROVIDER"
//    static let Invalid = "INVALID_TOKEN"
//    static let AuthenticationDisabled = "INVALID_USER"
//    static let AuthenticationDisabled = "NETWORK_ERROR"
//    static let AuthenticationDisabled = "PROVIDER_ERROR"
//    static let AuthenticationDisabled = "TRANSPORT_UNAVAILABLE"
//    static let AuthenticationDisabled = "UNKNOWN_ERROR"
//    static let AuthenticationDisabled = "USER_CANCELLED"
//    static let AuthenticationDisabled = "USER_DENIED"
//    
//    static let authErrorCodes = [
//        "AUTHENTICATION_DISABLED":"The requested authentication provider is disabled for this Firebase application.",
//        "EMAIL_TAKEN":"The new user account cannot be created because the specified email address is already in use.",
//        "INVALID_ARGUMENTS":"The specified credentials are malformed or incomplete. Please refer to the error message, error details, and Firebase documentation for the required arguments for authenticating with this    provider.",
//        "INVALID_CONFIGURATION":"The requested authentication provider is misconfigured, and the request cannot complete. Please confirm that the provider's client ID and secret are correct in your App Dashboard and the app is properly set up on the provider's website.",
//        "INVALID_CREDENTIALS":"The specified authentication credentials are invalid. This may occur when credentials are malformed or expired.",
//        "INVALID_EMAIL":"The specified email is not a valid email.",
//        "INVALID_ORIGIN":"A security error occurred while processing the authentication request. The web origin for the request is not in your list of approved request origins. To approve this origin, visit the Login & Auth tab in your App Dashboard.",
//        "INVALID_PASSWORD":"The specified user account password is incorrect.",
//        "INVALID_PROVIDER":"The requested authentication provider does not exist. Please consult the Firebase Authentication documentation for a list of supported providers.",
//        "INVALID_TOKEN":"The specified authentication token is invalid. This can occur when the token is malformed, expired, or the Firebase app secret that was used to generate it has been revoked.",
//        "INVALID_USER":"The specified user account does not exist.",
//        "NETWORK_ERROR":"An error occurred while attempting to contact the authentication server.",
//        "PROVIDER_ERROR":"A third-party provider error occurred. Please refer to the error message and error details for more information.",
//        "TRANSPORT_UNAVAILABLE":"The requested login method is not available in the user's browser environment. Popups are not available in Chrome for iOS, iOS Preview Panes, or local, file:",
//        "UNKNOWN_ERROR":"An unknown error occurred. Please refer to the error message and error details for more information.",
//        "USER_CANCELLED":"The current authentication request was cancelled by the user.",
//        "USER_DENIED":"The user did not authorize the application. This error can occur when the user has cancelled an OAuth authentication request."
//    ]
}