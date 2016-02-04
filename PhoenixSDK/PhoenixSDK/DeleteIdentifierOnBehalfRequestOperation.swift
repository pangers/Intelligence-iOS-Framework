//
//  DeleteIdentifierOnBehalfRequestOperation.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 27/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

class DeleteIdentifierOnBehalfRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    let token: String
    
    required init(token: String, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        self.token = token
        
        super.init()
        
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.phx_URLRequestForIdentifierDeletionOnBehalf(token, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(token: token, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        copy.timesToRetry = timesToRetry
        
        return copy
    }
}
