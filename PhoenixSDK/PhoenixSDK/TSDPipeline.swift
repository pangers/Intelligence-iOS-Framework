//
//  TSDPipeline.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation


class TSDPipeline <TInput, TOutput, TFirstOperationOutput> : TSDOperation <TInput, TOutput> {
    
    typealias TSDPipelineCompletion = (output:TOutput?, error:NSError?) -> Void
    
    var completion:TSDPipelineCompletion?
    
    var operations:[NSOperation]
    
    class func pipeline(withOperationArray operations:[NSOperation]) -> TSDPipeline {
        return TSDPipeline(withOperationArray:operations)
    }
    
    init(withOperationArray operations:[NSOperation]) {
        self.operations = operations

        super.init()
        
        self.completionBlock = { [weak self] in
            guard let this = self,
                let callback = this.completion else {
                    return
            }
            
            
            callback(output:this.output, error: this.error)
        }
        

        
        guard let operation = operations.first as? TSDOperation<TInput, TFirstOperationOutput> else {
            return
        }
        
        self.input = operation.input
    }


}