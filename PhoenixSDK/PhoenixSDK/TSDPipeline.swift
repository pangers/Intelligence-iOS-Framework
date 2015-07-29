//
//  TSDPipeline.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation


class TSDPipeline <TInput, TOutput, TError> : TSDOperation <TInput, TOutput, TError> {
    
    typealias TSDPipelineCompletion = (output:TOutput?, error:TError?) -> Void
    
    var completion:TSDPipelineCompletion
    var operations:[TSDOperations]
    
    class func pipeline(withOperationArray operations:[TSDOperation<>]) {
        return TSDPipeline(withOperationArray:operations)
    }
    
    init(withOperationArray operations:[NSOperation]) {
        super.init()
        
        self.completionBlock = { [weak self] in
            guard let this = self else {
                return
            }
            
            this.completion(output:this.output, error: this.error)
        }
        
        self.operations = operations
        self.input = operations.first.input
    }


}