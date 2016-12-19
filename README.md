# Intelligence SDK #

The goal of this SDK is to encapsulate in a developer-friendly manner the Intelligence platform's API's.

# Getting Started #

# Importing SDK #

#### For Cocoapods project ####

For Cocoapods project Intelligence SDK uses private CocoaPods to install and manage dependencies. Open a terminal window and navigate to the location of the Xcode project for your application. If you have not already created a Podfile for your application, create one now:

    pod init

Open the Podfile created for your application and add the following:

    pod 'IntelligenceSDK', :git => 'https://git.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK.git
    
Save the file and run:
    
    pod install
        
This creates an .xcworkspace file for your application. Use this file for all future development on your application.

To support Swift 2.0 and IOS deployment target 7.0 add the following amd run pod install:
    
    pod 'IntelligenceSDK’, :git => 'https://git.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK.git', :branch => 'Swift-2.0'


#### For Non-Cocoapods project ####

Create a new Workspace to embed both your project and the IntelligenceSDK framework project. If your project already have Workspace,add IntelligenceSDK framework project into your workspace.

Once you get a workspace with both projects coexisting in it, add the SDK in the list of Linked Frameworks and Libraries so that it is accessible from your own project:

![Linked Frameworks and Libraries](https://bitbucket.org/repo/4z6Eb8/images/3275432151-Screen%20Shot%202015-07-22%20at%2017.55.51.png)

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

Before using the SDK you will need a Intelligence account. Instructions for creating and configuring this account can be found in [Intelligence - Getting Started](http://tgrs.pk/m9lq5).

## Configuration JSON File ##

All of these variables come from the Intelligence Platform and will need to be included in a JSON file bundled with your iOS App:

1. "client_secret" (String): Only provided when you create a New Application, if you do not know this value you will need to get in contact with the Intelligence Platform team.
3. "client_id" (String): Can be found on your configured Application.
2. "application_id" (Integer): Can be found on your configured Application.
4. "project_id" (Integer): Can be seen in the URL when you're on the Dashboard.
5. "region" (String): "US", "EU", "AU" or "SG"
6. "environment" (String): "local", "development", "integration", "uat", "staging" or "production"
7. "company_id" (Integer): Can be obtained from the Dashboard.
8. "sdk_user_role" (Integer): ID of SDK user role you have configured. This allows permission to use the SDK, so please ensure it is configured correctly.

As an example, your configuration file should look something like:

```
#!JSON

{
    "client_id": "CLIENT_ID",
    "client_secret": "CLIENT_SECRET",
    "application_id": 10,
    "project_id": 20,
    "region": "EU",
    "environment": "production",
    "company_id" : 10,
    "sdk_user_role" : 1000
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
configuration.region = Intelligence.Region.Europe
configuration.environment = Intelligence.Environment.Production
configuration.sdk_user_role = 1000

```
*Objective-C:*

```
#!objc

INTConfiguration *configuration = [[INTConfiguration alloc] init];
configuration.clientID = @"YOUR_CLIENT_ID";
configuration.clientSecret = @"YOUR_CLIENT_SECRET";
configuration.projectID = 123456789;
configuration.applicationID = 987654321;
configuration.region = RegionEurope;                
configuration.environment = EnvironmentProduction;
configuration.sdk_user_role = 1000;
        

```



4- Hybrid initialization of the configuration file, reading a file and customizing programmatically some of its properties:

*Swift:*

```
#!swift

do {
	// Load from file
	let configuration = try Intelligence.Configuration(fromFile: "config")
            
	// Change region programmatically
	configuration.region = Intelligence.Region.Europe

    // Change environment programmatically
    configuration.environment = Intelligence.Environment.Production
            
	// Instantiate with hybrid configuration
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
        
// Change region programmatically
configuration.region = RegionEurope;

// Change environment programmatically
configuration.environment = EnvironmentProduction;
        
Intelligence *intelligence = [[Intelligence alloc] initWithDelegate: self configuration:configuration error:&err];
if (nil != err) {
	// Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
	// and generally indicate that something has gone wrong and needs to be resolved.
	NSLog(@"Error initialising Intelligence: %zd", err.code);
}
NSParameterAssert(err == nil && intelligence != nil);
        

```


Consider that the Intelligence.Configuration can throw exceptions if you haven't configured properly your setup. Please refer to the class documentation for further information on what kind of errors it can throw.

Also, check the Intelligence.Configuration and Intelligence classes to learn about more initializers available for you.


## Startup ##

Importantly, the 'startup' method is responsible to bootstrap the SDK, without it, undefined behaviour might occur, and thus it's the developer responsibility to call it before the SDK is used. It is suggested to do so right after the Intelligence object is initialised, but it can be deferred until a more convenient time. You will receive a 'success' flag in the completion block, if this returns false, something is probably incorrectly configured. You should receive an error from one of the IntelligenceDelegate methods.

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

When you app is terminated you should call the shutdown method in order for the SDK to do any cleanup and store anything relevant to the next session.

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

* RequestError.ParseError: Unable to parse the response of the call. Server is behaving unexpectedly, this is unrecoverable.
* RequestError.AccessDeniedError: Unable to call particular method, your permissions on the Intelligence Platform are incorrectly configured. **Developer is responsible to fix these issues.**
* RequestError.InternetOfflineError: Internet connectivity error, developer will need to wait until device has connected to the internet then try this request again.
* RequestError.Unauthorized: The credentials are not authenicaticated for this call.
* RequestError.Forbidden: The role provided is forbidden from accessing this call.
* RequestError.UnhandledError: The SDK could not handle this error. If the error came from the server an HTTP status code can be retrieved

These errors will be wrapped within an NSError.


## Analytics Module ##

The analytics module allows developers to effortlessly track several predefined events or their own custom events which can be used to determine user engagement and behavioural insights.

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

This module provides methods for user management within the Intelligence platform. Allowing users to register, login, update, and retrieve information.

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

### Get User ###

Request information for a specific user (by userId). The user calling this method must have a role with the permission to see other users.

The following code snippets illustrate how to request a user's information in Objective-C and Swift.

*Swift:*


```
#!swift

intelligence.identity.getUser(userId) { (user, error) -> Void in
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}


```

*Objective-C:*

```
#!objc

[intelligence getUser:userId callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}];


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

### Update User ###

The code to update a user for each language is as follows:

*Swift:*


```
#!swift
let user = Intelligence.User(userId: userId, companyId: companyId, username: usernameTxt,password: passwordTxt,
firstName: firstNameTxt, lastName: lastNameTxt, avatarURL: avatarURLTxt)

intelligence.identity.updateUser(user, callback: { (user, error) -> Void in
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
})
```

*Objective-C:*

```
#!objc

INTUser* user = [[INTUser alloc] initWithUserId:userID companyId:companyID username:username password:password
firstName:firstname lastName:lastname avatarURL:avatarURL];

[intelligence.identity updateUser:user callback:^(id<INTUser> _Nullable user, NSError * _Nullable error) {
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
}];

```

The 'updateUser' method can return the following additional errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.WeakPasswordError : When the password provided does not meet Intelligence security requirements. The requirements are that your password needs to have at least 8 characters, containing a number, a lowercase letter and an uppercase letter.

Please note that you can not update the 'username' or the 'password' of a user

### Register Device Token ###

As a developer you are responsible for managing the push notification token, if your app supports login you should register the device token after login succeeds. However if your app doesn't have login/logout functionality you should register after startup has succeeded. You should also manage whether or not you have previously registered this device token, since you would not want to send it multiple times.

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

The developer is responsible for unregistering device tokens, they can only be assigned to one user at a time, so if you forget to unregister from the previous user you will continue receiving push notifications meant for another user. In order to unregister you will need to store the tokenId returned by the 'registerDeviceToken' method then send this before logging out. If your app does not implement the login/logout functionality you will most likely never need to call this method.

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

The 'unregisterDeviceTokenWithId' method can return the follow additional errors:

* IdentityError.DeviceTokenNotRegisteredError: Device token is not registered in Intelligence platform. You will receive this error if you try to unregister a token twice, you should handle this as though it was a successful request.

### Assign Role ###

A user can have multiple roles (and multiple of the same role) and it may be necessary to assign another from within the SDK.

*Swift:*
```
#!swift

IntelligenceManager.intelligence.identity.assignRole(roleId, user: user, callback: { (error) -> Void in
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
})

```

*Objective-C:*
```
#!objc

[[[INTIntelligenceManager intelligence] identity] assignRole:roleId user:user callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}];

```

### Revoke Role ###

A user can have multiple roles (and multiple of the same role) and it may be necessary to revoke these from within the SDK.

*Swift:*
```
#!swift

IntelligenceManager.intelligence.identity.revokeRole(roleId, user: user, callback: { (error) -> Void in
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
})

```

*Objective-C:*
```
#!objc

[[[INTIntelligenceManager intelligence] identity] revokeRole:roleId user:user callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// in a background thread. Use dispatch_async to handle it in the main thread.
}];

