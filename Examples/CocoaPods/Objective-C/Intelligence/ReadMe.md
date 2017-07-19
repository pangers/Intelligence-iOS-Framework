# Using CocoaPods

Intelligence is available via CocoaPods. If you're new to CocoaPods, You can install it with the following command:

```

$ gem install cocoapods


```

For more info refer [Getting Started Guide](https://guides.cocoapods.org/using/using-cocoapods.html).

To integrate IntelligenceSDK into your Xcode project, navigate to the directory that contains your project and create a new Podfile with pod init or open an existing one, then add pod 'IntelligenceSDK' to the main loop. If you are using the Swift SDK, make sure to add the line use_frameworks!.

Here's what you have to add to your Podfile:

```

use_frameworks!

target 'Your Project Name' do
pod 'IntelligenceSDK'
end

```

If you want to install specific version of cocoapod library (e.g. 1.0):

```
use_frameworks!
target :YourTargetName do
pod 'IntelligenceSDK', '1.0'
end

```

Then, run the following command to install the dependency:

```

$ pod install

```

Remember to close any current XCode sessions and use the file ending in .xcworkspace after installation. If you open your .xcworkspace file, you should be able to see the IntelligenceSDK folder under the Pods folder.


For Objective-C projects, set the Embedded Content Contains Swift Code flag in your project to Yes (found under Build Options in the Build Settings tab).




Congratulations, you've added the Uber Rides iOS SDK into your project using CocoaPods! 

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

