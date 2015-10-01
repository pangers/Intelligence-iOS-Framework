//
//  DownloadGeofencesRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// NSOperation that handles downloading geofences.
internal final class DownloadGeofencesRequestOperation: PhoenixOAuthOperation {
    
    /// Array containing Geofence objects.
    var geofences: [Geofence]?
    
    init(oauth: PhoenixOAuth, phoenix: Phoenix) {
        super.init()
        self.oauth = oauth
        self.phoenix = phoenix
    }
    
    override func main() {
        let request = NSURLRequest.phx_URLRequestForDownloadGeofences(oauth!, phoenix: phoenix!)
        output = phoenix!.network.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        if handleError(LocationError.domain, code: LocationError.DownloadGeofencesError.rawValue) {
            return
        }
        guard let downloaded = try? Geofence.geofences(withJSON: output?.data?.phx_jsonDictionary) else {
            output?.error = NSError(domain: RequestError.domain, code: RequestError.ParseError.rawValue, userInfo: nil)
            return
        }
        geofences = downloaded
    }
}