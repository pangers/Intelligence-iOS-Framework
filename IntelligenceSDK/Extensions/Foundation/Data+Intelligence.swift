//
//  NSData.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension Data {

    func hexString() -> String {
        // Create a byte array our length
        var dataAsByteArray = [UInt8](repeating: 0x0, count: count)

        // Copy our bytes into the byte array
        self.copyBytes(to: &dataAsByteArray, count: count)

        // Create hex string
        let dataAsHexString = dataAsByteArray.map { String(format: "%02lx", $0) }.joined(separator: "")

        return dataAsHexString
    }

}
