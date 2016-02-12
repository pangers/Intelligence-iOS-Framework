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

    required init(oauth: IntelligenceOAuthProtocol, configuration: Intelligence.Configuration, network: Network, query:GeofenceQuery, callback: IntelligenceAPICallback) {
        queryDetails = query
        super.init()
        self.callback = callback
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.int_URLRequestForDownloadGeofences(oauth!, configuration: configuration!, network: network!, query:queryDetails)
        output = network!.sessionManager!.int_executeSynchronousDataTaskWithRequest(request)
        
        if handleError() {
            return
        }
        
        guard let downloaded = try? Geofence.geofences(withJSON: output?.data?.int_jsonDictionary) else {
            output?.error = NSError(code: RequestError.ParseError.rawValue)
            return
        }
        
        geofences = downloaded
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = self.dynamicType.init(oauth: oauth!, configuration: configuration!, network: network!, query:queryDetails, callback: callback!)
        
        return copy
    }
}