```

Note that revokeRole only revokes one copy of that role, so if a role has been assigned multiple times it will need to be revoked multiple times.

## Location Module ##

The location module is responsible for managing a user's location in order to track entering/exiting geofences and add this information to analytics events. 

Developers will need to request location permissions in order to use this module by adding the 'NSLocationAlwaysUsageDescription' to the Info.plist of their app.

Developers are responsible to decide when is the most suitable time to start fetching geofences and monitoring the user, and also will need to request location permissions in order to be able to track the user's location by either adding the *NSLocationAlwaysUsageDescription* or the *NSLocationWhenInUseUsageDescription* to the Info.plist of their app. You can find documentation on those keys in [Info Plist Key Reference](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW18).

In order to obtain permissions to track the user's location, follow Apple's documentation in:

[CLLocationManager Class Reference](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/doc/uid/TP40007125-CH3-SW62)

The location module is available via the location property in the Intelligence object.

### Download Geofences ###

The first step before tracking a user is to obtain a list of Geofences created in the Intelligence Dashboard.

To do so, you'll have to provide a GeofenceQuery object defining how you want to retrieve the geofences. The query can take the following parameters:

* **longitude: Double**. The latitude to calculate the distance from. Must be provided.
    
* **latitude: Double**. The longitude to calculate the distance to. Must be provided.
    
* **radius: Double?**. The radius (in meters) to filter geofences from. Must be provided.
    
* **pageSize: Int?**. The number of geofences per page loaded.
    
* **pageNumber: Int?**. The page to load (starting at 0).

The next sample code shows how to initialize a sample query:

*Swift:*

```
#!swift

