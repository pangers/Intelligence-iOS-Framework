//
//  TSDKeychain.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal enum TSDKeychainRequestType {
    case Delete, Update, Read
}

internal enum TSDKeychainError: ErrorType {
    case ErrorCode(Int), NotFoundError
}

internal class TSDKeychain {
    
    /// Value for kSecAttrAccount
    private let keychainAccount: String
    
    /// Value for kSecAttrService
    private let keychainService: String
    
    /// Create a new instance providing kSecAttrAccount and kSecAttrService.
    init(_ account: String, service: String) {
        keychainAccount = account
        keychainService = service
    }
    
    private func performRequest(request: NSMutableDictionary, requestType: TSDKeychainRequestType) throws -> NSDictionary? {
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
    
    private func createRequest(requestType: TSDKeychainRequestType, keyValues: NSDictionary? = nil) -> NSMutableDictionary {
        let options = NSMutableDictionary()
        options[String(kSecAttrAccount)] = keychainAccount
        options[String(kSecAttrService)] = keychainService
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
            break
        }
        return options
    }
    
    /// Execute a new keychain storage request optionally providing key-values.
    /// Error will be thrown if something fails.
    /// - Parameters:
    ///     - requestType: Update, Read, or Delete request
    ///     - keyValues: Dictionary containing archivable key-values
    /// - Returns: Previously stored key-values or error
    func executeRequest(requestType: TSDKeychainRequestType, keyValues: NSDictionary? = nil) throws -> NSDictionary? {
        return try performRequest(createRequest(requestType, keyValues: keyValues), requestType: requestType)
    }
    
    /// Execute a new keychain storage request optionally providing key-values.
    /// Error will be consumed and ignored.
    /// - SeeAlso: executeRequest(requestType:keyValues:)
    /// - Parameters:
    ///     - requestType: Update, Read, or Delete request
    ///     - keyValues: Dictionary containing archivable key-values
    /// - Returns: Previously stored key-values
    func executeManagedRequest(requestType: TSDKeychainRequestType, keyValues: NSDictionary? = nil) -> NSDictionary? {
        do {
            return try executeRequest(requestType, keyValues: keyValues)
        }
        catch { }
        return nil
    }
}
