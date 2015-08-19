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

### Configuration ###

The Phoenix SDK requires a few configuration properties in order to initialize itself. There are a few different ways of creating the configuration:

1- Initialize Phoenix with a configuration file:


```
#!swift

        do {
            let phoenix = try Phoenix(withFile: "config", inBundle: nil)
            phoenix?.networkDelegate = self
            phoenix?.startup(withCallback: { (authenticated) -> () in
                // Perform requests inside this callback
            }
        }
        catch {
            // Treat the error with care!
        }

```

2- Initialize a configuration object, read a file and pass it to Phoenix:


```
#!swift

        let bundle = NSBundle.mainBundle()
        
        do {
            let configuration = try Phoenix.Configuration(fromFile: "config", inBundle: bundle)
            let phoenix = Phoenix(withConfiguration: configuration)
            phoenix?.networkDelegate = self
            phoenix?.startup(withCallback: { (authenticated) -> () in
                // Perform requests inside this callback
            }
        }
        catch {
            // Treat the error with care!
        }

```

3- Programmatically set the required parameters in the configuration, and initialize Phoenix with it.


```
#!swift

        let configuration = Phoenix.Configuration()
        
        configuration.clientID = "YOUR_CLIENT_ID"
        configuration.clientSecret = "YOUR_CLIENT_SECRET"
        configuration.projectID = 123456789
        configuration.applicationID = 987654321
        configuration.region = Phoenix.Region.Europe

```

4- Hybrid initialization of the configuration file, reading a file and customizing programmatically some of its properties:


```
#!swift

        let bundle = NSBundle.mainBundle()
        
        do {
            let configuration = try Phoenix.Configuration(fromFile: "config", inBundle: bundle)
            configuration.region = Phoenix.Region.Europe

            let phoenix = Phoenix(withConfiguration: configuration)
            phoenix?.networkDelegate = self
            phoenix?.startup(withCallback: { (authenticated) -> () in
                // Perform requests inside this callback
            }
        }
        catch {
            // Treat the error with care!
        }

```

### Configuration file format ###

The configuration file is a JSON file with the following keys:

1. "client_id" with a String value
2. "client_secret" with a String value
3. "application_id" with an Integer value
4. "project_id" with an Integer value
5. "region" with a String value which needs to be one of: "US","EU","AU" or "SG"

As an example, your configuration file will look like:


```
#!JSON

{
    "client_id": "CLIENT_ID",
    "client_secret": "CLIENT_SECRET",
    "application_id": 10,
    "project_id": 20,
    "region": "EU",
    "company_id" : 10
}

```

### Initialising Phoenix ###

First of all, create a new Workspace to embed both your project and the PhoenixSDK framework project.

Once you get a workspace with both projects coexisting in it, add the SDK in the list of Linked Frameworks and Libraries so that it is accessible from your own project:

![Linked Frameworks and Libraries](https://bitbucket.org/repo/4z6Eb8/images/3275432151-Screen%20Shot%202015-07-22%20at%2017.55.51.png)

Next, import the PhoenixSDK framework.

**Swift:**
```
#!swift

import PhoenixSDK

```

**Objective-C:**
```
#!objc
@import PhoenixSDK;
```

Finally, to initialise the SDK you'll have to add in the application didFinishLaunchingWithOptions: the following lines:

**Swift:**
```
#!swift
        
        do {
            phoenix = try Phoenix(withFile: "config")
            phoenix.startup(withCallback: { (error) -> () in
                // Handle critical/network error.
            }
        }
        catch PhoenixSDK.ConfigurationError.FileNotFoundError {
            // The file you specified does not exist!
        }
        catch PhoenixSDK.ConfigurationError.InvalidFileError {
            // The file is invalid! Check that the JSON provided is correct.
        }
        catch PhoenixSDK.ConfigurationError.MissingPropertyError {
            // You missed a property!
        }
        catch PhoenixSDK.ConfigurationError.InvalidPropertyError {
            // There is an invalid property!
        }
        catch {
            // Treat the error with care!
        }
        
```

**Objective-C:**

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
        [phoenix startupWithCallback:^(NSError *error) {        
            // Handle critical/network error.
        }];
```

The Phoenix.startup() method is responsible to bootstrap the SDK, without it, undefined behaviour might occur, and thus it's the developer responsibility to call it before the SDK is used. It is suggested to do so right after the Phoenix object is initialised, but it can be deferred until a more convenient time.

Consider that the Phoenix.Configuration can throw exceptions if you haven't configured properly your setup. Please refer to the class documentation for further information on what kind of errors it can throw.

Also, check the Phoenix.Configuration and Phoenix classes to learn about more initializers available for you.

### Authentication ###

If you have a registered account on the Phoenix Platform you will be able to login to that account using the login method (as seen below).

**Swift:**
```
#!swift

// Optionally, login to a user's account...
phoenix.identity.login(withUsername: username, password: password, callback: { (user, error) -> () in
print("Logged in as: \(user)")
})

```


**Objective-C:**

```
#!objc

// Optionally, login to a user's account...
[phoenix.identity loginWithUsername:username password:password callback:^(PHXPhoenixUser * _Nullable user, NSError * _Nullable error) {
NSLog(@"Logged in as: %@", user);
}];

```

You will then be logged in to a user's account (if 'authenticated' is true). Once you are logged in, you may want to give a user the ability to logout in which case you can call the 'logout' method (as seen below).

**Swift:**
```
#!swift

phoenix.identity.logout()

```


**Objective-C:**

```

[phoenix.identity logout];

```



## Phoenix Modules ##

The Phoenix platform is composed of a series of modules that can be used as required by the developer.

In this section, each modules are described, including its functions and sample code on how to use them.

### Analytics Module ###

The analytics module allows developers to effortlessly track several predefined events or their own custom events which can be used to determine user engagement and behavioural insights.

Tracking an event is as simple as accessing the track method on the analytics module, once you have initialised Phoenix.

How to track a custom Event:

**Objective-C:**
```
#!objc

// Create custom Event
PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:5 metadata:nil];

