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
    
    internal var tokenString: String {
        // 18892
        // d3e3a7db07691f8f698e5139310cce50f5e2d2e36020e2f70187bf23b175ec00
        return tokenData.hexString()
    }
    private let tokenData: NSData
    
    required init(tokenData: NSData, oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        self.tokenData = tokenData
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.phx_URLRequestForIdentifierCreation(tokenString, oauth: oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        
        // Note: Hacky, we should ask for an error code.
        if let errorDescription = outputErrorDescription() where errorDescription.rangeOfString("assigned") != nil {
            output?.error = NSError(domain: IdentityError.domain, code: IdentityError.DeviceTokenAlreadyRegisteredError.rawValue, userInfo: nil)
            return
        }
        
        if handleError(IdentityError.domain, code: IdentityError.DeviceTokenRegistrationError.rawValue) {
            return
        }
        
        guard let data = outputArrayFirstDictionary(), returnedId = data["Id"] as? Int where returnedId > 0 else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        
        tokenId = returnedId
        
        print(returnedId)
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(tokenData: tokenData, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}