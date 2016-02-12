//
//  DeleteIdentifierRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
class DeleteIdentifierRequestOperation : IntelligenceAPIOperation, NSCopying {
    
    let tokenId: Int
    
    required init(tokenId: Int, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: IntelligenceAPICallback) {
        self.tokenId = tokenId
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.int_URLRequestForIdentifierDeletion(tokenId, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.int_executeSynchronousDataTaskWithRequest(request)
        
        if errorInData() == "object_notfound" {
            output?.error = NSError(code: IdentityError.DeviceTokenNotRegisteredError.rawValue)
            return
        }
        
        if handleError() {
            return
        }
        
        guard let jsonDictionary = self.output?.data?.int_jsonDictionary,
            let data = jsonDictionary["Data"],
            let dataObject = data.lastObject,
            let returnedId = dataObject?["Id"] as? Int where returnedId == tokenId else {
                output?.error = NSError(code: RequestError.ParseError.rawValue)
                return
            }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(tokenId: tokenId, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}