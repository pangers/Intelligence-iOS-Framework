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
private let avatarURLKey = "AvatarURL"
private let companyIdKey = "CompanyId"
private let lockingCountKey = "LockingCount"
private let referenceKey = "Reference"
private let isActiveKey = "IsActive"
private let metadataKey = "MetaData"
private let userTypeKey = "UserTypeId"

/// The user types that the SDK supports
public enum UserType : String {
    
    /// Regular user
    case User = "User"
    
}

/// A protocol defining the Phoenix Users behaviour.
public protocol PhoenixUser {
    
    /// The user id. Non modifiable. The implementer should use a let.
    var userId:Int? { get }
    
    /// The company id. Non modifiable. Should be fetched from the Configuration of Phoenix.
    var companyId:Int {get}
    
    /// The username
    var username:String {get set}
    
    /// The password
    var password:String? {get set}
    
    /// The firstname
    var firstName:String {get set}
    
    /// The lastname
    var lastName:String? {get set}
    
    /// The avatar URL
    var avatarURL:String? {get set}
    
}

/// Extends phoenix user to provide the variables that should be disregarded by the user.
/// Also provides a toJSON method to return a JSON dictionary from the values of the user.
extension PhoenixUser {
    
    var lockingCount:Int {
        return 0
    }

    var reference:String {
        return ""
    }

    var isActive:Bool {
        return true
    }
    
    var metadata:String {
        return ""
    }
    
    var userTypeId:UserType {
        return .User
    }
    
    func toJSON() -> JSONDictionary {
        var dictionary:JSONDictionary = [
            companyIdKey: self.companyId,
            usernameKey: self.username,
            firstNameKey: self.firstName,
            lockingCountKey: self.lockingCount,
            referenceKey: self.reference,
            isActiveKey: self.isActive,
            metadataKey: self.metadata,
            userTypeKey: self.userTypeId.rawValue
        ]
        func add(value: AnyObject?, key: String) {
            if let value = value {
                dictionary[key] = value
            }
        }
        add(lastName, key: lastNameKey)
        add(userId, key: idKey)
        add(password, key: passwordKey)
        add(avatarURL, key: avatarURLKey)
        return dictionary
    }
}


extension Phoenix {

    /// The user class implementation
    public class User : PhoenixUser {
        
        /// The user Id as a let
        public let userId:Int?
        
        /// The company Id as a let.
        public let companyId:Int
        
        /// the username
        public var username:String
        
        /// The password
        public var password:String?
        
        /// The first name
        public var firstName:String
        
        /// The last name
        public var lastName:String?
        
        /// The avatar url
        public var avatarURL:String?
        
        /// Default initializer receiveing all parameters required.
        public init(userId:Int?, companyId:Int, username:String, password:String?, firstName:String, lastName:String?, avatarURL:String?) {
            self.userId = userId
            self.companyId = companyId
            self.username = username
            self.password = password
            self.firstName = firstName
            self.lastName = lastName
            self.avatarURL = avatarURL
        }
        
        /// Convenience initializer with no user id.
        convenience public init(companyId:Int, username:String, password:String?, firstName:String, lastName:String, avatarURL:String?) {
            self.init(userId:nil, companyId:companyId, username:username, password:password, firstName:firstName, lastName:lastName, avatarURL:avatarURL)
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
    }
}










