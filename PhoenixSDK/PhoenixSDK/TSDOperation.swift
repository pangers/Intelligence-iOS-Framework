//
//  TSDOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class TSDOperation <TInput, TOutput, TError> : NSOperation {
    
    var input:TInput?
    private(set) var output:TOutput?
    private(set) var error:TError?
    
    override init() {
        super.init()
    }
    
    convenience init(withInput input:TInput) {
        self.init()
        self.input = input
    }
    
    
}