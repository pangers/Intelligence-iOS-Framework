//
//  PhoenixNetworkTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 07/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixNetworkTestCase : PhoenixBaseTestCase {
    
    func testQueuedOperations() {
        let expectation = expectationWithDescription("Queue Test Expectation")
        
        XCTAssert(mockNetwork.queuedOperations().count == 0)
        XCTAssert(mockNetwork.queuedPipelines().count == 0)
        
        mockNetwork.queue.suspended = true
        
        mockNetwork.getPipeline(forOAuth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration) { [weak mockNetwork, weak self] (pipeline) -> () in
            XCTAssertNotNil(pipeline, "Cannot be nil")
            
            mockNetwork?.enqueueOperation(pipeline!)
            XCTAssert(mockNetwork?.queuedPipelines().count == 1)
            
            
            mockNetwork?.getPipeline(forOAuth: self!.mockOAuthProvider.applicationOAuth, configuration: self!.mockConfiguration) { (pipeline) -> () in
                XCTAssertNil(pipeline, "Cannot enqueue twice")
                
                self!.mockOAuthProvider.fakeLoggedIn(self!.mockOAuthProvider.sdkUserOAuth, fakeUser: self!.fakeUser)
                
                let operation = CreateInstallationRequestOperation(installation: self!.mockInstallation, oauth: self!.mockOAuthProvider.sdkUserOAuth, configuration: self!.mockConfiguration, network: self!.mockNetwork, callback: { (returnedOperation) -> () in
                    XCTAssert(false)
                })
                self!.mockNetwork.enqueueOperation(operation)
                XCTAssert(self!.mockNetwork.queuedOperations().count == 1)
                
                mockNetwork?.getPipeline(forOAuth: self!.mockOAuthProvider.sdkUserOAuth, configuration: self!.mockConfiguration) { (pipeline) -> () in
                    XCTAssertNotNil(pipeline, "Different type of pipeline should succeed")
                    
                    expectation.fulfill()
                }
            }
        }
        
        waitForExpectations()
    }
}
