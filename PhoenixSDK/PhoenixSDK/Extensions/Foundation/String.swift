//
//  String.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation


extension String {
    
    public func contains(string:String) -> Bool {
        return self.rangeOfString(string) != nil
    }
    
}