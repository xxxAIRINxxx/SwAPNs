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
    static var backgroundFetchHandler : DidReceivedBackgroundFetchHandler?
    static var handleActionHandler : DidReceivedHandleActionHandler?
    
    class func convertDeviceToken(deviceToken: NSData) -> String {
        var deviceTokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        return deviceTokenString.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil)
    }
    
    class func setup() {
        SwAPNs.sharedInstance.push.swizzle()
        
        NSNotificationCenter.defaultCenter().addObserver(
            SwAPNs.sharedInstance,
            selector: "handleAppDidFinishLaunchingNotification:",
            name: UIApplicationDidFinishLaunchingNotification,
            object: nil)
    }
    
    // categories is iOS8 Only uses
    class func registerType<T: RawOptionSetType>(types: T, categories: Set<NSObject>?) {
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
        
        Push.replaceClassMethod(aClass, sel: Selector("application:didRegisterForRemoteNotificationsWithDeviceToken:"), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, data: NSData) in
            Push.didRegisterDeviceToken(data)
        } as @objc_block (AnyObject, AnyObject, NSData) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: Selector("application:didFailToRegisterForRemoteNotificationsWithError:"), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, error: NSError) in
            Push.didFailToRegister(error)
        } as @objc_block (AnyObject, AnyObject, NSError) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: Selector("application:didReceiveRemoteNotification:"), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, userInfo: [NSObject : AnyObject]) in
            Push.receivedPush(userInfo)
        } as @objc_block (AnyObject, AnyObject, [NSObject : AnyObject]) -> Void , AnyObject.self))
        
        Push.replaceClassMethod(aClass, sel: Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"), block: unsafeBitCast({
            (appDelegate: AnyObject, app: AnyObject, userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) in
            Push.receivedBackgroundFetch(userInfo, completion: completion)
        } as @objc_block (AnyObject, AnyObject, [NSObject : AnyObject], (UIBackgroundFetchResult) -> Void) -> Void , AnyObject.self))
        
        if UIDevice.isiOS8orLater() {
            Push.replaceClassMethod(aClass, sel: Selector("application:handleActionWithIdentifier:forRemoteNotification:completionHandler:"), block: unsafeBitCast({
                (appDelegate: AnyObject, app: AnyObject, identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) in
                Push.receivedHandleAction(identifier, userInfo: userInfo, completion: completion)
            } as @objc_block (AnyObject, AnyObject, String?, [NSObject : AnyObject], () -> Void) -> Void , AnyObject.self))
        }
    }
    
    class func registerType<T: RawOptionSetType>(types: T, categories: Set<NSObject>?) {
        let app = UIApplication.sharedApplication()
        
        if UIDevice.isiOS8orLater() {
            let settings = UIUserNotificationSettings(forTypes: types as! UIUserNotificationType, categories: categories)
            app.registerUserNotificationSettings(settings)
            app.registerForRemoteNotifications()
        } else {
            app.registerForRemoteNotificationTypes(types as! UIRemoteNotificationType)
        }
    }
    
    class func didFailToRegister(error: NSError) {
        if let _hander = SwAPNs.failToRegisterPushHandler {
            _hander(error)
        }
    }
    
    class func didRegisterDeviceToken(deviceToken: NSData) {
        if let _hander = SwAPNs.registerDeviceTokenHandler {
            _hander(deviceToken)
        }
    }
    
    class func pushTypes() -> (pushBadge: Bool, pushSound: Bool, pushAlert: Bool) {
        var pushBadge = false
        var pushSound = false
        var pushAlert = false
        
        if UIDevice.isiOS8orLater() {
            let types = UIApplication.sharedApplication().currentUserNotificationSettings().types
            if types == .None {
            } else if types == .Badge {
                pushBadge = true
            } else if types == .Sound {
                pushSound = true
            } else if types == .Alert {
                pushAlert = true
            } else if types == .Badge | .Alert {
                pushBadge = true
                pushAlert = true
            } else if types == .Badge | .Sound {
                pushBadge = true
                pushSound = true
            } else if types == .Alert | .Sound {
                pushSound = true
                pushAlert = true
            } else if types == .Badge | .Sound | .Alert {
                pushBadge = true
                pushSound = true
                pushAlert = true
            }
        } else {
            var types = UIApplication.sharedApplication().enabledRemoteNotificationTypes()
            if types == .None {
            } else if types == .Badge {
                pushBadge = true
            } else if types == .Sound {
                pushSound = true
            } else if types == .Alert {
                pushAlert = true
            } else if types == .Badge | .Alert {
                pushBadge = true
                pushAlert = true
            } else if types == .Badge | .Sound {
                pushBadge = true
                pushSound = true
            } else if types == .Alert | .Sound {
                pushSound = true
                pushAlert = true
            } else if types == .Badge | .Sound | .Alert {
                pushBadge = true
                pushSound = true
                pushAlert = true
            }
        }
        
        return (pushBadge, pushSound, pushAlert)
    }
    
    class func receivedPush(userInfo: [NSObject : AnyObject]) {
        if SwAPNs.canReceivedPush == false {
            return
        }
        
        let pushTypes = Push.pushTypes()
        
        if pushTypes.pushBadge == true {
            if let _hander = SwAPNs.badgePushHandler {
                _hander(userInfo)
            }
        }
        if pushTypes.pushSound == true {
            if let _hander = SwAPNs.soundPushHandler {
                _hander(userInfo)
            }
        }
        if pushTypes.pushAlert == true {
            if let _hander = SwAPNs.alertPushHandler {
                _hander(userInfo)
            }
        }
        if let _hander = SwAPNs.alertPushHandler {
            _hander(userInfo)
        }
    }
    
    class func receivedBackgroundFetch(userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) {
        if let _hander = SwAPNs.backgroundFetchHandler {
            _hander(userInfo, completion)
        }
    }
   
    class func receivedHandleAction(identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) {
        if let _hander = SwAPNs.handleActionHandler {
            _hander(identifier, userInfo, completion)
        }
    }
}

// MARK: - UIDevice Extension

public extension UIDevice {
    
    class func iosVersion() -> Float {
        let versionString =  UIDevice.currentDevice().systemVersion
        return NSString(string: versionString).floatValue
    }
    
    class func isiOS8orLater() ->Bool {
        let version = UIDevice.iosVersion()
        
        if version >= 8.0 {
            return true
        }
        return false
    }
}
