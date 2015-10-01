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
        phoenix: Phoenix)
    {
        self.operations = operations
        super.init()
        self.input = operations.first!.input as PhoenixOAuthResponse!
        self.oauth = oauth
        self.phoenix = phoenix
    }
    
    override func main() {
        var previousOutput: PhoenixOAuthResponse? = nil
        while let operation = operations.first {
            if previousOutput != nil {
                operation.input = previousOutput
            }
            operation.oauth = oauth
            operation.phoenix = phoenix
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