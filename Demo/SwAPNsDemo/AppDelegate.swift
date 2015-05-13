//
//  AppDelegate.swift
//  SwAPNsDemo
//
//  Created by xxxAIRINxxx on 2015/05/13.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        SwAPNs.setup()
        
        if UIDevice.isiOS8orLater() {
            SwAPNs.registerType((UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert), categories: nil)
        } else {
            SwAPNs.registerType((UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert), categories: nil)
        }
        
        SwAPNs.failToRegisterPushHandler = { (error: NSError) in
            println(error)
        }
        
        SwAPNs.registerDeviceTokenHandler = { (deviceToken: NSData) in
            println(deviceToken)
        }
        
        SwAPNs.badgePushHandler = { (userInfo: [NSObject : AnyObject]) in
            println(userInfo)
        }
        
        SwAPNs.soundPushHandler = { (userInfo: [NSObject : AnyObject]) in
            println(userInfo)
        }
        
        SwAPNs.alertPushHandler = { (userInfo: [NSObject : AnyObject]) in
            println(userInfo)
        }
        
        SwAPNs.backgroundFetchHandler = { (userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) in
            println(userInfo)
            println(completion)
        }
        
        SwAPNs.handleActionHandler = { (identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) in
            println(identifier)
            println(userInfo)
            println(completion)
        }
        
        // test
        
        application.delegate!.application!(application, didFailToRegisterForRemoteNotificationsWithError: NSError(domain: "tst", code: 111, userInfo: nil))
        application.delegate!.application!(application, didRegisterForRemoteNotificationsWithDeviceToken: NSData())
        application.delegate!.application!(application, didReceiveRemoteNotification: ["didReceiveRemoteNotification": "test"])
        application.delegate!.application!(application, didReceiveRemoteNotification: ["backgroundfetch": "test"]) { result in
            println("backgroundfetch : result")
        }
        if UIDevice.isiOS8orLater() {
            application.delegate!.application!(application, handleActionWithIdentifier: "identifier", forRemoteNotification: ["handleActionWithIdentifier": "test"]) {
                println("handleActionWithIdentifier : result")
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

