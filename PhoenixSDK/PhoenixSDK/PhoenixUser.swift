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
    var userId:Int { get }
    
    /// The company id. Non modifiable. Should be fetched from the Configuration of Phoenix.
    var companyId:String {get}
    
    /// The username
    var username:String {get set}
    
    /// The password
    var password:String {get set}
    
    /// The firstname
    var firstName:String {get set}
    
    /// The lastname
    var lastName:String {get set}
    
    /// The avatar URL
    var avatarURL:String {get set}
    
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
        return [
            idKey:self.userId,
            companyIdKey: self.companyId,
            usernameKey: self.username,
            passwordKey: self.password,
            firstNameKey: self.firstName,
            lastNameKey: self.lastName,
            avatarURLKey: self.avatarURL,
            lockingCountKey: self.lockingCount,
            referenceKey: self.reference,
            isActiveKey: self.isActive,
            metadataKey: self.metadata,
            userTypeKey: self.userTypeId.rawValue
        ]
    }
}


extension Phoenix {

    /// The user class implementation
    public class User : PhoenixUser {
        
        /// The user Id as a let
        public let userId:Int
        
        /// The company Id as a let.
        public let companyId:String
        
        /// the username
        public var username:String
        
        /// The password
        public var password:String
        
        /// The first name
        public var firstName:String
        
        /// The last name
        public var lastName:String
        
        /// The avatar url
        public var avatarURL:String
        
        /// Parses the JSON dictionary to create the User object. If it fails to
        /// parse all values, it will return nil.
        ///
        /// - Parameters:
        ///     - withJSON: The json dictionary as obtained from the backend.
        ///     - withConfiguration: The configuration that holds the company Id.
        init?(withJSON json:JSONDictionary, withConfiguration configuration:Configuration) {
            self.username = ""
            self.password = ""
            self.firstName = ""
            self.lastName = ""
            self.avatarURL = ""
            self.companyId = configuration.companyId

            guard let id = json[idKey] as? Int,
                let username = json[usernameKey] as? String,
                let password = json[passwordKey] as? String,
                let firstName = json[firstNameKey] as? String,
                let lastName = json[lastNameKey] as? String,
                let avatarURL = json[avatarURLKey] as? String else {
                    self.userId = 0
                    return nil
            }
            
            self.userId = id
            self.username = username
            self.password = password
            self.firstName = firstName
            self.lastName = lastName
            self.avatarURL = avatarURL
        }
        
        
    }
    
}
