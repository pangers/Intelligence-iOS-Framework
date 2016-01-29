//
//  InstallationRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class InstallationRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    var installation: Installation!
    
    required init(installation: Installation, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
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
    
    func parse() {
        if handleError() {
            return
        }
        
        if installation.updateWithJSON(outputArrayFirstDictionary()) == false {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(installation: installation, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}