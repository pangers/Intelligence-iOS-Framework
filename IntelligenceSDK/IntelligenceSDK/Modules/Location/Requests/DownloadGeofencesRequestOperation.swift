//
//  DownloadGeofencesRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles downloading geofences.
/// Inheritors must ensure all relevent fields will be copied by copyWithZone(zone:), which may require an override.
internal final class DownloadGeofencesRequestOperation: IntelligenceAPIOperation, NSCopying {
    
    /// Array containing Geofence objects.
    var geofences: [Geofence]?
    let queryDetails: GeofenceQuery

    required init(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, query:GeofenceQuery, callback: @escaping IntelligenceAPICallback) {
        queryDetails = query
        super.init()
        self.callback = callback
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = URLRequest.int_URLRequestForDownloadGeofences(oauth: oauth!, configuration: configuration!, network: network!, query:queryDetails)
        sharedIntelligenceLogger.logger?.debug(request.description)

        output = network?.sessionManager?.int_executeSynchronousDataTask(with: request)
        
        if handleError() {
            return
        }
        
        guard let downloaded = try? Geofence.geofences(withJSON: output?.data?.int_jsonDictionary) else {
            output?.error = NSError(code: RequestError.parseError.rawValue)
            
            let str = String(format: "Parse error -- %@", (self.session?.description)!)
            sharedIntelligenceLogger.logger?.error(str)            
            return
        }
        
        geofences = downloaded
        
        if let httpResponse = output?.response as? HTTPURLResponse {
            sharedIntelligenceLogger.logger?.debug(httpResponse.description)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init(oauth: oauth!, configuration: configuration!, network: network!, query:queryDetails, callback: callback!)
        
        return copy
    }
}
