//
//  AppDelegate.swift
//  Favoured
//
//  Created by Wouter de Vos on 2016/04/02.
//  Copyright © 2016 Wouter. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FIRApp.configure()
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSConstants.RegionType,
            identityPoolId: AWSConstants.IdentityPoolId)
        let configuration = AWSServiceConfiguration(region: AWSConstants.RegionType, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        return true
    }
}

