// Generated by Apple Swift version 3.1 (swiftlang-802.0.53 clang-802.0.42)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if defined(__has_attribute) && __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if defined(__has_attribute) && __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if defined(__has_feature) && __has_feature(modules)
@import Foundation;
@import ObjectiveC;
@import CoreLocation;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"

SWIFT_PROTOCOL("_TtP15IntelligenceSDK14ModuleProtocol_")
@protocol ModuleProtocol
- (void)startupWithCompletion:(void (^ _Nonnull)(BOOL))completion;
- (void)shutdown;
@end

@class INTEvent;

/// The Intelligence Analytics Module defines the methods available for tracking events.
SWIFT_PROTOCOL_NAMED("AnalyticsModuleProtocol")
@protocol INTAnalyticsModuleProtocol <ModuleProtocol>
/// Pause analytics module, must be called when entering the background.
- (void)pause;
/// Resume analytics module, must be called after returning from background.
- (void)resume;
/// Track user engagement and behavioral insight.
/// \param event Event containing information to track.
///
- (void)track:(INTEvent * _Nonnull)event;
@end

/// Enumeration to list the errors that can occur in the authentication module.
typedef SWIFT_ENUM(NSInteger, AuthenticationError) {
/// The client or user credentials are incorrect.
  AuthenticationErrorCredentialError = 3001,
/// The account has been disabled.
  AuthenticationErrorAccountDisabledError = 3002,
/// The account has been locked due to multiple authentication failures.
/// An Administration is required to unlock.
  AuthenticationErrorAccountLockedError = 3003,
/// The token is invalid or has expired.
  AuthenticationErrorTokenInvalidOrExpired = 3004,
};
static NSString * _Nonnull const AuthenticationErrorDomain = @"IntelligenceSDK.AuthenticationError";


@interface NSBundle (SWIFT_EXTENSION(IntelligenceSDK))
@end

/// This enum represents the certificate trust policy to apply when the Intelligence SDK connects to the server.
/// Certificate validity is defined by iOS and not by the SDK.
/// When receiving a certificate challenge from iOS, the SDK will apply the selected policy.
typedef SWIFT_ENUM(NSInteger, CertificateTrustPolicy) {
  CertificateTrustPolicyValid = 0,
/// Trust only certificates that are considered valid by iOS. This is the default value
  CertificateTrustPolicyAny = 1,
/// Trust any certificate, independently of iOS considering it valid or invalid
  CertificateTrustPolicyAnyNonProduction = 2,
};

/// Enumeration that defines the possible errors that can occur during
/// the initial setup of Intelligence’s configuration.
/// Refer to the Readme file to obtain further instructions on setup.
typedef SWIFT_ENUM(NSInteger, ConfigurationError) {
/// Configuration file does not exist.
  ConfigurationErrorFileNotFoundError = 1001,
/// A property is invalid.
  ConfigurationErrorInvalidPropertyError = 1002,
/// Configuration file is invalid
/// (Couldn’t parse into a JSON or had an issue while reading it)
  ConfigurationErrorInvalidFileError = 1003,
/// There is a missing property in the configuration.
  ConfigurationErrorMissingPropertyError = 1004,
};
static NSString * _Nonnull const ConfigurationErrorDomain = @"IntelligenceSDK.ConfigurationError";


/// Intelligence coordinate object. CLLocationCoordinate2D can’t be used as an optional.
/// Furthermore, not providing a custom location object would force the developers to
/// always require CoreLocation even if they don’t need to use it.
SWIFT_CLASS_NAMED("Coordinate")
@interface INTCoordinate : NSObject
/// Default initializer with latitude and longitude
/// \param latitude 
///
/// \param longitude 
///
///
/// returns:
/// A newly initialized geofence.
- (nonnull instancetype)initWithLatitude:(double)latitude longitude:(double)longitude OBJC_DESIGNATED_INITIALIZER;
- (BOOL)isEqual:(id _Nullable)object SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end


@interface NSDateFormatter (SWIFT_EXTENSION(IntelligenceSDK))
@end


/// Custom event which can be sent to the ‘track:’ method in the Analytics module.
SWIFT_CLASS_NAMED("Event")
@interface INTEvent : NSObject
/// Initializer for Event class.
/// seealso:
/// Analytics module <code>track(event:)</code> method.
/// \param type Type of Event we are trying to track.
///
/// \param value Value associated with Event. Defaults to 0.0.
///
/// \param targetId Optional identifier relevant to this event. Defaults to nil.
///
/// \param metadata Optional metadata field.
///
///
/// returns:
/// Returns an Event object.
- (nonnull instancetype)initWithType:(NSString * _Nonnull)type value:(double)value targetId:(NSString * _Nullable)targetId metadata:(NSDictionary<NSString *, id> * _Nullable)metadata OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end


