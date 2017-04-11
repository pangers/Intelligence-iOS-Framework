# Logging System.#

Currently, IOS IntelligenceSDK supports the logging. Means developer can enable the Log to make sure that process is happening smoothly and also used to debug the problem.

Intelligence IOS SDK doesn’t share the source code to the developer, logging is critical to observe the behaviour in the console.

By default, logging is disabled in the SDK and we can only enable in debug mode.

#Enable the Log#

Developers can enable the log through intelligence instance. Intelligence as an instance called “IntelligenceLogger”, this will handle all the logging activity.

let intelligence = try Intelligence(withDelegate: self, file: "IntelligenceConfiguration")
intelligence.location.includeLocationInEvents = true
intelligence.IntelligenceLogger.enableLogging = true;
intelligence.IntelligenceLogger.logLevel = .error;

#LogLevel#

There are different log level in the intelligenceLogger with priority from highest to lower. Namely debug, info, warning, error, severe, none.


[debug] - log all the events in detail. Example request header, body, URL and its response. Since debug is the highest priority, this will also display the logs belong to info, waring, error and severe mode.

[info] - This mode will display the brief info about the events. Since this is the lowest priority, it will not display the log events of debug mode.

[warning] - Display the warning thrown by the SDK.

[error] -  Display all the errors thrown by the SDK. Like if the request get failed or intelligence failed to initialize etc.

[severe] - Display if there any severe error’s occurs in SDK.

[none] - Use this option to turn off the logging events.

#Saving Log File#

The log file will get saved in the Document folder. For each day it will create then new log file and SDK will keep only last 5 days log file.

Developers can take get the log file and sent to intelligence support team if there any issue in the sdk.


#Note:#
Currently intelligenceSDK is not using the third party library like "XCLogger" for logging. This will create the dependency to the framework. Means SDK force the developer to install the xclogger library along with the intelligence SDK. This could be hassle if developers not using pods or carthage.
IntellignceSDK customize and include the XCLogger inside the framework. Also it make sure it won't conflict if app install the xclogger library.
