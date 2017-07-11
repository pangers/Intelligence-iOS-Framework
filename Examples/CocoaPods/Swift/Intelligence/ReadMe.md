# Using CocoaPods

Intelligence is available via CocoaPods. If you're new to CocoaPods, this [Getting Started Guide](https://guides.cocoapods.org/using/using-cocoapods.html) will help you.

Important: Please make sure that you have a CocoaPods version >= 1.0.0 installed. You can check your version of CocoaPods with 

```
pod --version.
```

Here's what you have to add to your Podfile:

```
use_frameworks!
target :YourTargetName do
pod 'IntelligenceSDK'
end
```

Pinning to a specific version (e.g. 1.0):

```
use_frameworks!
target :YourTargetName do
pod 'IntelligenceSDK', '1.0'
end
```
To Integrate Intelligence API, refer Intelligence [wiki](https://git-apac.internal.tigerspike.com/phoenix/Phoenix-Intelligence-iOS-SDK).