/// An instance of a geofence with a latitude/longitude/radius combination.
SWIFT_CLASS_NAMED("Geofence")
@interface INTGeofence : NSObject
/// Longitude of the geofence.
@property (nonatomic, readonly) double longitude;
/// Latitude of the geofence.
@property (nonatomic, readonly) double latitude;
/// Radius around the longitude + latitude to include.
@property (nonatomic, readonly) double radius;
/// Identifier of this geofence.
@property (nonatomic, readonly) NSInteger id;
/// Project ID for this geofence.
@property (nonatomic, readonly) NSInteger projectId;
/// Name of this geofence.
@property (nonatomic, readonly, copy) NSString * _Nonnull name;
/// Address associated with this geofence.
@property (nonatomic, readonly, copy) NSString * _Nonnull address;
/// Date this geofence was modified last on the server. (Unused)
@property (nonatomic, readonly) NSTimeInterval modifyDate;
/// Date this geofence was created on the server. (Unused)
@property (nonatomic, readonly) NSTimeInterval createDate;
- (BOOL)isEqual:(id _Nullable)object SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


@interface INTGeofence (SWIFT_EXTENSION(IntelligenceSDK))
@end


/// An instance of object using to create query part of URL for Geofence API
SWIFT_CLASS_NAMED("GeofenceQuery")
@interface INTGeofenceQuery : NSObject
/// The latitude of the coordinates.
@property (nonatomic) double longitude;
/// The longitude of the coordinates
@property (nonatomic) double latitude;
/// The radius (in meters) to limit the geofences to fetch
@property (nonatomic) double radius;
/// Default initializer. Requires location coordinates to query for list of geofences.
/// \param location location coordinates to look for geofences related to.
///
- (nonnull instancetype)initWithLocation:(INTCoordinate * _Nonnull)location radius:(double)radius OBJC_DESIGNATED_INITIALIZER;
- (void)setPageSize:(NSInteger)pageSize;
- (void)setPage:(NSInteger)page;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end

/// Enumeration to list the errors that can occur in the identity module.
typedef SWIFT_ENUM(NSInteger, IdentityError) {
/// The user is invalid.
  IdentityErrorInvalidUserError = 4001,
/// The password provided is too weak. See <code>Intelligence.User</code> password field to see
/// the security requirements of the password.
  IdentityErrorWeakPasswordError = 4002,
/// The device token is invalid (zero length).
  IdentityErrorDeviceTokenInvalidError = 4003,
/// Device token has not been registered yet.
  IdentityErrorDeviceTokenNotRegisteredError = 4004,
};
static NSString * _Nonnull const IdentityErrorDomain = @"IntelligenceSDK.IdentityError";

@class INTUser;
@class NSError;

/// The Intelligence Idenity module protocol. Defines the available API calls that can be performed.
SWIFT_PROTOCOL_NAMED("IdentityModuleProtocol")
@protocol INTIdentityModuleProtocol <ModuleProtocol>
/// Attempt to authenticate with a username and password.
/// Logging in with associate events with this user.
/// <ul>
///   <li>
///     Parameters
///     <ul>
///       <li>
///         username: Username of account to attempt login with.
///       </li>
///       <li>
///         password: Password associated with username.
///       </li>
///       <li>
///         callback: The user callback to pass. Will be called with either an error or a user.
///       </li>
///     </ul>
///   </li>
/// </ul>
- (void)loginWith:(NSString * _Nonnull)username password:(NSString * _Nonnull)password callback:(void (^ _Nonnull)(INTUser * _Nullable, NSError * _Nullable))callback;
/// Logging out will no longer associate events with the authenticated user.
- (void)logout;
/// Get details about logged in user.
/// \param callback Will be called with either an error or a user.
///
- (void)getMeWithCallback:(void (^ _Nonnull)(INTUser * _Nullable, NSError * _Nullable))callback;
/// Register a push notification token on the Intelligence platform.
/// \param data Data received from ‘application:didRegisterForRemoteNotificationsWithDeviceToken:’ response.
///
/// \param callback Callback to fire on completion, will contain error or token ID. Developer should store token ID and is responsible for managing the flow of registration for push.
///
- (void)registerDeviceTokenWith:(NSData * _Nonnull)data callback:(void (^ _Nonnull)(NSInteger, NSError * _Nullable))callback;
/// Unregister a token ID in the backend, will fail if it was registered against another user.
/// \param tokenId Previously registered token ID. Should be unregistered prior to logout if you have multiple accounts.
///
/// \param callback Callback to fire on completion, error will be set if unable to unregister.
///
- (void)unregisterDeviceTokenWith:(NSInteger)tokenId callback:(void (^ _Nonnull)(NSError * _Nullable))callback;
@end

