//
//  DownloadGeofencesRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles downloading geofences.
internal final class DownloadGeofencesRequestOperation: PhoenixOAuthOperation, NSCopying {
    
    /// Array containing Geofence objects.
    var geofences: [Geofence]?

    required init(oauth: PhoenixOAuthProtocol, configuration: Phoenix.Configuration, network: Network, callback: PhoenixOAuthCallback) {
        super.init()
        self.callback = callback
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
    }
    
    override func main() {
        super.main()
        let request = NSURLRequest.phx_URLRequestForDownloadGeofences(oauth!, configuration: configuration!, network: network!)
        output = network!.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        if handleError(LocationError.domain, code: LocationError.DownloadGeofencesError.rawValue) {
            return
        }
        guard let downloaded = try? Geofence.geofences(withJSON: output?.data?.phx_jsonDictionary) else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        geofences = downloaded
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(oauth: oauth!, configuration: configuration!, network: network!, callback: callback!)
    }
}