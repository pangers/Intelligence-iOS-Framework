//
//  PhoenixDataObjects.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

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

public enum UserType : String {
    
    case User = "User"
    
}

public protocol PhoenixUser {
    
    var userId:Int { get }
    var companyId:String {get}
    
    var username:String {get set}
    var password:String {get set}
    var firstName:String {get set}
    var lastName:String {get set}
    var avatarURL:String {get set}
    
}

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
    
    public class User : PhoenixUser {
        
        public let userId:Int
        public let companyId:String
        
        public var username:String
        public var password:String
        public var firstName:String
        public var lastName:String
        public var avatarURL:String
        
        /// Parses the JSON dictionary and returns the data read.
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
