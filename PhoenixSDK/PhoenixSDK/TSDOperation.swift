//
//  TSDOperation.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Extensds NSOperation to provide an input, output and error to it.
/// Uses generics to define the type of its input and output.
internal class TSDOperation <TInput, TOutput> : NSOperation {
    
    /// The input can be set from the caller. When running, the
    /// main method of the operation should read it.
    var input: TInput?
    
    /// the output is only set by the class itself once it finishes.
    internal(set) var output: TOutput?
    
    /// The error will be set by the operation if an error did occur.
    //internal(set) var error: NSError?
    
}