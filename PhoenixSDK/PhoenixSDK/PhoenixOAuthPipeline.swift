//
//  TSDOAuthPipeline.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 30/09/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class PhoenixAPIPipeline: PhoenixAPIOperation {
    
    var operations: [PhoenixAPIOperation]
    
    init(withOperations operations: [PhoenixAPIOperation],
        oauth: PhoenixOAuthProtocol? = nil,
        configuration: Phoenix.Configuration,
        network: Network)
    {
        self.operations = operations
        super.init()
        self.input = operations.first!.input as PhoenixAPIResponse!
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
        self.completionBlock = { [weak self] in
            self?.complete()
        }
    }
    
    override func main() {
        var previousOutput: PhoenixAPIResponse? = nil
        while let operation = operations.first {
            if previousOutput != nil {
                operation.input = previousOutput
            }
            operation.oauth = oauth
            operation.network = network
            operation.configuration = configuration
            operation.main()
            if operation.shouldBreak {
                output = operation.output
                return
            }
            previousOutput = operation.output
            operations.removeFirst()
        }
        output = previousOutput
    }
}