//
//  InstallationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class InstallationRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    var installation: PhoenixInstallation!
    
    required init(installation: PhoenixInstallation, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.network = network
        self.oauth = oauth
        self.installation = installation
    }
    
    override func main() {
        super.main()
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
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(installation: installation, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}