@class INTConfiguration;
@protocol INTLocationModuleProtocol;
@protocol INTDelegate;

/// Base class for initialization of the SDK. Developers must call ‘startup’ method to start modules.
SWIFT_CLASS("_TtC15IntelligenceSDK12Intelligence")
@interface Intelligence : NSObject
///
/// returns:
/// A <em>copy</em> of the configuration.
@property (nonatomic, readonly, strong) INTConfiguration * _Nonnull configuration;
/// The identity module, enables user management in the Intelligence backend.
@property (nonatomic, readonly, strong) id <INTIdentityModuleProtocol> _Null_unspecified identity;
/// Analytics instance that can be used for posting Events.
@property (nonatomic, readonly, strong) id <INTAnalyticsModuleProtocol> _Null_unspecified analytics;
/// The location module, used to internally manages geofences and user location. Hidden from developers.
@property (nonatomic, readonly, strong) id <INTLocationModuleProtocol> _Null_unspecified location;
/// Initializes the Intelligence entry point with a configuration object.
/// \param delegate The delegate to call for events propagated by Intelligence modules.
///
/// \param configuration Instance of the Configuration class, object will be copied to avoid mutability.
///
///
/// throws:
/// <em>ConfigurationError</em> if the configuration is invalid.
///
/// returns:
/// New instance of the Intelligence SDK base class.
- (nullable instancetype)initWithDelegate:(id <INTDelegate> _Nonnull)delegate configuration:(INTConfiguration * _Nonnull)intelligenceConfiguration error:(NSError * _Nullable * _Nullable)error;
/// Initialize Intelligence with a configuration file.
/// \param delegate The delegate to call for events propagated by Intelligence modules.
///
/// \param file The JSON file name (no extension) of the configuration.
///
/// \param inBundle The NSBundle to use. Defaults to the main bundle.
///
///
/// throws:
/// <em>ConfigurationError</em> if the configuration is invalid or there is a problem reading the file.
///
/// returns:
/// New instance of the Intelligence SDK base class.
- (nullable instancetype)initWithDelegate:(id <INTDelegate> _Nonnull)delegate file:(NSString * _Nonnull)file inBundle:(NSBundle * _Nonnull)inBundle error:(NSError * _Nullable * _Nullable)error;
/// Starts up the Intelligence SDK modules.
/// \param callback Called when the startup of Intelligence finishes. Receives in a boolean
/// whether the startup was successful or not. This call has to finish successfully
/// before using any of the intelligence modules. If any action is performed while startup
/// has not yet finished fully, an unexpected error is likely to occur.
///
- (void)startup:(void (^ _Nonnull)(BOOL))completion;
/// Shutdowns the Intelligence SDK modules. After shutting down, you’ll have to
/// startup again before being able to use Intelligence reliably again.
- (void)shutdown;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end


@interface Intelligence (SWIFT_EXTENSION(IntelligenceSDK))
@end


