//
//  IntelligenceEnvironment.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

public extension Intelligence {

    /// An enum with the environments to which the SDK can be pointing to.

    @objc public enum Environment: Int {

        /// Local Environment
        case local

        /// Development Environment
        case development

        /// Integration Environment
        case integration

        /// UAT Environment
        case uat

        /// Staging Environment
        case staging

        /// Production Environment
        case production


        /// This init method should be used to extract the environment from a configuration file and turn it into an enum value
        /// The values that should be used are "local", "development", "integration", "uat", "staging" and "production"
        /// If another value is used this will return nil
        init?(code: String) {
            switch code {
            case "local":
                self = .local
            case "development":
                self = .development
            case "integration":
                self = .integration
            case "uat":
                self = .uat
            case "staging":
                self = .staging
            case "production":
                self = .production
            default:
                return nil
            }
        }

        var envString: String? {
            switch self {
            case .local: return "local"
            case .development: return "development"
            case .integration: return "integration"
            case .uat: return "uat"
            case .staging: return "staging"
            case .production: return "production"
            default: return nil
            }
            return nil
        }
    }

}
