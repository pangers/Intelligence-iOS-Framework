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

The Phoenix SDK requires a few configuration properties in order to initialize itself. There are a few different ways of creating the configuration:

1- Initialize Phoenix with a configuration file:

*Swift:*

```
#!swift

        do {
            phoenix = try Phoenix(withFile: "PhoenixConfiguration")
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
        Phoenix *phoenix = [[Phoenix alloc] initWithFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
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
            phoenix = try Phoenix(withConfiguration: configuration)
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
        Phoenix *phoenix = [[Phoenix alloc] initWithConfiguration:configuration error:&err];
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
        configuration.useGeofences = true

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
        configuration.useGeofences = YES;
        

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
            phoenix = try Phoenix(withConfiguration: configuration)
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
        
        Phoenix *phoenix = [[Phoenix alloc] initWithConfiguration:configuration error:&err];
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
6. "use_geofences" a Boolean value which needs to be true or false - this is an optional configuration, if not specified, the default value is true. Setting this value to false means the SDK will not attempt to download existing geofence data and use it to monitor geofences.

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
    "use_geofences" : true
}

```

### Startup ###

Importantly, the 'startup' method is responsible to bootstrap the SDK, without it, undefined behaviour might occur, and thus it's the developer responsibility to call it before the SDK is used. It is suggested to do so right after the Phoenix object is initialised, but it can be deferred until a more convenient time. An error may occur at any time (usually due to networking) that cannot be handled by the SDK internally and will be surfaced through the error callback. These errors only really serve a purpose for developers to help with debugging.


*Swift:*
```
#!swift
        
        // Startup all modules.
        phoenix?.startup { (error) -> () in       
            // Handle critical/network error.
        }
        
```

*Objective-C:*

```
#!objc

        // Startup the SDK...
        [phoenix startupWithCallback:^(NSError *error) {        
            // Handle critical/network error.
        }];
        
```


# Phoenix Modules #

The Phoenix SDK is composed of several modules which can be used as necessary by developers to perform specific functions. Each module is described below with sample code where necessary.


## Analytics Module ##

The analytics module allows developers to effortlessly track several predefined events or their own custom events which can be used to determine user engagement and behavioural insights.

Tracking an event is as simple as accessing the track method on the analytics module, once you have initialised Phoenix.

How to track an Event:

*Swift:*
Note: there are some optional fields in Swift that default to zero/nil if missing.

```
#!swift

// Create custom Event
let myTestEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")

// Send event to Analytics module
phoenix?.analytics.track(myTestEvent)

```

*Objective-C:*
```
#!objc

// Create custom Event
PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:5 metadata:nil];

// Send event to Analytics module
[phoenix.analytics track:myTestEvent];

```

## Identity Module ##

This module provides methods for user management within the Phoenix platform. Allowing users to register, login, update, and retrieve information.

*NOTE:* The below methods will either return a User object or an Error object (not both) depending on whether the request was successful.

In addition to the errors specified by each individual method, you may also get one of the following errors if the request fails:

* RequestError.RequestFailedError: Unable to receive a response from the server, could be due to local connection or server issues.
* RequestError.ParseError: Unable to parse the response of the call.

These errors will be wrapped within an NSError using as domain RequestError.domain.



#### Create User ####

Register a user on the Phoenix platform.

Calling this method does not also perform a login, it is a two-step process, developers must call the 'login' method afterward if they want to streamline their app experience.

The code to create a user for each language is as follows:

*Swift:*


```
#!swift
    let user = Phoenix.User(companyId: companyId, username: usernameTxt,password: passwordTxt,
        firstName: firstNameTxt, lastName: lastNameTxt, avatarURL: avatarURLTxt)
        
    phoenix?.identity.createUser(user, callback: { (user, error) -> Void in
        // Treat the user and error appropriately. Notice that the callback might be performed
        // In a background thread. Use dispatch_async to handle it in the main thread.
    })
```

