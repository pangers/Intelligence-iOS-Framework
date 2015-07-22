**TODO - We should explain how to format or where to obtain the json file, and also to embed it in the project.**

# Phoenix SDK #

The goal of this SDK is to encapsulate in a developer-friendly manner the Phoenix platform's API's.

## Getting Started ##



In this section we detail how to get up and running with the SDK for both Objective-C and Swift based projects.

### Swift ###

First of all, create a new Workspace to embed both your project and the PhoenixSDK framework project.

Once you get a workspace with both projects coexisting in it, add the SDK in the list of Linked Frameworks and Libraries so that it is accessible from your own project:

![Linked Frameworks and Libraries](https://bitbucket.org/repo/4z6Eb8/images/3275432151-Screen%20Shot%202015-07-22%20at%2017.55.51.png)

With this you should be able to import into your swift the PhoenixSDK namespace by using:


```
#!swift

import PhoenixSDK

```

Finally, to initialise the SDK you'll have to add in the application didFinishLaunchingWithOptions: the following lines:


```
#!swift
        
        do {
            let configuration = try Phoenix.Configuration(fromFile: "phoenixConfig", inBundle: NSBundle.mainBundle())
            self.phoenix = Phoenix(withConfiguration: configuration);
        }
        catch {
            // Treat the error with care!
        }
        
```

Consider that the Phoenix.Configuration can throw exceptions if you haven't configured properly your setup. Please refer to the class documentation for further information on what kind of errors it can throw.

Also, check the Phoenix.Configuration and Phoenix classes to learn about more initializers available for you.

### Objective-C ###

