//
//  GetUserMeRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class GetUserMeRequestOperation : PhoenixNetworkRequestOperation {
    
    var meUser: Phoenix.User?
    private let configuration: PhoenixConfigurationProtocol
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration)
        self.configuration = configuration
        super.init(withSession: session, withRequest: request, withAuthentication: authentication)
    }
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        
        if error != nil {
            return
        }
        
        guard let output = self.output, rawData = output.data, jsonResponse = rawData.phx_jsonDictionary,
            jsonArr = jsonResponse["Data"] as? JSONArray,
            userData = jsonArr.first as? JSONDictionary where jsonArr.count > 0 else {
                return
        }
        meUser = Phoenix.User(withJSON: userData, withConfiguration: configuration)
        authentication.userId = meUser?.userId
    }
}