//
//  TSDOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal class TSDOperation <TInput, TOutput> : NSOperation {
    
    var input:TInput?
    internal(set) var output:TOutput?
    internal(set) var error:NSError?
    
    override init() {
        super.init()
    }
    
    convenience init(withInput input:TInput) {
        self.init()
        self.input = input
    }
    
    
}