// Send event to Analytics module
[[PHXPhoenixManager sharedManager].phoenix.analytics track:myTestEvent];

```

**Swift:**
Note: there are some optional fields in Swift that default to zero/nil if missing.

```
#!swift

// Create custom Event
let myTestEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")

// Send event to Analytics module
PhoenixManager.manager.phoenix?.analytics.track(myTestEvent)

```

### Identity Module ###

The identity module is responsible to perform user management within the Phoenix platform, allowing to create, retrieve and update users.

Notice that calling this methods **won't** start using the user's credentials. 
You'll need to perform an authentication with the new user's credentials in order to do so.

Also, the input and output of this operation is not stored by the SDK, and the developer is responsible to do so if required in its app.

#### Create user ####

The code to create a user for each language is as follows:

**Objective-C:**

```
#!objc

    PHXPhoenixUser* user = [[PHXPhoenixUser alloc] initWithCompanyId:companyID username:username password:password
        firstName:firstname lastName:lastname avatarURL:avatarURL];

    [[PHXPhoenixManager sharedManager].phoenix.identity createUser:user callback:^(id<PHXPhoenixUser> _Nullable user, NSError * _Nullable error) {
        // Treat the user and error appropriately. Notice that the callback might be performed
        // In a background thread. Use dispatch_async to handle it in the main thread.
    }];

```

**Swift:**


```
#!swift
        let user = Phoenix.User(companyId: companyId, username: usernameTxt,password: passwordTxt,
                    firstName: firstNameTxt, lastName: lastNameTxt, avatarURL: avatarURLTxt)
        
        PhoenixManager.manager.phoenix?.identity.createUser(user, callback: { (user, error) -> Void in
            // Treat the user and error appropriately. Notice that the callback might be performed
            // In a background thread. Use dispatch_async to handle it in the main thread.
        })
```

Notice that the createUser method can return the following errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.UserCreationError : When there is an error while creating the user in the platform. This contains network errors and possible errors generated in the backend.
* IdentityError.WeakPasswordError : When the password provided does not meet Phoenix security requirements. The requirements are that your password needs to have at least 8 characters, containing a number, a lowercase letter and an uppercase letter.


Those errors will be wrapped within an NSError using as domain IdentityError.domain.

#### Update user ####

The code to update a user for each language is as follows:

**Objective-C:**

```
#!objc

PHXPhoenixUser* user = [[PHXPhoenixUser alloc] initWithUserId:userID companyId:companyID username:username password:password
firstName:firstname lastName:lastname avatarURL:avatarURL];

[[PHXPhoenixManager sharedManager].phoenix.identity updateUser:user callback:^(id<PHXPhoenixUser> _Nullable user, NSError * _Nullable error) {
// Treat the user and error appropriately. Notice that the callback might be performed
// In a background thread. Use dispatch_async to handle it in the main thread.
}];

```

**Swift:**


```
#!swift
let user = Phoenix.User(userId: userId, companyId: companyId, username: usernameTxt,password: passwordTxt,
firstName: firstNameTxt, lastName: lastNameTxt, avatarURL: avatarURLTxt)

PhoenixManager.manager.phoenix?.identity.updateUser(user, callback: { (user, error) -> Void in
// Treat the user and error appropriately. Notice that the callback might be performed
// In a background thread. Use dispatch_async to handle it in the main thread.
})
```

Notice that the createUser method can return the following errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.UserUpdateError : When there is an error while updating the user in the platform. This contains network errors and possible errors generated in the backend.
* IdentityError.WeakPasswordError : When the password provided does not meet Phoenix security requirements. The requirements are that your password needs to have at least 8 characters, containing a number, a lowercase letter and an uppercase letter.


Those errors will be wrapped within an NSError using as domain IdentityError.domain.


#### Get User ####

Request the user information for a particular userId.

The following code snippets illustrate how to request a user's information in Objective-C and Swift.

**Objective-C:**

```
#!objc

// Get the user via it's id
[[[PHXPhoenixManager sharedManager].phoenix getUser:userId callback:^(PHXPhoenixUser * _Nullable user, NSError * _Nullable error) {
    // Get the user and treat the error
}];


```

**Swift:**


```
#!swift

// Get the user via it's id
PhoenixManager.manager.phoenix?.identity.getUser(userId) { (user, error) -> Void in
    // Get the user and treat the error
}


```

Notice that the get user methods can return the following errors:

* IdentityError.InvalidUserError : When the request can't be created with the provided user data (i.e. wrong userId, or authentication tokens).
* IdentityError.GetUserError : When there is an error while retrieving the user from the Phoenix platform, or no user is retrieved.

Those errors will be wrapped within an NSError using as domain IdentityError.domain.

Also, the input and output of this operation is not stored by the SDK, and the developer is responsible to do so if required in its app.


### Location Module ###

The location module is responsible for managing a user's location and handling events for entering/exiting geofences. This module will request user location when enabled and currently manages all logic internally.

Developers can disable geofence downloading and checking by setting 'use_geofences' to false in the Configuration file.
