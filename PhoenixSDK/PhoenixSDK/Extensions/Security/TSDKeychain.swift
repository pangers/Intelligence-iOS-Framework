//
//  TSDKeychain.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal enum TSDKeychainRequestType: String {
    case Delete = "Delete"
    case Update = "Update"
    case Read = "Read"
}

internal enum TSDKeychainError: ErrorType {
    case ErrorCode(Int)
    case NotFoundError
}

class TSDKeychain {
    
    // MARK:- Helpers
    
    private static let PhoenixUser = "PhoenixSDK"
    private static let PhoenixService = "com.tigerspike.PhoenixSDK"
    
    private class func performRequest(request: NSMutableDictionary, requestType: TSDKeychainRequestType) throws -> NSDictionary? {
        let type = requestType
        let requestReference = request as CFDictionaryRef
        var result: AnyObject?
        var status: OSStatus?
        
        switch type {
        case .Read:
            status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(requestReference, UnsafeMutablePointer($0)) }
        case .Delete:
            status = SecItemDelete(requestReference)
        case .Update:
            SecItemDelete(requestReference)
            status = withUnsafeMutablePointer(&result) { SecItemAdd(requestReference, UnsafeMutablePointer($0)) }
        }
        
        if let status = status {
            let statusCode = Int(status)
            if statusCode != Int(errSecSuccess) {
                throw TSDKeychainError.ErrorCode(statusCode)
            }
            var resultsDictionary: NSDictionary?
            if result != nil && type == .Read && status == errSecSuccess {
                if let data = result as? NSData {
                    resultsDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSDictionary
                }
            }
            return resultsDictionary
        } else {
            throw TSDKeychainError.NotFoundError
        }
    }
    
    private class func createRequest(keyValues: NSDictionary?, requestType: TSDKeychainRequestType) -> NSMutableDictionary {
        let options = NSMutableDictionary()
        options[String(kSecAttrAccount)] = PhoenixUser
        options[String(kSecAttrService)] = PhoenixService
        options[String(kSecAttrSynchronizable)] = false
        options[String(kSecClass)] = kSecClassGenericPassword
        switch requestType {
        case .Update:
            if let keyValues = keyValues {
                options[String(kSecValueData)] = NSKeyedArchiver.archivedDataWithRootObject(keyValues)
            }
        case .Read:
            options[String(kSecReturnData)] = kCFBooleanTrue
            options[String(kSecMatchLimit)] = kSecMatchLimitOne
        default:
            // Exhaustive switch -_-
            requestType == requestType
        }
        return options
    }
    
    internal class func executeRequest(keyValues: NSDictionary?, requestType: TSDKeychainRequestType) throws -> NSDictionary? {
        return try performRequest(createRequest(keyValues, requestType: requestType), requestType: requestType)
    }
}
