# Using Carthage

Intelligence is available via Carthage.You can integrate Intelligence into your project using Carthage. If you're new to Carthage, check out their [documentation](https://github.com/Carthage/Carthage) first.

You can install Carthage (with XCode 7+) via homebrew:

```

brew update
brew install carthage

```

To install IntelligenceSDK via Carthage, you need to create a Cartfile. In the root directory of your project, run the following command:

```

touch cartfile

```

In the editor of your choice open the file and add the following:

```

binary "https://s3-ap-southeast-1.amazonaws.com/chethansp007.sample/IntelligenceFramework.json" ~> 1.0

```

### To use the specific version of the library(eg:1.0):

```

binary "https://s3-ap-southeast-1.amazonaws.com/chethansp007.sample/IntelligenceFramework.json" == 1.0

```


Now run the following command to checkout & build our repo and dependencies.

```

carthage update 


```

You should now have a Carthage/Build folder in your project directory. Open your .xcodeproj and go to the General settings tab. In the Linked Frameworks and Libraries section, drag and drop each framework (in Carthage/Build/iOS)

Now, open your application target's Build Phases settings tab, click the + icon, and select New Run Script Phase. Add the following to the script area:

```

/usr/local/bin/carthage copy-frameworks

```

and add the paths to the required frameworks in Input Files

```

$(SRCROOT)/Carthage/Build/iOS/IntelligenceSDK.framework

```

For Objective-C projects, set the Embedded Content Contains Swift Code flag in your project to Yes (found under Build Options in the Build Settings tab).

Congratulations, you've added the Intelligence iOS SDK into your project using Carthage! 


## API Integration

1. Include the "IntelligenceManager.swift" [file](/Code-Snippet/Swift/IntelligenceManager.swift) into your project.

2. Update the clientSecret,ClientID,ApplicationID and projectID in the IntelligenceManager.swift class.

3. Statup the Intelligence in AppDelegate, application:didFinishLaunchingWithOptions method.  

```

IntelligenceManager.sharedInstance.startUp { (status, error) in
    assert(status,"Failed to Initilaize intelligence")
}

```

4. Post event anywhere from your app using following snippet.

```

IntelligenceManager.sharedInstance.postEvent(name: "IOS-Event-2");

```

For more info on Intelligence API refer [wiki](https://git-apac.internal.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK).
