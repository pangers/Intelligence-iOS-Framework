//
//  CreateUserRequestOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Create Installation API.
internal final class CreateInstallationRequestOperation : PhoenixInstallationRequestOperation {
    
    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        let request = NSURLRequest.phx_URLRequestForInstallationCreate(installation, configuration: configuration!, network: network!)
        output = network!.sessionManager.phx_executeSynchronousDataTaskWithRequest(request)
        parse(withErrorCode: InstallationError.CreateInstallationError.rawValue)
    }
    
}