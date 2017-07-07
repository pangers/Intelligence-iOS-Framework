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
    
    required init(tokenId: Int, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.tokenId = tokenId
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = URLRequest.int_URLRequestForIdentifierDeletion(tokenId: tokenId, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.int_executeSynchronousDataTask(with: request)
        
        if errorInData() == "object_notfound" {
            output?.error = NSError(code: IdentityError.deviceTokenNotRegisteredError.rawValue)
            return
        }
        
        if handleError() {
            return
        }
        
        guard let jsonDictionary = self.output?.data?.int_jsonDictionary,
            let data = jsonDictionary["Data"] as? [Any],
            let dataObject = data.last as? JSONDictionary,
            let returnedId = dataObject["Id"] as? Int, returnedId == tokenId else {
                output?.error = NSError(code: RequestError.parseError.rawValue)
                return
            }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(tokenId: tokenId, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
}
