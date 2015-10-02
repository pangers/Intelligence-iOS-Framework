//
//  PhoenixInstallationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixInstallationRequestOperation : PhoenixOAuthOperation {
    
    var installation: Phoenix.Installation!
    
    init(installation: Phoenix.Installation, oauth: PhoenixOAuth, configuration: Phoenix.Configuration, network: Network) {
        super.init()
        self.configuration = configuration
        self.network = network
        self.oauth = oauth
        self.installation = installation
    }
    
    func parse(withErrorCode errorCode: Int) {
        if handleError(InstallationError.domain, code: errorCode) {
            return
        }
        
        if installation.updateWithJSON(outputDictionary()) == false {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
    
}