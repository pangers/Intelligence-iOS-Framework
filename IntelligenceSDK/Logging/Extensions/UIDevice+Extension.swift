//
//  UIDevice+Extension.swift
//  IntelligenceSDK
//
//  Created by Chethan SP on 1/11/17.
//  Copyright © 2017 Tigerspike. All rights reserved.
//

import Foundation

extension UIDevice {
    public static var platform: String {
        var platfrom = ""
        #if os(iOS)
            platfrom = "iOS"
        #elseif os(watchOS)
            platfrom = "watchOS"
        #elseif os(tvOS)
            platfrom = "tvOS"
        #elseif os(OSX)
            platfrom = "OSX"
        #endif
        return platfrom
    }
}
