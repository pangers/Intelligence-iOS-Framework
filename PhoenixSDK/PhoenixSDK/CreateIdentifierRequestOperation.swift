//
//  CreateIdentifierRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 12/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class CreateIdentifierRequestOperation : PhoenixOAuthOperation, NSCopying {
    
    var tokenId: Int?
    
    private let tokenString: String
    
    required init(token: String, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        self.tokenString = token
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.phx_URLRequestForIdentifierCreation(tokenString, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager!.phx_executeSynchronousDataTaskWithRequest(request)
        
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
        return self.dynamicType.init(token: tokenString, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}