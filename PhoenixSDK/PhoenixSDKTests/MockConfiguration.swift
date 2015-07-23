//
//  MockConfiguration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 23/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

import PhoenixSDK

    public class MockConfiguration: Phoenix.Configuration {
        
        override public func isValid() -> Bool {
            return false
        }
        
        override public func hasMissingProperty() -> Bool {
            return false
        }
    }

