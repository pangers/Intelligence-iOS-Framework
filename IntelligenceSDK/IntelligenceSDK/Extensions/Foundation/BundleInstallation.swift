//
//  NSBundleInstallation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 12/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

protocol IntelligenceApplicationVersionProtocol {
    /// - Returns: Current app version.
    var int_applicationVersionString: String? {get}
}

extension Bundle: IntelligenceApplicationVersionProtocol {
    
    var int_applicationVersionString: String? {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = infoDictionary?["CFBundleVersion"] as? String else { return nil }
        return "\(version) (\(build))"
    }
    
}
