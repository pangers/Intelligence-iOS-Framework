//
//  DeleteIdentifierOnBehalfRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 27/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
class DeleteIdentifierOnBehalfRequestOperation : IntelligenceAPIOperation, NSCopying {
    
    let token: String
    
    required init(token: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.token = token
        
        super.init()
        
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = URLRequest.int_URLRequestForIdentifierDeletionOnBehalf(token: token, oauth: oauth!, configuration: configuration!, network: network!)
        
        sharedIntelligenceLogger.log(message: request.description);

        output = network!.sessionManager!.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            return
        }
        
        if let httpResponse = output?.response as? HTTPURLResponse {
            sharedIntelligenceLogger.log(message: httpResponse.description);
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(token: token, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
