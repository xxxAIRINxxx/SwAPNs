//
//  AppDelegate.swift
//  SwAPNsDemo
//
//  Created by xxxAIRINxxx on 2015/05/13.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import SwAPNs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        SwAPNs.setup()
        
        SwAPNs.registerType([.Badge, .Sound, .Alert], categories: nil)
        
        SwAPNs.failToRegisterPushHandler = { (error: NSError) in
            print(error)
        }
        
        SwAPNs.registerDeviceTokenHandler = { (deviceToken: NSData) in
            print(deviceToken)
        }
        
        SwAPNs.badgePushHandler = { (userInfo: [NSObject : AnyObject]) in
            print(userInfo)
        }
        
        SwAPNs.soundPushHandler = { (userInfo: [NSObject : AnyObject]) in
            print(userInfo)
        }
        
        SwAPNs.alertPushHandler = { (userInfo: [NSObject : AnyObject]) in
            print(userInfo)
        }
        
        SwAPNs.backgroundFetchHandler = { (userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) in
            print(userInfo)
            print(completion)
        }
        
        SwAPNs.handleActionHandler = { (identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) in
            print(identifier)
            print(userInfo)
            print(completion)
        }
        
        // test
        
        application.delegate!.application!(application, didFailToRegisterForRemoteNotificationsWithError: NSError(domain: "tst", code: 111, userInfo: nil))
        application.delegate!.application!(application, didRegisterForRemoteNotificationsWithDeviceToken: NSData())
        application.delegate!.application!(application, didReceiveRemoteNotification: ["didReceiveRemoteNotification": "test"])
        application.delegate!.application!(application, didReceiveRemoteNotification: ["backgroundfetch": "test"]) { result in
            print("backgroundfetch : result")
        }
        
        application.delegate!.application!(application, handleActionWithIdentifier: "identifier", forRemoteNotification: ["handleActionWithIdentifier": "test"]) {
            print("handleActionWithIdentifier : result")
        }
        
        return true
    }
}

