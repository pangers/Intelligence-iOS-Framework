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
    
    required init(token: String, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.tokenString = token
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = URLRequest.int_URLRequestForIdentifierCreation(tokenString: tokenString, oauth: oauth!, configuration: configuration!, network: network!)

        sharedIntelligenceLogger.log(message: request.description);

        output = network?.sessionManager?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            return
        }
        
        guard let data = outputArrayFirstDictionary(), let returnedId = data["Id"] as? Int else {
            output?.error = NSError(code: RequestError.parseError.rawValue)
           
            if let msg = output?.error?.descriptionWith(urlRequest: request){
                sharedIntelligenceLogger.log(message: msg);
            }
            
            return
        }
        
        tokenId = returnedId
    
        if let httpResponse = output?.response as? HTTPURLResponse {
            sharedIntelligenceLogger.log(message: httpResponse.description);
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(token: tokenString, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
    
}
