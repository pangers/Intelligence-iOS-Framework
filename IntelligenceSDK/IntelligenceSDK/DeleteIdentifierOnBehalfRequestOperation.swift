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
    
    required init(token: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: IntelligenceAPICallback) {
        self.token = token
        
        super.init()
        
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.int_URLRequestForIdentifierDeletionOnBehalf(token, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.int_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(token: token, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
