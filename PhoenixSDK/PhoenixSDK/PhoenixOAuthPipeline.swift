//
//  TSDOAuthPipeline.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 30/09/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class PhoenixOAuthPipeline: PhoenixOAuthOperation {
    
    var operations: [PhoenixOAuthOperation]
    
    init(withOperations operations: [PhoenixOAuthOperation],
        oauth: PhoenixOAuth? = nil,
        configuration: Phoenix.Configuration,
        network: Network)
    {
        self.operations = operations
        super.init()
        self.input = operations.first!.input as PhoenixOAuthResponse!
        self.oauth = oauth
        self.configuration = configuration
        self.network = network
    }
    
    override func main() {
        var previousOutput: PhoenixOAuthResponse? = nil
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