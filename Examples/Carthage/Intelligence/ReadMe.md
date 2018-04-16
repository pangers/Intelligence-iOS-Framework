# Using Carthage

Intelligence is available via Carthage. If you're new to Carthage, check out their [documentation](https://github.com/Carthage/Carthage) first.

**Note:** Please make sure that you have Carthage version >= 0.19 installed. You can check your Carthage version with

```
Carthage version
```
### Here's what you have to add to your Cartfile:

```
binary "https://raw.githubusercontent.com/tigerspike/Intelligence-iOS-Framework/master/carthage-dependency.json" ~> 1.0
```
Using the above command Carthage will download the Intelligence version compatible with 1.0 and above.

### To use the specific version of the library:

```
binary "https://raw.githubusercontent.com/tigerspike/Intelligence-iOS-Framework/master/carthage-dependency.json" == 1.0
```
Using the above Carthage will download the latest Intelligence framework of version 1.0.

To Integrate Intelligence API, refer Intelligence [wiki](https://github.com/tigerspike/Intelligence-iOS-Framework/wiki/Intelligence-iOS-Framework).
