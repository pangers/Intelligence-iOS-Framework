//
//  PhoenixBaseTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

import OHHTTPStubs

class PhoenixBaseTestCase : XCTestCase {

    override func setUp() {
        Injector.storage = MockSimpleStorage()
    }
    
    func mockResponseForURL(url:NSURL!, method:String?, response:(data:String?,statusCode:Int32,headers:[String:String]?), expectation:XCTestExpectation? = nil) {
        var exp = expectation
        if exp == nil {
             exp = expectationWithDescription("mock \(url)")
        }
        
        OHHTTPStubs.stubRequestsPassingTest(
            { request in

                if let method = method where method != request.HTTPMethod {
                    return false
                }
                
                return request.URL! == url
            }
            ,
            withStubResponse: { [response, exp] _ in
                // Dispatch the expectation after a bit of sleeping, to allow the request to be handled.
                let now:dispatch_time_t = DISPATCH_TIME_NOW
                let dispatchTime = dispatch_time(now , Int64(0.01 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), { () -> Void in
                    exp!.fulfill()
                })
                
                let stubData = ((response.data) ?? "").dataUsingEncoding(NSUTF8StringEncoding)!
                return OHHTTPStubsResponse(data: stubData, statusCode:response.statusCode, headers:response.headers)
        })

    }
}