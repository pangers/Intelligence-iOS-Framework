//
//  DeleteIdentifierRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class DeleteIdentifierRequestOperation : PhoenixAPIOperation, NSCopying {
    
    let tokenId: Int
    
    required init(tokenId: Int, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixAPICallback) {
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
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        
        if errorInData() == "object_notfound" {
            output?.error = NSError(code: IdentityError.DeviceTokenNotRegisteredError.rawValue)
            return
        }
        
        if handleError() {
            return
        }
        
        guard let jsonDictionary = self.output?.data?.phx_jsonDictionary,
            let data = jsonDictionary["Data"],
            let dataObject = data.lastObject,
            let returnedId = dataObject?["Id"] as? Int where returnedId == tokenId else {
                output?.error = NSError(code: RequestError.ParseError.rawValue)
                return
            }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(tokenId: tokenId, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        copy.timesToRetry = timesToRetry
        
        return copy
    }
}