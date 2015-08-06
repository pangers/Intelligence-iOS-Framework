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
            phoenix.networkDelegate = self
            phoenix.startup(withCallback: { (authenticated) -> () in
                // Perform requests inside this callback
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

        __weak typeof(phoenix) weakPhoenix = phoenix;
        [phoenix setNetworkDelegate:self];
        [phoenix startupWithCallback:^(BOOL authenticated) {
            // Perform requests inside this callback.
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
phoenix.login(withUsername: username, password: password, callback: { (authenticated) -> () in
print("Logged in \(authenticated)")
})

```


**Objective-C:**

```
#!objc

// Optionally, login to a user's account...
[phoenix loginWithUsername:username password:password callback:^(BOOL authenticated) {
NSLog(@"Logged in %d", authenticated);
}];

```

You will then be logged in to a user's account (if 'authenticated' is true). Once you are logged in, you may want to give a user the ability to logout in which case you can call the 'logout' method (as seen below).

**Swift:**
```
#!swift

phoenix.logout()

```


**Objective-C:**

```

[phoenix logout];

```



## Phoenix Modules ##

The Phoenix platform is composed of a series of modules that can be used as required by the developer.

In this section, each modules are described, including its functions and sample code on how to use them.

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

    __weak typeof(self) weakSelf = self;
    
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
        
        PhoenixManager.manager.phoenix?.identity.createUser(user, callback: { [weak self] (user, error) -> Void in
            
            guard let this = self else {
                return
            }
            
            // Treat the user and error appropriately. Notice that the callback might be performed
            // In a background thread. Use dispatch_async to handle it in the main thread.
            
        })
```

Notice that the createUser method can return the following errors:

* IdentityError.InvalidUserError : When the user provided is invalid (e.g. some fields are not populated correctly, are empty, or the password does not pass our security requirements)
* IdentityError.UserCreationError : When there is an error while creating the user in the platform. This contains network errors and possible errors generated in the backend.


Those errors will be wrapped within an NSError using as domain IdentityError.domain.

#### Get User ####

There are two different ways to get a user:

* Obtaining a user from its id.
* Obtaining your user data from its token credentials.

The SDK offers two methods to obtain a user based on those two different approaches in the identity modules.

The following code snippets illustrate how to use each of the methods in Objective-C and Swift.

**Objective-C:**

```
#!objc

// Get user via our current credentials
[phoenix getMe:^(PHXPhoenixUser* _Nullable user, NSError * _Nullable error) {
    // Get the user and treat the error.
}];

// Get the user via it's id
[phoenix getUser:userId callback:^(PHXPhoenixUser * _Nullable user, NSError * _Nullable error) {
    // Get the user and treat the error
}];


```

**Swift:**


```
#!swift

// Get user via our current credentials
phoenix.identity.getMe({ (user, error) -> Void in
    // Get the user and treat the error
})

// Get the user via it's id
phoenix.identity.getUser(userId) { (user, error) -> Void in
    // Get the user and treat the error
}


```

Notice that the get user methods can return the following errors:

* IdentityError.InvalidUserError : When the request can't be created with the provided user data (i.e. wrong userId, or authentication tokens).
* IdentityError.GetUserError : When there is an error while retrieving the user from the Phoenix platform, or no user is retrieved.

Those errors will be wrapped within an NSError using as domain IdentityError.domain.

