//
//  TSDKeychain.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal enum TSDKeychainRequestType {
    case delete, update, read
}

internal enum TSDKeychainError: Error {
    case errorCode(Int), notFoundError
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
        let requestReference = request as CFDictionary
        var result: AnyObject?
        var status: OSStatus?
        
        switch type {
        case .read:
            status = withUnsafeMutablePointer(to: &result) { SecItemCopyMatching(requestReference, UnsafeMutablePointer($0)) }
        case .delete:
            status = SecItemDelete(requestReference)
        case .update:
            SecItemDelete(requestReference)
            status = withUnsafeMutablePointer(to: &result) { SecItemAdd(requestReference, UnsafeMutablePointer($0)) }
        }
        
        if let status = status {
            let statusCode = Int(status)
            if statusCode != Int(errSecSuccess) {
                sharedIntelligenceLogger.logger?.error("Intelligence keychain error")
                throw TSDKeychainError.errorCode(statusCode)
            }
            var resultsDictionary: NSDictionary?
            if result != nil && type == .read && status == errSecSuccess {
                if let data = result as? Data {
                    resultsDictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary
                }
            }
            return resultsDictionary
        } else {
            sharedIntelligenceLogger.logger?.error("Intelligence keychain item not found")
            throw TSDKeychainError.notFoundError
        }
    }
    
    private func createRequest(requestType: TSDKeychainRequestType, keyValues: NSDictionary? = nil) -> NSMutableDictionary {
        let options = NSMutableDictionary()
        options[String(kSecAttrAccount)] = keychainAccount
        options[String(kSecAttrService)] = keychainService
        options[String(kSecAttrSynchronizable)] = false
        options[String(kSecClass)] = kSecClassGenericPassword
        switch requestType {
        case .update:
            if let keyValues = keyValues {
                options[String(kSecValueData)] = NSKeyedArchiver.archivedData(withRootObject: keyValues)
            }
        case .read:
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
    @discardableResult
    func executeRequest(requestType: TSDKeychainRequestType, keyValues: NSDictionary? = nil) throws -> NSDictionary? {
        return try performRequest(request: createRequest(requestType: requestType, keyValues: keyValues), requestType: requestType)
    }
    
    /// Execute a new keychain storage request optionally providing key-values.
    /// Error will be consumed and ignored.
    /// - SeeAlso: executeRequest(requestType:keyValues:)
    /// - Parameters:
    ///     - requestType: Update, Read, or Delete request
    ///     - keyValues: Dictionary containing archivable key-values
    /// - Returns: Previously stored key-values
    @discardableResult
    func executeManagedRequest(requestType: TSDKeychainRequestType, keyValues: NSDictionary? = nil) -> NSDictionary? {
        do {
            return try executeRequest(requestType: requestType, keyValues: keyValues)
        }
        catch { }
        return nil
    }
}
