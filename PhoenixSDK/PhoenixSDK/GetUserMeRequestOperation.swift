//
//  GetUserMeRequestOperation.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class GetUserMeRequestOperation : PhoenixNetworkRequestOperation {
    
    let configuration: PhoenixConfigurationProtocol
    
    /// Default initializer with all required parameters
    init(session:NSURLSession, user:PhoenixUser, authentication:Phoenix.Authentication, configuration:PhoenixConfigurationProtocol) {
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
        
        if let output = self.output, data = output.data {
            
            do {
                let jsonResponse:JSONDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! JSONDictionary
                
                if let data = jsonResponse["Data"] as? JSONArray where data.count > 0 {
                    let userData = data[0] as! JSONDictionary
                    self.createdUser = Phoenix.User(withJSON: userData, withConfiguration:configuration)
                }
            }
            catch {
                // TODO: Error parsing the response
                
            }
        }
    }

}