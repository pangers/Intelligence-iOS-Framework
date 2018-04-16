//
//  IntelligenceKeychain.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

final class IntelligenceKeychain: TSDKeychain, IntelligenceOAuthStorage {

    init(account: String = "IntelligenceSDK") {
        super.init(account, service: "com.tigerspike.IntelligenceSDK")
    }

    private func keyValues() -> NSMutableDictionary {
        return executeManagedRequest(requestType: .read)?.mutableCopy() as? NSMutableDictionary ?? NSMutableDictionary()
    }

    private func object(for key: String) -> Any? {
        let value = keyValues()[key]
        return value
    }

    private func setObject(value: Any, for key: String) {
        let values = keyValues()
        values[key] = value
        executeManagedRequest(requestType: .update, keyValues: values)
    }

    private func removeObject(for key: String) {
        let values = keyValues()
        values.removeObject(forKey: key)
        executeManagedRequest(requestType: .update, keyValues: values)
    }

    // Subscript implementation
    @objc subscript(index: String) -> Any? {
        get {
            // return an appropriate subscript value here
            return object(for: index)
        }
        set(newValue) {
            // perform a suitable setting action here
            guard let value = newValue else {
                removeObject(for: index)
                return
            }

            setObject(value: value, for: index)
        }
    }

    public func clearAllData() {
        let values = keyValues()
        executeManagedRequest(requestType: .delete, keyValues: values)
    }
}
