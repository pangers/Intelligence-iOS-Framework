//
//  IntelligenceNetworkTestCase.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 07/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class IntelligenceNetworkTestCase : IntelligenceBaseTestCase {
    
    func testQueuedOperations() {
        let expectation = self.expectation(description: "Queue Test Expectation")
        
        XCTAssert(mockNetwork.queuedOperations().count == 0)
        XCTAssert(mockNetwork.queuedPipelines().count == 0)
        
        mockNetwork.queue.isSuspended = true
        
        mockNetwork.getPipeline(forOAuth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration) { [weak mockNetwork, weak self] (pipeline) -> () in
            XCTAssertNotNil(pipeline, "Cannot be nil")
            
            mockNetwork?.enqueueOperation(operation: pipeline!)
            XCTAssert(mockNetwork?.queuedPipelines().count == 1)

            expectation.fulfill()

        }
        
        waitForExpectations()
    }
}
