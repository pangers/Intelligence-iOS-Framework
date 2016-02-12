//
//  CreateIdentifierRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
class CreateIdentifierRequestOperation : IntelligenceAPIOperation, NSCopying {
    
    var tokenId: Int?
    
    private let tokenString: String
    
    required init(token: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: IntelligenceAPICallback) {
        self.tokenString = token
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.int_URLRequestForIdentifierCreation(tokenString, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.int_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
        
        guard let data = outputArrayFirstDictionary(), returnedId = data["Id"] as? Int else {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
        
        tokenId = returnedId
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(token: tokenString, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
    
}