let query = GeofenceQuery(location: Coordinate(withLatitude: 51.5200395, longitude: -0.1341359), radius: 40_075_000) // The circumference of the Earth
query.pageSize = 100
query.pageNumber = 0

```

*Objective-C:*

```
#!objc

INTCoordinate* coordinate = [[INTCoordinate alloc] initWithLatitude:51.5200395
                                                          longitude:-0.1341359];

INTGeofenceQuery* query = [[INTGeofenceQuery alloc] initWithLocation:coordinate radius:40075000]; // The circumference of the Earth
[query setPageSize:100];
[query setPage:0];

```

Once the Geofence query is created and configured, you can retrieve the geofences you need by using the following snippet:

*Swift:*

```
#!swift
let intelligence:Intelligence = ...
intelligence.location.downloadGeofences(geofenceQuery) { (geofences, error) in
    // Geofences loaded!
}


```

*Objective-C:*

```
#!objc

Intelligence* intelligence = ...;
[intelligence.location downloadGeofences:query callback:^(NSArray<INTGeofence *>* _Nullable geofences, NSError*  _Nullable error) {
     // Geofences loaded!
    
}];

```

### Start/Stop Monitoring Geofences ###

Once you have Geofences you could start tracking the user's location and be notified of when a user enters or exits a given Geofence.

When tracking a user's location, you have to keep in mind:

* Privacy concerns.
* Battery usage.
* What value the user will receive when sacrificing the previous two.
* When to stop tracking the user's location.

The Intelligence SDK **won't** perform any tracking by default, since the developer is responsible to decide when is the best time to track the user for the user's benefit. For some apps, this will mean immediately after launching the app until it gets killed, for others it will be only when the user is performing a given action.

Once all this is considered, and it has been decided when to start and stop tracking the user's location, you can start and stop the tracking by using the following code snippets:

*Swift:*

```
#!swift

