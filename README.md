# SwAPNs

[![CI Status](http://img.shields.io/travis/Airin/ARNAlert.svg?style=flat)](https://travis-ci.org/xxxAIRINxxx/SwAPNs)
[![Version](https://img.shields.io/cocoapods/v/ARNAlert.svg?style=flat)](http://cocoadocs.org/docsets/SwAPNs)
[![License](https://img.shields.io/cocoapods/l/ARNAlert.svg?style=flat)](http://cocoadocs.org/docsets/SwAPNs)
[![Platform](https://img.shields.io/cocoapods/p/ARNAlert.svg?style=flat)](http://cocoadocs.org/docsets/SwAPNs)

Wrap the Apple Push Notification Service (Remote Notification) written in Swift.

## Usage

```swift

SwAPNs.setup()

if UIDevice.isiOS8orLater() {
    SwAPNs.registerType((UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert), categories: nil)
} else {
    SwAPNs.registerType((UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert), categories: nil)
}

SwAPNs.failToRegisterPushHandler = { (error: NSError) in
    // didFailToRegisterForRemoteNotificationsWithError
    println(error)
}

SwAPNs.registerDeviceTokenHandler = { (deviceToken: NSData) in
    // didRegisterForRemoteNotificationsWithDeviceToken
    println(deviceToken)
}

SwAPNs.badgePushHandler = { (userInfo: [NSObject : AnyObject]) in
    // didReceiveRemoteNotification
    println(userInfo)
}

SwAPNs.soundPushHandler = { (userInfo: [NSObject : AnyObject]) in
    // didReceiveRemoteNotification
    println(userInfo)
}

SwAPNs.alertPushHandler = { (userInfo: [NSObject : AnyObject]) in
    // didReceiveRemoteNotification
    println(userInfo)
}

SwAPNs.backgroundFetchHandler = { (userInfo: [NSObject : AnyObject], completion: (UIBackgroundFetchResult) -> Void) in
    // didReceiveRemoteNotification fetchCompletionHandler
    println(userInfo)
    println(completion)
}

// iOS 8.0+ Only
SwAPNs.handleActionHandler = { (identifier: String?, userInfo: [NSObject : AnyObject], completion: () -> Void) in
    // handleActionWithIdentifier forRemoteNotification
    println(identifier)
    println(userInfo)
    println(completion)
}

```

## Method Swizzling (objc runtime)

replaced the following methods.

```objective-c

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

// iOS 8.0+ Only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler;

```

## Objc Version

[ARNPush](https://github.com/xxxAIRINxxx/ARNPush)


## Requirements

* iOS 7.0+
* Swift lang 1.2+
* ARC

## Installation

SwAPNs.swift source file directly in your project.


## License

SwAPNs is available under the MIT license. See the LICENSE file for more info.
