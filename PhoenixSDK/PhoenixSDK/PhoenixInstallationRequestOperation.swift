//
//  PhoenixInstallationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class PhoenixInstallationRequestOperation : PhoenixOAuthOperation {
    
    init(oauth: PhoenixOAuth, phoenix: Phoenix) {
        super.init()
        self.phoenix = phoenix
        self.oauth = oauth
    }
    
    func parse(withErrorCode errorCode: Int) {
        if output?.error != nil || self.outputErrorCode() != nil {
            output?.error = NSError(domain: InstallationError.domain, code: errorCode, userInfo: nil)
            return
        }
        
        if phoenix!.installation.updateWithJSON(outputDictionary()) == false {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
    
}