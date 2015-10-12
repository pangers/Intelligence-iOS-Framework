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
        
        if handleError(IdentityError.domain, code: IdentityError.RegisterDeviceTokenError.rawValue) {
            return
        }
        
        guard let data = outputArrayFirstDictionary() else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        
        print(data)
        
        // TODO: Parse ID
        tokenId = -1
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(tokenData: tokenData, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
    
}