// Start monitoring
let geofences:[Geofence] = ...

intelligence.location.startMonitoringGeofences(geofences)

...

// Stop monitoring
intelligence.location.stopMonitoringGeofences()


```

*Objective-C:*

```
#!objc

// Start monitoring
NSArray<INTGeofence*>* geofences = ...;
[intelligence.location startMonitoringGeofences:geofences];

...

// Stop monitoring
[intelligence.location stopMonitoringGeofences];

```

Notice that when you start monitoring a given set of geofences, you'll stop monitoring the previous monitored geofences. Also, bear in mind that iOS has a limit of simultaneous geofences that you can be tracking at a time (20). If your app requires the use of several geofences, consider downloading more geofences when the user's location changes or every once in a while. However, this techniques come at an expense of battery and data draining for the user.

#### Listen for Location Events ####

Given that you have started monitoring the use location, your app will probably want to be aware of when a user enters or leaves a geofence.

The location module provides a locationDelegate so you can be notified of events. The following snippet displays an example implementation and how to set your object as delegate. All methods in the IntelligenceLocationDelegate protocol are optional, and thus you may only implement those that you need.

*Swift:*

```
#!swift

intelligence.location.locationDelegate = self
        
func intelligenceLocation(location:IntelligenceLocation, didEnterGeofence geofence:Geofence) {
	print("Did enter a geofence")
}

func intelligenceLocation(location:IntelligenceLocation, didExitGeofence geofence:Geofence) {
	print("Did exit a geofence")
}
    
func intelligenceLocation(location:IntelligenceLocation, didStartMonitoringGeofence:Geofence) {
	print("Did start monitoring a given geofence")
}

func intelligenceLocation(location:IntelligenceLocation, didFailMonitoringGeofence:Geofence) {
	print("Did fail the monitoring of a geofence. This can occur when the user has not allowed your app to track its location or when the maximum number of geofences are already being tracked.")
}

func intelligenceLocation(location:IntelligenceLocation, didStopMonitoringGeofence:Geofence) {
	print("Did stop monitoring a geofence")
}


```

*Objective-C:*

```
#!objc

intelligence.location.locationDelegate = self;

-(void)intelligenceLocation:(id<INTLocation>)location didEnterGeofence:(INTGeofence *)geofence {
	NSLog(@"Did enter a geofence");
}

-(void)intelligenceLocation:(id<INTLocation>)location didExitGeofence:(INTGeofence *)geofence {
	NSLog(@"Did exit a geofence");
}

-(void)intelligenceLocation:(id<INTLocation>)location didStartMonitoringGeofence:(INTGeofence *)geofence {
	NSLog(@"Did start monitoring a given geofence");
}

-(void)intelligenceLocation:(id<INTLocation>)location didFailMonitoringGeofence:(INTGeofence *)geofence {
	NSLog(@"Did fail the monitoring of a geofence. This can occur when the user has not allowed your app to track its location or when the maximum number of geofences are already being tracked.");
}

-(void)intelligenceLocation:(id<INTLocation>)location didStopMonitoringGeofence:(INTGeofence *)geofence {
	NSLog(@"Did stop monitoring a geofence");
}

```

#### Configuring Monitoring Accuracy ####

Getting the user location is one of the most battery consuming action a mobile phone can perform. This can be alleviated by reducing the accuracy you use when getting the user position. This comes at the expense of missing some events or having false positives.

When considering the accuracy to use, you have to consider what kind of regions are you working with. If your geofences represent a big region (a city, a country, 10km...) then you'll probably be fine with a lower accuracy.

If, however, your geofences represent a small region (a street, a shop, 100m...) then you'll need to increase the accuracy in order to get a granular enough location to allow CoreLocation to detect the user entered the region.

As a final note, consider checking the minimum radius of the geofences you are about to monitor and to set the location accuracy based on that.

*Swift:*

```
#!swift

intelligence.location.setLocationAccuracy(kCLLocationAccuracyBest)


```

*Objective-C:*

```
#!objc

[intelligence.location setLocationAccuracy:kCLLocationAccuracyBest];

```