//
//  NSBundleInstallation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 12/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

protocol PhoenixApplicationVersionProtocol {
    /// - Returns: Current app version.
    var phoenix_applicationVersionString: String? {get}
}

extension NSBundle: PhoenixApplicationVersionProtocol {
    
    var phoenix_applicationVersionString: String? {
        guard let version = infoDictionary?["CFBundleShortVersionString"] as? String, build = infoDictionary?["CFBundleVersion"] as? String else { return nil }
        return "\(version).\(build)"
    }
    
}