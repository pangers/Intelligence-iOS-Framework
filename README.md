# Intelligence SDK #

The goal of this SDK is to encapsulate in a developer-friendly manner the Intelligence platform's API's.

# Getting Started #

## Adding IntelligenceSDK ##

In this section, we detail how to Integrate IntelligenceSDK for both Objective-C and Swift based projects.

We can import the SDK through Cocoapods, Carthage or Import Manually to your application

#### Through Cocoapods ####

We can install Intelligence SDK through [Cocoapods](https://git-apac.internal.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK/blob/Documentation/Examples/CocoaPods/Swift/Intelligence/ReadMe.md). Open a terminal window and navigate to the root folder of your project.

If you have not already created a Podfile for your application, create one now:

```
    pod init
```

Open the Podfile created for your application and add the following to your target:

```
    target :YourTargetName do
        pod 'IntelligenceSDK'
    end
```
Save the file and run:

```
    pod install
```

This creates a .xcworkspace file for your application. Use this file for all future development on your application.


To support Swift 2.0 and IOS deployment target 7.0 add the following and run pod install:

target :YourTargetName do
pod 'IntelligenceSDK’, :git => 'https://git.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK.git', :branch => 'Swift-2.0'
end

#### Through Carthage ####

Here what you need to add to your Cartfile. For more [detail](https://git-apac.internal.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK/tree/Documentation/Examples/Carthage/Swift/Intelligence/ReadMe.md).

```
    binary "https://s3-ap-southeast-1.amazonaws.com/chethansp007.sample/IntelligenceFramework.json" ~> 1.0
```

If you're new to Carthage, check out their documentation first.


#### Manual Integration ####

Integrating the Intelligence SDK through [Framework](https://git-apac.internal.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK/blob/Documentation/Examples/Through_Framework/Swift/Intelligence/ReadMe.md)(Manual Integration).

1.    Download the Intelligence framework from the [Github](https://github.com/tigerspike/Intelligence-iOS-Framework/blob/master/SDK).

2.    Drag and drop the Intelligence framework into your project, as shown in part-1.
![Linked Frameworks and Libraries](Images/Framework-Link.png)

3. Include the Intelligence framework in Embedded Binaries as shown in part-2.
![Linked Frameworks and Libraries](Images/Framework-Link.png)


## Import SDK ##

Next, import the IntelligenceSDK framework.

*Swift:*

```
#!swift
import IntelligenceSDK
```

*Objective-C:*

```
#!objc
@import IntelligenceSDK;

```

## Create & Configure your Account ##

Before using the SDK you need a Intelligence account. If you do not have an Intelligence account please reach out to intelligence.support@tigerspike.com. For Tigerspiker please reach out [here](https://sites.google.com/tigerspike.com/intelligence/join-in?authuser=1).


## Configuration JSON File ##

IntellignceSDK require cconfiguration JSON file for each project.
All of these variables come from the Intelligence Platform and will need to be included in a JSON file bundled with your iOS App:

1. "client_secret" (String): Only provided when you create a New Application, if you do not know this value you will need to get in contact with the Intelligence Platform team(intelligence.support@tigerspike.com).
3. "client_id" (String): Can be found on your configured Application.
2. "application_id" (Integer): Can be found on your configured Application.
4. "project_id" (Integer): Can be seen in the URL when you're on the Dashboard.

As an example, your configuration file should look something like:

```
#!JSON

{
"client_id": "CLIENT_ID",
"client_secret": "CLIENT_SECRET",
"application_id": 10,
"project_id": 20    
}

```

## Initialization ##

The Intelligence SDK requires a delegate and configuration variables in order to initialize itself. The delegate will be called in cases where the SDK is incapable of continuing in a particular state, such as requesting that the user must login again.


**There are a few different ways of providing configuration to the SDK:**

1- Initialize Intelligence with a configuration file:

*Swift:*

```
#!swift

do {
intelligence = try Intelligence(withDelegate: self, file: "IntelligenceConfiguration")
}
catch {
// Treat the error with care!
}

```

*Objective-C:*

```
#!objc

// Attempt to instantiate Intelligence using a JSON file.
NSError *err;
Intelligence *intelligence = [[Intelligence alloc] initWithDelegate: self file:@"IntelligenceConfiguration" inBundle:[NSBundle mainBundle] error:&err];
if (nil != err) {
// Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
// and generally indicate that something has gone wrong and needs to be resolved.
NSLog(@"Error initialising Intelligence: %zd", err.code);
}
NSParameterAssert(err == nil && intelligence != nil);

```


2- Initialize a configuration object, read a file and pass it to Intelligence:

*Swift:*

```
#!swift

do {
let configuration = try Intelligence.Configuration(fromFile: "IntelligenceConfiguration")
intelligence = try Intelligence(withDelegate: self, configuration: configuration)
}
catch {
// Treat the error with care!
}

```

*Objective-C:*

```
#!objc

// Attempt to instantiate Intelligence using a JSON file.
NSError *err;
INTConfiguration *configuration = [[INTConfiguration alloc] initFromFile:@"IntelligenceConfiguration" inBundle:[NSBundle mainBundle] error:&err];
Intelligence *intelligence = [[Intelligence alloc] initWithDelegate: self configuration:configuration error:&err];
if (nil != err) {
// Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
// and generally indicate that something has gone wrong and needs to be resolved.
NSLog(@"Error initialising Intelligence: %zd", err.code);
}
NSParameterAssert(err == nil && intelligence != nil);

```

3- Programmatically set the required parameters in the configuration, and initialize Intelligence with it.

*Swift:*

```
#!swift

let configuration = Intelligence.Configuration()
configuration.clientID = "YOUR_CLIENT_ID"
configuration.clientSecret = "YOUR_CLIENT_SECRET"
configuration.projectID = 123456789
configuration.applicationID = 987654321

```
*Objective-C:*

```
#!objc

INTConfiguration *configuration = [[INTConfiguration alloc] init];
configuration.clientID = @"YOUR_CLIENT_ID";
configuration.clientSecret = @"YOUR_CLIENT_SECRET";
configuration.projectID = 123456789;
configuration.applicationID = 987654321;

```

## Startup ##

Importantly, the 'startup' method is responsible to bootstrap the SDK, without it, undefined behavior might occur, and thus it's the developer responsibility to call it before the SDK is used. It is suggested to do so right after the Intelligence object is initialised, but it can be deferred until a more convenient time. You will receive a 'success' flag in the completion block, if this returns false, something is probably incorrectly configured. You should receive an error from one of the IntelligenceDelegate methods.

*Swift:*
```
#!swift

// Startup all modules.
intelligence.startup { (success) -> () in               
// Startup succeeded if success is true.
}

```

*Objective-C:*

```
#!objc

// Startup the SDK...
[intelligence startup:^(BOOL success) {        
// Startup succeeded if success is true.
}];

```

## Shutdown ##

When your app is terminated you should call the shutdown method in order for the SDK to do any cleanup and store anything relevant to the next session.

*Swift:*
```
#!swift

func applicationWillTerminate(application: UIApplication) {
// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
IntelligenceManager.intelligence.shutdown()
}

```

*Objective-C:*

```
#!objc

- (void)applicationWillTerminate:(UIApplication *)application {
// Shutdown Intelligence in the applicationWillTerminate method so Intelligence has time
// to teardown properly.
[[INTIntelligenceManager intelligence] shutdown];
}

```



# Intelligence Modules #

The Intelligence SDK is composed of several modules which can be used as necessary by developers to perform specific functions. Each module is described below with sample code where necessary.

Note: Developers are responsible for ensuring the callbacks are executed on the correct thread, i.e. anything related to the UI will need to be dispatched on the main thread.

In addition to the errors specified by each individual module, you may also get one of the following errors if the request fails:

* RequestError.ParseError: Unable to parse the response of the call. The server is behaving unexpectedly, this is unrecoverable.
* RequestError.AccessDeniedError: Unable to call a particular method, your permissions on the Intelligence Platform are incorrectly configured. **Developer is responsible for fixing these issues.**
* RequestError.InternetOfflineError: Internet connectivity error, developer will need to wait until device has connected to the internet then try this request again.
* RequestError.Unauthorized: The credentials are not authenticated for this call.
* RequestError.Forbidden: The role provided is forbidden from accessing this call.
* RequestError.UnhandledError: The SDK could not handle this error. If the error came from the server an HTTP status code can be retrieved

These errors will be wrapped within an NSError.


## Analytics Module ##

The analytics module allows developers to effortlessly track several predefined events or their own custom events which can be used to determine user engagement and behavioral insights.

Tracking an event is as simple as accessing the track method on the analytics module, once you have initialised Intelligence.

### Tracking Events ###

**How to track a Custom Event:**

*Swift:*
Note: there are some optional fields in Swift that default to zero/nil if missing.

```
#!swift

// Create custom Event
let myTestEvent = Intelligence.Event(withType: "Intelligence.Test.Event.Type")

// Send event to Analytics module
intelligence.analytics.track(myTestEvent)

```

*Objective-C:*
```
#!objc

// Create custom Event
INTEvent *myTestEvent = [[INTEvent alloc] initWithType:@"Intelligence.Test.Event.Type" value:1.0 targetId:5 metadata:nil];

// Send event to Analytics module
[intelligence.analytics track:myTestEvent];

```

**How to track a Screen View Event:**

*Swift:*

```
#!swift

// Duration is in seconds and can include fractional seconds
intelligence.analytics.trackScreenViewed("Main Screen", viewingDuration: 5)
```

*Objective-C:*

```
#!objc

// Duration is in seconds and can include fractional seconds
[intelligence.analytics trackScreenViewedWithScreenName:@"Main Screen", viewingDuration: 5];

```



### Pause/Resume Tracking ###

Developers are responsible for calling the **pause** and **resume** methods when the app enters the background and foreground respectively. This will cause unexpected results if these methods are not called and skew the analytics gathered by Intelligence. 

*Swift:*
```
#!swift

func applicationDidEnterBackground(application: UIApplication) {
IntelligenceManager.intelligence.analytics.pause()
}

func applicationWillEnterForeground(application: UIApplication) {
IntelligenceManager.intelligence.analytics.resume()
}
```

*Objective-C:*
```
#!objc

- (void)applicationDidEnterBackground:(UIApplication *)application {
[[[INTIntelligenceManager intelligence] analytics] pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
[[[INTIntelligenceManager intelligence] analytics] resume];
}

```

## Identity Module ##

This module provides methods for user management within the Intelligence platform. Allowing users to register, login, and retrieve information.

*NOTE:* The below methods will either return a User object or an Error object (not both) depending on whether the request was successful.

### Login ###

If you have a registered account on the Intelligence platform you will be able to login to that account using the 'login' method:

*Swift:*
```
#!swift

intelligence.identity.login(withUsername: username, password: password, callback: { (user, error) -> () in
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
})

```

*Objective-C:*

```
#!objc

[intelligence.identity loginWithUsername:username password:password callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}];

```

### Logout ###

Once you are logged in, you may want to give a user the ability to logout in which case you can call the 'logout' method:

*Swift:*
```
#!swift

intelligence.identity.logout()

```


*Objective-C:*

```

[intelligence.identity logout];

```

### Get Me ###

Request the latest information for the logged in user, developer is responsible for calling this only after a login has succeeded. This is automatically called by the SDK on login to return the state at that point in time, but the user may be modified in the backend so it's important to call it before calling the 'Update User' method to ensure you have the latest details.

The following code snippets illustrate how to request a user's information in Objective-C and Swift.

*Swift:*


```
#!swift

intelligence.identity.getMe { (user, error) -> Void in
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}


```

*Objective-C:*

```
#!objc

[intelligence getMeWithCallback:^(INTUser * _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}];


```


### Register Device Token ###

As a developer, you are responsible for managing the push notification token, if your app supports login you should register the device token after login succeeds. However, if your app doesn't have login/logout functionality you should register after startup has succeeded. You should also manage whether or not you have previously registered this device token since you would not want to send it multiple times.

An example of how to request the push notification token from Apple:
```
#!swift

let application = UIApplication.sharedApplication()
application.registerForRemoteNotifications()
application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))

```

Here is an example of how to respond to the delegate method 'didRegisterForRemoteNotificationsWithDeviceToken':

*Swift:*
```
#!swift


func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
IntelligenceManager.intelligence.identity.registerDeviceToken(deviceToken) { (tokenId, error) -> Void in
if error != nil {
// Failed, handle error.
} else {
// Successful! Store tokenId in Keychain you will need the Id in order to unregister.
}
}
}

```

*Objective-C:*
```
#!objc

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
[[[INTIntelligenceManager intelligence] identity] registerDeviceToken:deviceToken callback:^(NSInteger tokenId, NSError * _Nullable error) {
if (error != nil) {
// Failed, handle error.
} else {
// Successful! Store tokenId in Keychain you will need the Id in order to unregister.
}
}];
}


```

The 'registerDeviceToken' method can return the following additional errors:

* IdentityError.DeviceTokenInvalidError: Invalid device token provided.

### Unregister Device Token ###

The developer is responsible for unregistering device tokens, they can only be assigned to one user at a time, so if you forget to unregister from the previous user you will continue receiving push notifications meant for another user. In order to unregister, you will need to store the tokenId returned by the 'registerDeviceToken' method then send this before logging out. If your app does not implement the login/logout functionality you will most likely never need to call this method.

*Swift:*
```
#!swift

IntelligenceManager.intelligence.identity.unregisterDeviceToken(withId: id, callback: { (error) -> Void in
if error != nil {
// Failed, handle error.
} else {
// Successfully unregistered, clear anything stored in the keychain.
}
})

```

*Objective-C:*
```
#!objc

[[[INTIntelligenceManager intelligence] identity] unregisterDeviceTokenWithId:tokenId callback:^(NSError * _Nullable error) {
if (error != nil) {
// Failed, handle error.
} else {
// Successfully unregistered, clear anything stored in the keychain.
}
}];

```

The 'unregisterDeviceTokenWithId' method can return the following additional errors:

* IdentityError.DeviceTokenNotRegisteredError: Device token is not registered in Intelligence platform. You will receive this error if you try to unregister a token twice, you should handle this as though it was a successful request.