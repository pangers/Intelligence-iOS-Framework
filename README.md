# Phoenix SDK #
```
Current iOS application credentials (DELETE BEFORE GOING PUBLIC)
Client ID: iOSSDK_hvxbincerennv
Client Secret: IZYKF5c975Lkjazjhosplmroopifkhjgeegagrpf
AppId: 4152
ProjectId: 3030
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
            let phoenix = try Phoenix(withFile: "config", inBundle: NSBundle(forClass: PhoenixTestCase.self))
            phoenix?.startup()
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
            phoenix?.startup()
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
            phoenix?.startup()
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
            let instance = try Phoenix(withFile: "config")
            instance.networkDelegate = self
            instance.startup(withCallback: { (authenticated) -> () in
                // Perform requests inside this callback

                // Optionally, login to a user's account...
                instance.login(withUsername: username, password: password, callback: { (authenticated) -> () in
                    print("Logged in \(authenticated)")


                    // How to handle logout once you have authenticated.
                    instance.logout()
                })
            }
            self.phoenix = instance
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
        instance = [[Phoenix alloc] initWithFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
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

            // Optionally, login to a user's account...
            [weakPhoenix loginWithUsername:username password:password callback:^(BOOL authenticated) {
                NSLog(@"Logged in %d", authenticated);

                // How to handle logout once you have authenticated.
                [weakPhoenix logout];
            }];
        }];
```

The Phoenix.startup() method is responsible to bootstrap the SDK, without it, undefined behaviour might occur, and thus it's the developer responsibility to call it before the SDK is used. It is suggested to do so right after the Phoenix object is initialised, but it can be deferred until a more convenient time.

Consider that the Phoenix.Configuration can throw exceptions if you haven't configured properly your setup. Please refer to the class documentation for further information on what kind of errors it can throw.

Also, check the Phoenix.Configuration and Phoenix classes to learn about more initializers available for you.