/// The user class implementation
SWIFT_CLASS_NAMED("User")
@interface INTUser : NSObject
/// The user Id as a let
@property (nonatomic, readonly) NSInteger userId;
/// The company Id as a let. Should be fetched from the Configuration of Intelligence.
@property (nonatomic) NSInteger companyId;
/// The username
@property (nonatomic, copy) NSString * _Nonnull username;
/// The password
@property (nonatomic, copy) NSString * _Nullable password;
/// The firstname
@property (nonatomic, copy) NSString * _Nonnull firstName;
/// The last name
@property (nonatomic, copy) NSString * _Nullable lastName;
/// The avatar URL
@property (nonatomic, copy) NSString * _Nullable avatarURL;
/// Initializer a new User object.
/// \param userId Id for this user, required for Update User call.
///
/// \param companyId Id of company this user belongs to.
///
/// \param username Username for this user, must be included.
///
/// \param password Password for this user, must be included.
///
/// \param firstName First name for this user.
///
/// \param lastName Last name of this user.
///
/// \param avatarURL URL pointing at the users avatar.
///
///
/// returns:
/// A new User object.
- (nonnull instancetype)initWithUserId:(NSInteger)userId companyId:(NSInteger)companyId username:(NSString * _Nonnull)username password:(NSString * _Nullable)password firstName:(NSString * _Nonnull)firstName lastName:(NSString * _Nullable)lastName avatarURL:(NSString * _Nullable)avatarURL OBJC_DESIGNATED_INITIALIZER;
/// Convenience initializer with no user id.
- (nonnull instancetype)initWithCompanyId:(NSInteger)companyId username:(NSString * _Nonnull)username password:(NSString * _Nullable)password firstName:(NSString * _Nonnull)firstName lastName:(NSString * _Nullable)lastName avatarURL:(NSString * _Nullable)avatarURL;
/// A password is considered secure if it has at least 8 characters, and uses
/// at least a number, a lowercase letter and an uppercase letter.
///
/// returns:
/// True if the password is secure.
- (BOOL)isPasswordSecure SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
@end


@interface Intelligence (SWIFT_EXTENSION(IntelligenceSDK))
@end

/// An enum with the regions to which the SDK can be pointing to.
typedef SWIFT_ENUM(NSInteger, Region) {
/// US Region
  RegionUnitedStates = 0,
/// AU Region
  RegionAustralia = 1,
/// EU Region
  RegionEurope = 2,
/// SG Region
  RegionSingapore = 3,
};


@interface Intelligence (SWIFT_EXTENSION(IntelligenceSDK))
@end


/// This class holds the data to configure the intelligence SDK. It provides initialisers to
/// read the configuration from a JSON file in an extension, and allows to validate that
/// the data contained is valid to initialise the Intelligence SDK.
SWIFT_CLASS_NAMED("Configuration")
@interface INTConfiguration : NSObject
/// The client ID
@property (nonatomic, copy) NSString * _Nonnull clientID;
/// The client secret
@property (nonatomic, copy) NSString * _Nonnull clientSecret;
/// The provider Id
@property (nonatomic, readonly) NSInteger providerId;
/// The project ID
@property (nonatomic) NSInteger projectID;
/// The application ID
@property (nonatomic) NSInteger applicationID;
/// The trust policy to apply to server certificates.
/// By default we will only trust valid certificates.
@property (nonatomic) enum CertificateTrustPolicy certificateTrustPolicy;
/// Intelligence Identity user.To track the events assosiated to user.
@property (nonatomic, copy) NSString * _Nullable userName;
/// password of Intelligence Identity user.To track the events assosiated to user.
@property (nonatomic, copy) NSString * _Nullable userPassword;
/// Convenience initializer to load from a file.
/// \param fromFile The file name to read. The .json extension is appended to it.
///
/// \param inBundle The bundle that contains the given file.
///
///
/// throws:
/// A <em>ConfigurationError</em> if the configuration file is incorrectly formatted.
- (nullable instancetype)initFromFile:(NSString * _Nonnull)file inBundle:(NSBundle * _Nonnull)bundle error:(NSError * _Nullable * _Nullable)error;
- (nullable instancetype)initFromData:(NSData * _Nonnull)fromData error:(NSError * _Nullable * _Nullable)error;
/// Factory method to initialize a configuration and return it.
/// \param fromFile The file name to read. The .json extension is appended to it.
///
/// \param inBundle The bundle that contains the given file.
///
///
/// throws:
/// A <em>ConfigurationError</em> if the configuration file is incorrectly formatted.
///
/// returns:
/// A configuration with the contents of the file.
+ (INTConfiguration * _Nullable)configurationFromFile:(NSString * _Nonnull)file inBundle:(NSBundle * _Nonnull)bundle error:(NSError * _Nullable * _Nullable)error SWIFT_WARN_UNUSED_RESULT;
///
/// returns:
/// A copy of the configuration object.
- (INTConfiguration * _Nonnull)clone SWIFT_WARN_UNUSED_RESULT;
/// Parses the JSON configuration file passed as parameter into the configuration object.
/// \param fileName The name of the JSON file containing the configuration.
///
/// \param inBundle The bundle in which we will look for the file.
///
///
/// throws:
/// <em>ConfigurationError</em> if there was any error while reading and parsing the file.
- (BOOL)readFromFileWithFileName:(NSString * _Nonnull)fileName inBundle:(NSBundle * _Nonnull)bundle error:(NSError * _Nullable * _Nullable)error;
- (BOOL)readFromDataWithData:(NSData * _Nonnull)data error:(NSError * _Nullable * _Nullable)error;
///
/// returns:
/// True if the configuration is correct and can be used to initialize
/// the Intelligence SDK.
@property (nonatomic, readonly) BOOL isValid;
///
/// returns:
/// True if there is a missing property in the configuration
@property (nonatomic, readonly) BOOL hasMissingProperty;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


