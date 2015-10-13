//
//  NSData.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal extension NSData {
    
    func hexString() -> String {
        // Create a byte array our length
        var dataAsByteArray = [UInt8](count: length, repeatedValue: 0x0)
        
        // Copy our bytes into the byte array
        self.getBytes(&dataAsByteArray, length: length)
        
        // Create hex string
        let dataAsHexString = dataAsByteArray.map { String(format: "%02lx", $0) }.joinWithSeparator("")
        
        return dataAsHexString
    }
    
}