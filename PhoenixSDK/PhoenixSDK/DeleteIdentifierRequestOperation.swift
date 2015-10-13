//
//  DeleteIdentifierRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class DeleteIdentifierRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    let tokenId: Int
    
    required init(tokenId: Int, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        self.tokenId = tokenId
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.phx_URLRequestForIdentifierDeletion(tokenId, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        
        if outputErrorCode() == "object_notfound" {
            output?.error = NSError(domain: IdentityError.domain, code: IdentityError.DeviceTokenNotRegisteredError.rawValue, userInfo: nil)
            return
        }
        
        if handleError(IdentityError.domain, code: IdentityError.DeviceTokenUnregistrationError.rawValue) {
            return
        }
        
        guard let returnedId = self.output?.data?.phx_jsonDictionary?["Id"] as? Int where returnedId == tokenId else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(tokenId: tokenId, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
}