@interface Intelligence (SWIFT_EXTENSION(IntelligenceSDK))
@end

/// An enum with the environments to which the SDK can be pointing to.
typedef SWIFT_ENUM(NSInteger, Environment) {
/// Local Environment
  EnvironmentLocal = 0,
/// Development Environment
  EnvironmentDevelopment = 1,
/// Integration Environment
  EnvironmentIntegration = 2,
/// UAT Environment
  EnvironmentUat = 3,
/// Staging Environment
  EnvironmentStaging = 4,
/// Production Environment
  EnvironmentProduction = 5,
};


/// Mandatory public protocol developers must implement in order to respond to events correctly.
SWIFT_PROTOCOL_NAMED("IntelligenceDelegate")
@protocol INTDelegate
/// Credentials provided are incorrect.
/// Will not distinguish between incorrect client or user credentials.
- (void)credentialsIncorrectFor:(Intelligence * _Nonnull)intelligence;
/// Account has been disabled and no longer active.
/// Credentials are no longer valid.
- (void)accountDisabledFor:(Intelligence * _Nonnull)intelligence;
/// Account has failed to authentication multiple times and is now locked.
/// Requires an administrator to unlock the account.
- (void)accountLockedFor:(Intelligence * _Nonnull)intelligence;
/// This error and description is only returned from the Validate endpoint
/// if providing an invalid or expired token.
- (void)tokenInvalidOrExpiredFor:(Intelligence * _Nonnull)intelligence;
/// Unable to create SDK user, this may occur if a user with the randomized
/// credentials already exists (highly unlikely) or your Application is
/// configured incorrectly and has the wrong permissions.
- (void)userCreationFailedFor:(Intelligence * _Nonnull)intelligence;
/// User is required to login again, developer must implement this method
/// you may present a ‘Login Screen’ or silently call identity.login with
/// stored credentials.
- (void)userLoginRequiredFor:(Intelligence * _Nonnull)intelligence;
/// Unable to assign provided sdk_user_role to your newly created user.
/// This may occur if the Application is configured incorrectly in the backend
/// and doesn’t have the correct permissions or the role doesn’t exist.
- (void)userRoleAssignmentFailedFor:(Intelligence * _Nonnull)intelligence;
@end


/// Implement the LocationModuleDelegate in order to be notified of events that
/// occur related to the location module.
SWIFT_PROTOCOL_NAMED("LocationModuleDelegate")
@protocol INTLocationModuleDelegate
@optional
/// Called when the user enters into a monitored geofence.
/// \param location The location module.
///
/// \param geofence The geofence that was entered.
///
- (void)intelligenceLocationWithLocation:(id <INTLocationModuleProtocol> _Nonnull)location didEnterGeofence:(INTGeofence * _Nonnull)geofence;
/// Called when the user exits a monitored geofence.
/// \param location The location module.
///
/// \param geofence The geofence that was exited.
///
- (void)intelligenceLocationWithLocation:(id <INTLocationModuleProtocol> _Nonnull)location didExitGeofence:(INTGeofence * _Nonnull)geofence;
/// Called when the a geofence has successfully started its monitoring.
/// \param location The location module.
///
/// \param geofence The geofence that started the monitoring.
///
- (void)intelligenceLocationWithLocation:(id <INTLocationModuleProtocol> _Nonnull)location didStartMonitoringGeofence:(INTGeofence * _Nonnull)didStartMonitoringGeofence;
/// Called when an error occured while we tried to start monitoring a geofence. This is likely to
/// be either that you passed the limit of geofences to monitor, or that the user has not granted
/// location permissions for your app.
/// \param location The location module.
///
/// \param geofence The geofence that failed to be monitored.
///
- (void)intelligenceLocationWithLocation:(id <INTLocationModuleProtocol> _Nonnull)location didFailMonitoringGeofence:(INTGeofence * _Nonnull)didFailMonitoringGeofence;
/// Called when a geofence is no longer monitored.
/// \param location The location module.
///
/// \param geofence The geofence that stopped being monitored
///
- (void)intelligenceLocationWithLocation:(id <INTLocationModuleProtocol> _Nonnull)location didStopMonitoringGeofence:(INTGeofence * _Nonnull)didStopMonitoringGeofence;
@end


