# SwAPNs

Wrap the Apple Push Notification Service (Remote Notification) written in Swift.

## Usage

```swift

SwAPNs.setup()

SwAPNs.registerType((UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert), categories: nil)

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

* Xcode 7.0
* iOS 8.0+
* Swift 2.0

## Installation

SwAPNs.swift source file directly in your project.


## License

MIT license. See the LICENSE file for more info.
