//
//  PhoenixDataObjects.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

// MARK: the constants of the JSON keys.
private let idKey = "Id"
private let usernameKey = "Username"
private let passwordKey = "Password"
private let firstNameKey = "FirstName"
private let lastNameKey = "LastName"
private let avatarURLKey = "AvatarUrl"
private let companyIdKey = "CompanyId"
private let lockingCountKey = "LockingCount"
private let referenceKey = "Reference"
private let isActiveKey = "IsActive"
private let metadataKey = "MetaData"
private let userTypeKey = "UserTypeId"

private let invalidUserId = Int.min

/// The user types that the SDK supports
public enum UserType : String {
    
    /// Regular user
    case User = "User"
    
}

extension Phoenix {

    /// The user class implementation
    @objc(PHXPhoenixUser) public final class User : NSObject {
        
        /// The user Id as a let
        @objc public let userId:Int
        
        /// The company Id as a let. Should be fetched from the Configuration of Phoenix.
        @objc public  var companyId:Int
        
        /// The username
        @objc public var username:String
        
        /// The password
        @objc public var password:String?
        
        /// The firstname
        @objc public var firstName:String
        
        /// The last name
        @objc public var lastName:String?
        
        /// The avatar URL
        @objc public var avatarURL:String?
        
        /// Default initializer receiveing all parameters required.
        public init(userId:Int, companyId:Int, username:String, password:String?, firstName:String, lastName:String?, avatarURL:String?) {
            self.userId = userId
            self.companyId = companyId
            self.username = username
            self.password = password
            self.firstName = firstName
            self.lastName = lastName
            self.avatarURL = avatarURL
        }
        
        /// Convenience initializer with no user id.
        convenience public init(companyId:Int, username:String, password:String?, firstName:String, lastName:String?, avatarURL:String?) {
            self.init(userId:invalidUserId, companyId:companyId, username:username, password:password, firstName:firstName, lastName:lastName, avatarURL:avatarURL)
        }
        
        /// Parses the JSON dictionary to create the User object. If it fails to
        /// parse all values, it will return nil.
        ///
        /// - Parameters:
        ///     - withJSON: The json dictionary as obtained from the backend.
        ///     - withConfiguration: The configuration that holds the company Id.
        convenience internal init?(withJSON json:JSONDictionary, withConfiguration configuration:PhoenixConfigurationProtocol) {
            guard let userId = json[idKey] as? Int,
            let username = json[usernameKey] as? String,
            let firstName = json[firstNameKey] as? String else {
                    return nil
            }
            let lastName = json[lastNameKey] as? String
            self.init(userId:userId, companyId:configuration.companyId, username:username, password:nil, firstName:firstName, lastName:lastName, avatarURL:nil)
        }
        
        /// Creates a user from a data response from the backend.
        /// - Parameters:
        ///     - data: The data obtained from the backend.
        ///     - withConfiguration: The configuration object.
        class func fromResponseData(data:NSData, withConfiguration:PhoenixConfigurationProtocol) -> User? {
            guard let usersArray = data.phx_jsonDictionary?["Data"] as? JSONArray,
                let userDictionary = usersArray.first as? JSONDictionary else {
                return nil
            }
            
            return User(withJSON: userDictionary, withConfiguration: withConfiguration)
        }
        
        /// Checks if the user Id provided is a valid user Id.
        class func isUserIdValid(userId:Int) -> Bool {
            return userId != invalidUserId && userId >= 0
        }
        
        /// The locking count will always be 0 and should be ignored by the developer
        var lockingCount:Int {
            return 0
        }
        
        /// The reference will be empty and should be ignored by the developer
        var reference:String {
            return ""
        }
        
        /// Is active is true. Developers should ignore this value
        var isActive:Bool {
            return true
        }
        
        /// The metadata will be empty and should be ignored.
        var metadata:String {
            return ""
        }
        
        /// The user type will always be User.
        var userTypeId:UserType {
            return .User
        }
        
        /// - Returns: Provides a JSONDictionary with the user data.
        func toJSON() -> JSONDictionary {
            var dictionary:JSONDictionary = [
                companyIdKey: self.companyId,
                usernameKey: self.username,
                firstNameKey: self.firstName,
                lockingCountKey: self.lockingCount,
                referenceKey: self.reference,
                isActiveKey: self.isActive,
                metadataKey: self.metadata,
                userTypeKey: self.userTypeId.rawValue,
            ]
            dictionary ?+= (lastNameKey, lastName)
            dictionary ?+= (passwordKey, password)
            dictionary ?+= (avatarURLKey, avatarURL)
            // If we have the user Id add it.
            if userId != invalidUserId {
                dictionary[idKey] = userId
            }
            return dictionary
        }
        
        /// - Returns: True if the user is valid to be sent to a create request.
        var isValidToCreate:Bool {
            guard let password = password else {
                return false
            }
            
            let hasUsername = !username.isEmpty
            let hasPassword = !password.isEmpty
            let hasCompanyId = companyId > 0
            let hasFirstName = !firstName.isEmpty
            
            return (hasCompanyId && hasUsername && hasPassword && hasFirstName)
        }
    }
}

/// The minimum number of characters a password needs to have to be secure.
private let strongPasswordCharacterCountThreshold = 8

/// Extension to provide password security requirements validation.
extension Phoenix.User {
    
    /// A password is considered secure if it has at least 8 characters, and uses
    /// at least a number and a letter.
    /// - Returns: True if the password is secure.
    func isPasswordSecure() -> Bool {
        guard let password = self.password else {
            return false
        }
        
        /// - Returns: true if the character is between 0 and 9.
        func isDigit(char:Character) -> Bool {
            return char >= "0" && char <= "9"
        }

        /// - Returns: true if the character is **not** between 0 and 9.
        func isLetter(char:Character) -> Bool {
            return !isDigit(char)
        }

        // perform the checks
        let passwordHasCorrectLength = password.characters.count >= strongPasswordCharacterCountThreshold
        let passwordContainsNumbers = password.characters.filter(isDigit).count > 0
        let passwordContainsLetters = password.characters.filter(isLetter).count > 0

        // verify all checks are satisfied.
        return passwordHasCorrectLength && passwordContainsNumbers && passwordContainsLetters
    }
    
}