/// The Intelligence Location module protocol. Provides geofence downloading and tracking functionality.
SWIFT_PROTOCOL_NAMED("LocationModuleProtocol")
@protocol INTLocationModuleProtocol <ModuleProtocol>
/// Downloads a list of geofences using the given query details.
/// \param queryDetails The geofence query to retrieve.
///
/// \param callback The callback that will be notified upon success/error.
/// The callback receives either an array of geofences or an NSError.
///
- (void)downloadGeofences:(INTGeofenceQuery * _Nonnull)queryDetails callback:(void (^ _Nullable)(NSArray<INTGeofence *> * _Nullable, NSError * _Nullable))callback;
///
/// returns:
/// True if there are geofences being currently monitored.
- (BOOL)isMonitoringGeofences SWIFT_WARN_UNUSED_RESULT;
/// Starts monitoring the given geofences.
/// \param geofences The geofences to monitor. If an error occurs during the monitoring,
/// the locationDelegate will be notified asynchronously.
///
- (void)startMonitoringGeofences:(NSArray<INTGeofence *> * _Nonnull)geofences;
/// Stops monitoring the geofences, and flushes the ones the location module keeps.
- (void)stopMonitoringGeofences;
/// Sets the location accuracy to use when monitoring regions. Defaults to kCLLocationAccuracyHundredMeters.
/// \param accuracy The accuracy
///
- (void)setLocationAccuracy:(CLLocationAccuracy)accuracy;
/// Geofences array, loaded from Cache on startup but updated with data from server if network is available.
/// When updated it will set the location manager to monitor the given geofences if we have permissions.
/// If we don’t have permissions it will do nothing, and if we don’t receive any geofence, we will
/// stop monitoring the previous geofences.
/// As a result, this holds the list of geofences that are currently monitored if we have permissions.
@property (nonatomic, readonly, copy) NSArray<INTGeofence *> * _Nullable geofences;
/// The delegate that will be notified upon entering/exiting a geofence.
@property (nonatomic, strong) id <INTLocationModuleDelegate> _Nullable locationDelegate;
/// set this property to true if you want to include location in all of your intelligence events. default value is
/// false. location permissions are required to granted before this property is used which is the caller’s
/// responsibility. for more information, read the documentation.
@property (nonatomic) BOOL includeLocationInEvents;
@end



@interface NSError (SWIFT_EXTENSION(IntelligenceSDK))
@end

/// Enumeration to list the errors that can occur in any request.
typedef SWIFT_ENUM(NSInteger, RequestError) {
/// Error to return when parsing JSON fails.
  RequestErrorParseError = 2001,
/// Error to return if user doesn’t have access to a particular API.
  RequestErrorAccessDeniedError = 2002,
/// Error to return if user is offline.
  RequestErrorInternetOfflineError = 2003,
/// Error to return if the user is not authenticated.
  RequestErrorUnauthorized = 2004,
/// Error to return if the user’s role does not grant them access to this method.
  RequestErrorForbidden = 2005,
/// Error to return if an error occurs that we can not handle.
  RequestErrorUnhandledError = 2006,
};
static NSString * _Nonnull const RequestErrorDomain = @"IntelligenceSDK.RequestError";


/// Event that the developer can fire once a screen has been viewed
SWIFT_CLASS_NAMED("ScreenViewedEvent")
@interface INTScreenViewedEvent : INTEvent
- (nonnull instancetype)initWithScreenName:(NSString * _Nonnull)screenName viewingDuration:(NSTimeInterval)viewingDuration OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithType:(NSString * _Nonnull)type value:(double)value targetId:(NSString * _Nullable)targetId metadata:(NSDictionary<NSString *, id> * _Nullable)metadata SWIFT_UNAVAILABLE;
@end


@interface NSURLSession (SWIFT_EXTENSION(IntelligenceSDK))
@end


@interface NSUserDefaults (SWIFT_EXTENSION(IntelligenceSDK))
@end

#pragma clang diagnostic pop
