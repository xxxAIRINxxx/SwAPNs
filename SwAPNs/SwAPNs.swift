//
//  SwAPNs.swift
//  SwAPNs
//
//  Created by xxxAIRINxxx on 2015/05/13.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

public typealias DidFailToRegisterPushHandler = NSError -> Void
public typealias DidRegisterDeviceTokenHandler = NSData -> Void
public typealias DidReceivedPushHandler = [NSObject : AnyObject] -> Void
public typealias DidReceivedBackgroundFetchHandler = ([NSObject : AnyObject], (UIBackgroundFetchResult) -> Void) -> Void
public typealias DidReceivedHandleActionHandler = (String?, [NSObject : AnyObject], () -> Void) -> Void

public class SwAPNs: NSObject {
    
    static var sharedInstance = SwAPNs()
    
    private var push : Push = Push()
    
    static var canReceivedPush : Bool = true
    
    static var failToRegisterPushHandler : DidFailToRegisterPushHandler?
    static var registerDeviceTokenHandler : DidRegisterDeviceTokenHandler?
    static var badgePushHandler : DidReceivedPushHandler?
    static var soundPushHandler : DidReceivedPushHandler?
    static var alertPushHandler : DidReceivedPushHandler?
    static var receivedAnyHandler : DidReceivedPushHandler?
    static var backgroundFetchHandler : DidReceivedBackgroundFetchHandler?
    static var handleActionHandler : DidReceivedHandleActionHandler?
    
    class func convertDeviceToken(deviceToken: NSData) -> String {
        let deviceTokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        return deviceTokenString.stringByReplacingOccurrencesOfString(" ", withString: "", options: [], range: nil)
    }
    
    class func setup() {
        SwAPNs.sharedInstance.push.swizzle()
        
        NSNotificationCenter.defaultCenter().addObserver(
            SwAPNs.sharedInstance,
            selector: #selector(SwAPNs.handleAppDidFinishLaunchingNotification(_:)),
            name: UIApplicationDidFinishLaunchingNotification,
            object: nil)
    }
    
    class func registerType<T: OptionSetType>(types: T, categories: Set<UIUserNotificationCategory>?) {
        Push.registerType(types, categories: categories)
    }
    
    func handleAppDidFinishLaunchingNotification(notification: NSNotification) {
        if let _launchOptions: [NSObject:AnyObject] = notification.userInfo {
            if let _userInfo = _launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] {
                Push.receivedPush(_userInfo)
            }
        }
    }
}

private class Push: NSObject {
    
    class func replaceClassMethod(targetClass: AnyClass, sel: Selector, block: AnyObject!) {
        let newIMP = imp_implementationWithBlock(block)
        let types = method_getTypeEncoding(class_getInstanceMethod(targetClass, sel))
        class_replaceMethod(targetClass, sel, newIMP, types)
    }
    
    func swizzle() {
        let delegate = UIApplication.sharedApplication().delegate!
        let aClass: AnyClass! = object_getClass(delegate)
        // @see : http://stackoverflow.com/questions/28211973/swift-closure-as-anyobject
        
        Push.replaceClassMethod(aClass, sel: #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, data: NSData) in
            Push.didRegisterDeviceToken(data)
        } as @convention(block) (AnyObject, AnyObject, NSData) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, error: NSError) in
            Push.didFailToRegister(error)
        } as @convention(block) (AnyObject, AnyObject, NSError) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:)), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, userInfo: [NSObject : AnyObject]) in
            Push.receivedPush(userInfo)
        } as @convention(block) (AnyObject, AnyObject, [NSObject : AnyObject]) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) in
            Push.receivedBackgroundFetch(userInfo, completion: completion)
        } as @convention(block) (AnyObject, AnyObject, [NSObject : AnyObject], (UIBackgroundFetchResult) -> Void) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: #selector(UIApplicationDelegate.application(_:handleActionWithIdentifier:forRemoteNotification:completionHandler:)), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) in
            Push.receivedHandleAction(identifier, userInfo: userInfo, completion: completion)
        } as @convention(block) (AnyObject, AnyObject, String?, [NSObject : AnyObject], () -> Void) -> Void , AnyObject.self))
    }
    
    class func registerType<T: OptionSetType>(types: T, categories: Set<UIUserNotificationCategory>?) {
        let app = UIApplication.sharedApplication()
        
        let settings = UIUserNotificationSettings(forTypes: types as! UIUserNotificationType, categories: categories)
        app.registerUserNotificationSettings(settings)
        app.registerForRemoteNotifications()
    }
    
    class func didFailToRegister(error: NSError) {
        SwAPNs.failToRegisterPushHandler?(error)
    }
    
    class func didRegisterDeviceToken(deviceToken: NSData) {
        SwAPNs.registerDeviceTokenHandler?(deviceToken)
    }
    
    class func pushTypes() -> (pushBadge: Bool, pushSound: Bool, pushAlert: Bool) {
        var pushBadge = false
        var pushSound = false
        var pushAlert = false
        
        let types = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
        if types == .None {
        } else if types == .Badge {
            pushBadge = true
        } else if types == .Sound {
            pushSound = true
        } else if types == .Alert {
            pushAlert = true
        } else if types == UIUserNotificationType.Badge.union(.Alert) {
            pushBadge = true
            pushAlert = true
        } else if types == UIUserNotificationType.Badge.union(.Sound) {
            pushBadge = true
            pushSound = true
        } else if types == UIUserNotificationType.Alert.union(.Sound) {
            pushSound = true
            pushAlert = true
        } else if types == UIUserNotificationType.Badge.union(.Sound).union(.Alert) {
            pushBadge = true
            pushSound = true
            pushAlert = true
        }
        
        return (pushBadge, pushSound, pushAlert)
    }
    
    class func receivedPush(userInfo: [NSObject : AnyObject]) {
        if SwAPNs.canReceivedPush == false {
            return
        }
        
        let pushTypes = Push.pushTypes()
        
        if pushTypes.pushBadge == true {
            SwAPNs.badgePushHandler?(userInfo)
        }
        if pushTypes.pushSound == true {
            SwAPNs.soundPushHandler?(userInfo)
        }
        if pushTypes.pushAlert == true {
            SwAPNs.alertPushHandler?(userInfo)
        }
        SwAPNs.receivedAnyHandler?(userInfo)
    }
    
    class func receivedBackgroundFetch(userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) {
        SwAPNs.backgroundFetchHandler?(userInfo, completion)
    }
   
    class func receivedHandleAction(identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) {
        SwAPNs.handleActionHandler?(identifier, userInfo, completion)
    }
}