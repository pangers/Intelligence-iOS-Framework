//
//  InstallationRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
class InstallationRequestOperation: IntelligenceAPIOperation, NSCopying {

    var installation: Installation!

    required init(installation: Installation, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
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

        if installation.updateWithJSON(json: outputArrayFirstDictionary()) == false {
            output?.error = NSError(code: RequestError.parseError.rawValue)

            let str = String(format: "Parse error -- %@", (self.session?.description)!)
            sharedIntelligenceLogger.logger?.error(str)
            return
        }

        if let httpResponse = output?.response as? HTTPURLResponse {
                sharedIntelligenceLogger.logger?.debug(httpResponse.debugInfo)
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(installation: installation, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)

        return copy
    }

}
