//
//  UpdateInstallationRequestOperation.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Operation for Create Installation API.
final class UpdateInstallationRequestOperation: InstallationRequestOperation {

    /// The operation will run synchronously the data task and store the error and output.
    override func main() {
        super.main()
        let request = URLRequest.int_URLRequestForInstallationUpdate(installation: installation, oauth: oauth!, configuration: configuration!, network: network!)
        sharedIntelligenceLogger.logger?.debug(request.description)
        output = network?.sessionManager?.int_executeSynchronousDataTask(with: request)
        parse()
    }

}
