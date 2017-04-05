//
//  AnalyticsRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles sending analytics.
/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
internal final class AnalyticsRequestOperation: IntelligenceAPIOperation, NSCopying {
    
    private let eventsJSON: JSONDictionaryArray
    
    private let InvalidRequestErrorCode = "invalid_request"
    
    required init(json: JSONDictionaryArray, oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, callback: @escaping IntelligenceAPICallback) {
        self.eventsJSON = json
        super.init()
        self.callback = callback
        self.configuration = configuration
        self.oauth = oauth
        self.network = network
    }
    
    override func main() {
        super.main()
        assert(network != nil && configuration != nil)
        let request = URLRequest.int_URLRequestForAnalytics(json: eventsJSON, oauth: oauth!, configuration: configuration!, network: network!)
        sharedIntelligenceLogger.log(message: request.description);
        
        output = session?.int_executeSynchronousDataTask(with: request)
        
        // Swallowing the invalid request so that the events sent are cleared.
        // This error is not recoverable and we need to purge the data.
        if let httpResponse = output?.response as? HTTPURLResponse {
            if httpResponse.statusCode == HTTPStatusCode.badRequest.rawValue && errorInData() == InvalidRequestErrorCode {
                output?.error = NSError(code: AnalyticsError.oldEventsError.rawValue)
                
                if let error = output?.error{
                    sharedIntelligenceLogger.log(message: error.descriptionWith(urlRequest: request, response:httpResponse));
                }
                
                return
            }
        }

        if handleError() {
            return
        }
        
        if outputArray()?.count != eventsJSON.count {
            output?.error = NSError(code: RequestError.parseError.rawValue)
           
            if let msg = output?.error?.descriptionWith(urlRequest: request){
                sharedIntelligenceLogger.log(message: msg);
            }
            
            return
        }
        
        var eventNames = eventsJSON.map { (event) -> String in
            var type:String = ""
            for (key, value) in event {
                if (key == "EventType"){
                    type = value as! String;
                    break
                }
            }
            return type;
        }
        
        //info
        var str = String(format:"Sending Events Sucessfull : %@",eventNames.description)
        sharedIntelligenceLogger.log(message:str)
        
        if let httpResponse = output?.response as? HTTPURLResponse {
               sharedIntelligenceLogger.log(message: httpResponse.description);
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(json: eventsJSON, oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
        
        return copy
    }
    
}
