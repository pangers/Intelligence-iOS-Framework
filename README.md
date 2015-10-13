# Phoenix SDK #
```
== Configuration values for the "Phoenix SDK Test Project" (https://dashboard.phoenixplatform.eu/) ==
!! these values should be deleted from the app once the codebase goes public !!

Region: EU (https://api.phoenixplatform.eu)
API Version: v1
Company Id: 3
Project Id: 2030

Application Id (iOS): 3152
Client Id (iOS): iOSSDKApp_napmxilutp
Client Secret (iOS): Z4D1eCGO65pi45y5dewrmrgenndrfnzarnzdilrl

Application Id (Android): 4154
Client Id (Android): AndroidSDKApp_kypopf
Client Secret (Android): OCN20qleymuqjlqbfcwbcwnjdwphdgoxpocrpxvp
```

The goal of this SDK is to encapsulate in a developer-friendly manner the Phoenix platform's API's.

## Getting Started ##

In this section we detail how to get up and running with the SDK for both Objective-C and Swift based projects.

### Initialising Phoenix ###

First of all, create a new Workspace to embed both your project and the PhoenixSDK framework project.

Once you get a workspace with both projects coexisting in it, add the SDK in the list of Linked Frameworks and Libraries so that it is accessible from your own project:

![Linked Frameworks and Libraries](https://bitbucket.org/repo/4z6Eb8/images/3275432151-Screen%20Shot%202015-07-22%20at%2017.55.51.png)

Next, import the PhoenixSDK framework.

*Swift:*
```
#!swift

import PhoenixSDK

```

*Objective-C:*
```
#!objc
@import PhoenixSDK;
```

### Configuration ###

The Phoenix SDK requires a delegate and configuration variables in order to initialize itself. The delegate will be called in cases where the SDK is incapable of continuing in a particular state, such as requesting that the user must login again.


**There are a few different ways of providing configuration to the SDK:**

1- Initialize Phoenix with a configuration file:

*Swift:*

```
#!swift

do {
    phoenix = try Phoenix(withDelegate: self, file: "PhoenixConfiguration")
}
catch {
    // Treat the error with care!
}

```

*Objective-C:*

```
#!objc

// Attempt to instantiate Phoenix using a JSON file.
NSError *err;
Phoenix *phoenix = [[Phoenix alloc] initWithDelegate: self, file:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
if (nil != err) {
	// Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
	// and generally indicate that something has gone wrong and needs to be resolved.
	NSLog(@"Error initialising Phoenix: %zd", err.code);
}
NSParameterAssert(err == nil && instance != nil);

```


2- Initialize a configuration object, read a file and pass it to Phoenix:

*Swift:*

```
#!swift

do {
	let configuration = try Phoenix.Configuration(fromFile: "PhoenixConfiguration")
	phoenix = try Phoenix(withDelegate: self, configuration: configuration)
}
catch {
	// Treat the error with care!
}

```

*Objective-C:*

```
#!objc

// Attempt to instantiate Phoenix using a JSON file.
NSError *err;
PHXConfiguration *configuration = [[PHXConfiguration alloc] initFromFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
Phoenix *phoenix = [[Phoenix alloc] initWithDelegate: self, configuration:configuration error:&err];
if (nil != err) {
	// Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
	// and generally indicate that something has gone wrong and needs to be resolved.
	NSLog(@"Error initialising Phoenix: %zd", err.code);
}
NSParameterAssert(err == nil && instance != nil);
        
```

3- Programmatically set the required parameters in the configuration, and initialize Phoenix with it.

*Swift:*

```
#!swift

let configuration = Phoenix.Configuration()
configuration.clientID = "YOUR_CLIENT_ID"
configuration.clientSecret = "YOUR_CLIENT_SECRET"
configuration.projectID = 123456789
configuration.applicationID = 987654321
configuration.region = Phoenix.Region.Europe
configuration.sdk_user_role = 1000

```
*Objective-C:**

```
#!objc

PHXConfiguration *configuration = [[PHXConfiguration alloc] init];
configuration.clientID = @"YOUR_CLIENT_ID";
configuration.clientSecret = @"YOUR_CLIENT_SECRET";
configuration.projectID = 123456789;
configuration.applicationID = 987654321;
configuration.region = RegionEurope;                
configuration.sdk_user_role = 1000;
        

```



4- Hybrid initialization of the configuration file, reading a file and customizing programmatically some of its properties:

*Swift:*

```
#!swift

do {
	// Load from file
	let configuration = try Phoenix.Configuration(fromFile: "config")
            
	// Change region programmatically
	configuration.region = Phoenix.Region.Europe
            
	// Instantiate with hybrid configuration
	phoenix = try Phoenix(withDelegate: self, configuration: configuration)
}
catch {
	// Treat the error with care!
}

```

*Objective-C:*

```
#!objc

// Attempt to instantiate Phoenix using a JSON file.
NSError *err;
PHXConfiguration *configuration = [[PHXConfiguration alloc] initFromFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
        
// Change region programmatically
configuration.region = RegionEurope;
        
Phoenix *phoenix = [[Phoenix alloc] initWithDelegate: self, configuration:configuration error:&err];
if (nil != err) {
	// Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
	// and generally indicate that something has gone wrong and needs to be resolved.
	NSLog(@"Error initialising Phoenix: %zd", err.code);
}
NSParameterAssert(err == nil && instance != nil);
        

```


Consider that the Phoenix.Configuration can throw exceptions if you haven't configured properly your setup. Please refer to the class documentation for further information on what kind of errors it can throw.

Also, check the Phoenix.Configuration and Phoenix classes to learn about more initializers available for you.

### Configuration file format ###

The configuration file is a JSON file with the following keys:

1. "client_id" with a String value
2. "client_secret" with a String value
3. "application_id" with an Integer value
4. "project_id" with an Integer value
5. "region" with a String value which needs to be one of: "US","EU","AU" or "SG"
6. "sdk_user_role" an Integer value which needs to be configured in the Phoenix Intelligence platform with the correct rights in order to use this SDK.

As an example, your configuration file will look like:

```
#!JSON

{
    "client_id": "CLIENT_ID",
    "client_secret": "CLIENT_SECRET",
    "application_id": 10,
    "project_id": 20,
    "region": "EU",
    "company_id" : 10,
    "sdk_user_role" : 1000
}

```

### Startup ###

Importantly, the 'startup' method is responsible to bootstrap the SDK, without it, undefined behaviour might occur, and thus it's the developer responsibility to call it before the SDK is used. It is suggested to do so right after the Phoenix object is initialised, but it can be deferred until a more convenient time. You will receive a 'success' flag in the completion block, if this returns false, something is probably incorrectly configured. You should receive an error from one of the PhoenixDelegate methods.

*Swift:*
```
#!swift
        
// Startup all modules.
phoenix.startup { (success) -> () in               
	// Startup succeeded if success is true.
}

```

*Objective-C:*

```
#!objc

// Startup the SDK...
[phoenix startup:^(BOOL success) {        
	// Startup succeeded if success is true.
}];
        
```


# Phoenix Modules #

The Phoenix SDK is composed of several modules which can be used as necessary by developers to perform specific functions. Each module is described below with sample code where necessary.

Note: Developers are responsible for ensuring the callbacks are executed on the correct thread, i.e. anything related to the UI will need to be dispatched on the main thread.

In addition to the errors specified by each individual module, you may also get one of the following errors if the request fails:

* RequestError.AccessDeniedError: Unable to call particular method, your permissions on the Phoenix Platform are incorrectly configured. **Developer is responsible to fix these issues.**
* RequestError.ParseError: Unable to parse the response of the call. Server is behaving unexpectedly, this is unrecoverable.

These errors will be wrapped within an NSError using as domain RequestError.domain.


## Analytics Module ##

The analytics module allows developers to effortlessly track several predefined events or their own custom events which can be used to determine user engagement and behavioural insights.

Tracking an event is as simple as accessing the track method on the analytics module, once you have initialised Phoenix.

**How to track a Custom Event:**

*Swift:*
Note: there are some optional fields in Swift that default to zero/nil if missing.

```
#!swift

// Create custom Event
let myTestEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")

// Send event to Analytics module
phoenix.analytics.track(myTestEvent)

```

*Objective-C:*
```
#!objc

// Create custom Event
PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:5 metadata:nil];

// Send event to Analytics module
[phoenix.analytics track:myTestEvent];

```

**How to track a Screen View Event:**

*Swift:*

```
#!swift

// Duration is in seconds and can include fractional seconds
phoenix.analytics.trackScreenViewed("Main Screen", viewingDuration: 5)
```

*Objective-C:*

```
#!objc

// Duration is in seconds and can include fractional seconds
[phoenix.analytics trackScreenViewedWithScreenName:@"Main Screen", viewingDuration: 5];

```


## Identity Module ##

This module provides methods for user management within the Phoenix platform. Allowing users to register, login, update, and retrieve information.

*NOTE:* The below methods will either return a User object or an Error object (not both) depending on whether the request was successful.

#### Login ####

If you have a registered account on the Phoenix platform you will be able to login to that account using the 'login' method:

*Swift:*
```
#!swift

phoenix.identity.login(withUsername: username, password: password, callback: { (user, error) -> () in
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
})

```

*Objective-C:*

```
#!objc

[phoenix.identity loginWithUsername:username password:password callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
}];

```

The 'login' method can return the following additional errors:

* IdentityError.LoginFailed: There was an issue that occurred during login, could be due to incorrect credentials.


#### Logout ####

Once you are logged in, you may want to give a user the ability to logout in which case you can call the 'logout' method:

*Swift:*
```
#!swift

phoenix.identity.logout()

```


*Objective-C:*

```

[phoenix.identity logout];

```




#### Get Me ####

Request the latest information for the logged in user, developer is responsible for calling this only after a login has succeeded. This is automatically called by the SDK on login to return the state at that point in time, but the user may be modified in the backend so it's important to call it before calling the 'Update User' method to ensure you have the latest details.

The following code snippets illustrate how to request a user's information in Objective-C and Swift.

*Swift:*


```
#!swift

phoenix.identity.getMe { (user, error) -> Void in
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
}


```

*Objective-C:*

```
#!objc

[phoenix getMeWithCallback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
}];


```

The 'getMe' method can return the following additional errors:

* IdentityError.GetUserError : When there is an error while retrieving the user from the Phoenix platform, or no user is retrieved.


#### Update User ####

The code to update a user for each language is as follows:

*Swift:*


```
#!swift
let user = Phoenix.User(userId: userId, companyId: companyId, username: usernameTxt,password: passwordTxt,
firstName: firstNameTxt, lastName: lastNameTxt, avatarURL: avatarURLTxt)

phoenix.identity.updateUser(user, callback: { (user, error) -> Void in
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
})
```

*Objective-C:*

```
#!objc

PHXUser* user = [[PHXUser alloc] initWithUserId:userID companyId:companyID username:username password:password
firstName:firstname lastName:lastname avatarURL:avatarURL];

[phoenix.identity updateUser:user callback:^(id<PHXUser> _Nullable user, NSError * _Nullable error) {
	// Treat the user and error appropriately. Notice that the callback might be performed
	// in a background thread. Use dispatch_async to handle it in the main thread.
}];

```

The 'updateUser' method can return the following additional errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.UserUpdateError : When there is an error while updating the user in the platform. This contains network errors and possible errors generated in the backend.
* IdentityError.WeakPasswordError : When the password provided does not meet Phoenix security requirements. The requirements are that your password needs to have at least 8 characters, containing a number, a lowercase letter and an uppercase letter.


## Location Module ##

The location module is responsible for managing a user's location in order to track entering/exiting geofences and add this information to analytics events. 

Developers are responsible to decide when is the most suitable time to start fetching geofences and monitoring the user, and also will need to request location permissions in order to be able to track the user's location by either adding the 'NSLocationAlwaysUsageDescription' or the 'NSLocationWhenInUseUsageDescription' to the Info.plist of their app. You can find documentation on those keys in https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW18.

In order to obtain permissions to track the user's location, follow Apple's documentation in:

https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/doc/uid/TP40007125-CH3-SW62

The location module is available via the location property in the Phoenix object.

### Download geofences ###

The first step before tracking a user is to obtain a list of Geofences created in the Phoenix Dashboard.

To do so, you'll have to provide a GeofenceQuery object defining how you want to retrieve the geofences. The query can take the following parameters:

* **longitude: Double**. The latitude to calculate the distance from. Must be provided.
    
* **latitude: Double**. The longitude to calculate the distance to. Must be provided.
    
* **sortingDirection: GeofenceSortDirection**. Ascending or Descending. **Defaults to Ascending**
    
* **sortingCriteria: GeofenceSortCriteria?**. Sets how the geofences should be sorted. The available options are Distance, Id and Name. **Defaults to Distance**
    
* **radius: Double?**. The radius to filter geofences from.
    
* **pageSize: Int?**. The number of geofences per page loaded.
    
* **pageNumber: Int?**. The page to load.

The next sample code shows how to initialize a sample query:

*Swift:*

```
#!swift

let query = GeofenceQuery(location: PhoenixCoordinate(withLatitude: 42, longitude: 2))
query.radius = 1000
query.pageSize = 10
query.pageNumber = 0
query.sortingDirection = .Ascending
query.sortingCriteria = .Distance

```

*Objective-C:*

```
#!objc

PHXCoordinate* coordinate = [[PHXCoordinate alloc] initWithLatitude:42
                                                          longitude:2];

PHXGeofenceQuery* query = [[PHXGeofenceQuery alloc] initWithLocation:coordinate];
[query setRadius:1000];
[query setPage:1];
[query setPageSize:10];
[query setSortingDirection:GeofenceSortDirectionAscending];
[query setSortingCriteria:GeofenceSortCriteriaDistance];

```

Once the Geofence query is created and configured, you can retrieve the geofences you need by using the following snippet:

*Swift:*

```
#!swift
let phoenix:Phoenix = ...
phoenix.location.downloadGeofences(geofenceQuery) { [weak self] (geofences, error) in
    // Geofences loaded!
}


```

*Objective-C:*

```
#!objc

Phoenix* phoenix = ...;
[phoenix.location downloadGeofences:query callback:^(NSArray<PHXGeofence *>* _Nullable geofences, NSError*  _Nullable error) {
     // Geofences loaded!
    
}];

```

### Start/Stop monitoring geofences ###

Once you have Geofences you could start tracking the user's location and be notified of when a user enters or exits a given Geofence.

When tracking a user's location, you have to keep in mind:

* Privacy concerns.
* Battery usage.
* What value the user will receive when sacrificing the previous two.
* When to stop tracking the user's location.

The Phoenix SDK **won't** perform any tracking by default, since the developer is responsible to decide when is the best time to track the user for the user's benefit. For some apps, this will mean immediately after launching the app until it gets killed, for others it will be only when the user is performing a given action.

Once all this is considered, and it has been decided when to start and stop tracking the user's location, you can start and stop the tracking by using the following code snippets:

*Swift:*

```
#!swift

// Start monitoring
let geofences:[Geofence] = ...

phoenix.location.startMonitoringGeofences(geofences)

...

// Stop monitoring
phoenix.location.stopMonitoringGeofences()


```

*Objective-C:*

```
#!objc

// Start monitoring
NSArray<PHXGeofence*>* geofences = ...;
[phoenix.location startMonitoringGeofences:geofences];

...

// Stop monitoring
[phoenix.location stopMonitoringGeofences];

```

Notice that when you start monitoring a given set of geofences, you'll stop monitoring the previous monitored geofences. Also, bear in mind that iOS has a limit of simultaneous geofences that you can be tracking at a time (20). If your app requires the use of several geofences, consider downloading more geofences when the user's location changes or every once in a while. However, this techniques come at an expense of battery and data draining for the user.

#### Listen for location events ####

Given that you have started monitoring the use location, your app will probably want to be aware of when a user enters or leaves a geofence.

The location module provides a locationDelegate so you can be notified of events. The following snippet displays an example implementation and how to set your object as delegate. All methods in the PhoenixLocationDelegate protocol are optional, and thus you may only implement those that you need.

*Swift:*

```
#!swift

phoenix.location.locationDelegate = self
        
func phoenixLocation(location:PhoenixLocation, didEnterGeofence geofence:Geofence) {
	print("Did enter a geofence")
}

func phoenixLocation(location:PhoenixLocation, didExitGeofence geofence:Geofence) {
	print("Did exit a geofence")
}
    
func phoenixLocation(location:PhoenixLocation, didStartMonitoringGeofence:Geofence) {
	print("Did start monitoring a given geofence")
}

func phoenixLocation(location:PhoenixLocation, didFailMonitoringGeofence:Geofence) {
	print("Did fail the monitoring of a geofence. This can occur when the user has not allowed your app to track its location or when the maximum number of geofences are already being tracked.")
}

func phoenixLocation(location:PhoenixLocation, didStopMonitoringGeofence:Geofence) {
	print("Did stop monitoring a geofence")
}


```

*Objective-C:*

```
#!objc

phoenix.location.locationDelegate = self;

-(void)phoenixLocation:(id<PHXLocation>)location didEnterGeofence:(PHXGeofence *)geofence {
	NSLog(@"Did enter a geofence");
}

-(void)phoenixLocation:(id<PHXLocation>)location didExitGeofence:(PHXGeofence *)geofence {
	NSLog(@"Did exit a geofence");
}

-(void)phoenixLocation:(id<PHXLocation>)location didStartMonitoringGeofence:(PHXGeofence *)geofence {
	NSLog(@"Did start monitoring a given geofence");
}

-(void)phoenixLocation:(id<PHXLocation>)location didFailMonitoringGeofence:(PHXGeofence *)geofence {
	NSLog(@"Did fail the monitoring of a geofence. This can occur when the user has not allowed your app to track its location or when the maximum number of geofences are already being tracked.");
}

-(void)phoenixLocation:(id<PHXLocation>)location didStopMonitoringGeofence:(PHXGeofence *)geofence {
	NSLog(@"Did stop monitoring a geofence");
}

```

#### Configuring monitoring accuracy ####

Getting the user location is one of the most battery consuming action a mobile phone can perform. This can be alleviated by reducing the accuracy you use when getting the user position. This comes at the expense of missing some events or having false positives.

When considering the accuracy to use, you have to consider what kind of regions are you working with. If your geofences represent a big region (a city, a country, 10km...) then you'll probably be fine with a lower accuracy.

If, however, your geofences represent a small region (a street, a shop, 100m...) then you'll need to increase the accuracy in order to get a granular enough location to allow CoreLocation to detect the user entered the region.

As a final note, consider checking the minimum radius of the geofences you are about to monitor and to set the location accuracy based on that.

*Swift:*

```
#!swift

phoenix.location.setLocationAccuracy(kCLLocationAccuracyBest)


```

*Objective-C:*

```
#!objc

[phoenix.location setLocationAccuracy:kCLLocationAccuracyBest];

```