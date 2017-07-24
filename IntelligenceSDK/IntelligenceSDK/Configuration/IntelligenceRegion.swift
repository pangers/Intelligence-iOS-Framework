//
//  IntelligenceRegion.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

public extension Intelligence {

    /// An enum with the regions to which the SDK can be pointing to.

    @objc public enum Region: Int {

        /// US Region
        case unitedStates

        /// AU Region
        case australia

        /// EU Region
        case europe

        /// SG Region
        case singapore


        /// This init method should be used to extract the region from a configuration file and turn it into an enum value
        /// The values that should be used are "US", "AU", "EU" and "SG"
        /// If another value is used this will return nil
        init?(code: String) {
            switch code {
            case "US":
                self = .unitedStates
            case "AU":
                self = .australia
            case "EU":
                self = .europe
            case "SG":
                self = .singapore
            default:
                return nil
            }
        }

        var regionCode: String? {
            switch self {
            case .unitedStates:
                return "US"
            case .australia:
                return "AU"
            case .europe:
                return "EU"
            case .singapore:
                return "SG"
            }
        }
    }

}
