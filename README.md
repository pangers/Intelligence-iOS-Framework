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
*Objective-C:*

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
* RequestError.InternetOfflineError: Internet connectivity error, developer will need to wait until device has connected to the internet then try this request again.
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

#### Register Device Token ####

As a developer you are responsible for managing the push notification token, if your app supports login you should register the device token after login succeeds. However if your app doesn't have login/logout functionality you should register after startup has succeeded.

In order to request the push notification token from Apple, you will need to call the following:
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
        PhoenixManager.phoenix.identity.registerDeviceToken(deviceToken) { (tokenId, error) -> Void in
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
    [[[PHXPhoenixManager phoenix] identity] registerDeviceToken:deviceToken callback:^(NSInteger tokenId, NSError * _Nullable error) {
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
* IdentityError.DeviceTokenRegistrationError: An error occured while registering the token in the Phoenix platform.
* IdentityError.DeviceTokenAlreadyRegisteredError: Device token has already been registered by you or someone else, you should unregister from that user before trying to register again.


#### Unregister Device Token ####

The developer is responsible for unregistering device tokens, they can only be assigned to one user at a time, so if you forget to unregister from the previous user you will continue receiving push notifications meant for another user. In order to unregister you will need to store the tokenId returned by the 'registerDeviceToken' method then send this before logging out. If your app does not implement the login/logout functionality you will most likely never need to call this method.

*Swift:*
```
#!swift

PhoenixManager.phoenix.identity.unregisterDeviceToken(withId: id, callback: { (error) -> Void in
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

[[[PHXPhoenixManager phoenix] identity] unregisterDeviceTokenWithId:tokenId callback:^(NSError * _Nullable error) {
    if (error != nil) {
        // Failed, handle error.
    } else {
        // Successfully unregistered, clear anything stored in the keychain.
    }
}];

```

The 'unregisterDeviceTokenWithId' method can return the follow additional errors:

* IdentityError.DeviceTokenUnregistrationError: Unable to unregister token in Phoenix platform.


## Location Module ##

The location module is responsible for managing a user's location in order to track entering/exiting geofences and add this information to analytics events. 

Developers will need to request location permissions in order to use this module by adding the 'NSLocationAlwaysUsageDescription' to the Info.plist of their app.

Furthermore, you will need to manage the request for permissions by implementing the following code:

*Swift:*

```
#!swift

// Request location access.
if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
    locationManager.requestAlwaysAuthorization()
}

```

*Objective-C:*

```
#!objc

if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
    [self.locationManager requestAlwaysAuthorization];
}

```