*Objective-C:*

```
#!objc

    PHXUser* user = [[PHXUser alloc] initWithCompanyId:companyID username:username password:password
        firstName:firstname lastName:lastname avatarURL:avatarURL];

    [phoenix.identity createUser:user callback:^(id<PHXUser> _Nullable user, NSError * _Nullable error) {
        // Treat the user and error appropriately. Notice that the callback might be performed
        // In a background thread. Use dispatch_async to handle it in the main thread.
    }];

```

The 'createUser' method can return the following additional errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.UserCreationError : When there is an error while creating the user in the platform. This contains network errors and possible errors generated in the backend.
* IdentityError.WeakPasswordError : When the password provided does not meet Phoenix security requirements. The requirements are that your password needs to have at least 8 characters, containing a number, a lowercase letter and an uppercase letter.

These errors will be wrapped within an NSError using as domain IdentityError.domain.



#### Get User ####

Request the user information for a particular userId.

The following code snippets illustrate how to request a user's information in Objective-C and Swift.

*Swift:*


```
#!swift

// Get the user via it's id
phoenix?.identity.getUser(userId) { (user, error) -> Void in
    // Get the user and treat the error
}


```

*Objective-C:*

```
#!objc

// Get the user via it's id
[phoenix getUser:userId callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
    // Get the user and treat the error
}];


```

The 'getUser' method can return the following additional errors:

* IdentityError.InvalidUserError : When the request can't be created with the provided user data (i.e. wrong userId, or authentication tokens).
* IdentityError.GetUserError : When there is an error while retrieving the user from the Phoenix platform, or no user is retrieved.

These errors will be wrapped within an NSError using as domain IdentityError.domain.



#### Login ####

If you have a registered account on the Phoenix platform you will be able to login to that account using the 'login' method:

*Swift:*
```
#!swift

phoenix.identity.login(withUsername: username, password: password, callback: { (user, error) -> () in
print("Logged in as: \(user)")
})

```

*Objective-C:*

```
#!objc

[phoenix.identity loginWithUsername:username password:password callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
NSLog(@"Logged in as: %@", user);
}];

```

The 'login' method can return the following additional errors:

* RequestError.AuthenticationFailedError: There was an issue that occurred during login, could be due to incorrect credentials.

This error will be wrapped within an NSError using as domain RequestError.domain.



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



#### Update User ####

The code to update a user for each language is as follows:

*Swift:*


```
#!swift
let user = Phoenix.User(userId: userId, companyId: companyId, username: usernameTxt,password: passwordTxt,
firstName: firstNameTxt, lastName: lastNameTxt, avatarURL: avatarURLTxt)

phoenix?.identity.updateUser(user, callback: { (user, error) -> Void in
// Treat the user and error appropriately. Notice that the callback might be performed
// In a background thread. Use dispatch_async to handle it in the main thread.
})
```

*Objective-C:*

```
#!objc

PHXUser* user = [[PHXUser alloc] initWithUserId:userID companyId:companyID username:username password:password
firstName:firstname lastName:lastname avatarURL:avatarURL];

[phoenix.identity updateUser:user callback:^(id<PHXUser> _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// In a background thread. Use dispatch_async to handle it in the main thread.
}];

```

The 'updateUser' method can return the following additional errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.UserUpdateError : When there is an error while updating the user in the platform. This contains network errors and possible errors generated in the backend.
* IdentityError.WeakPasswordError : When the password provided does not meet Phoenix security requirements. The requirements are that your password needs to have at least 8 characters, containing a number, a lowercase letter and an uppercase letter.

These errors will be wrapped within an NSError using as domain IdentityError.domain.



## Location Module ##

The location module is responsible for managing a user's location in order to track entering/exiting geofences and add this information to analytics events. 

Developers can disable geofences by setting 'use_geofences' to false in the Configuration file, however if they still want to include user's location in analytics they will still need to request permission for the users location.

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


