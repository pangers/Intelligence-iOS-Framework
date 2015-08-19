//
//  PhoenixAnalyticsTestCase.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixAnalyticsTestCase: PhoenixBaseTestCase {
    
    override func tearDown() {
        super.tearDown()
        let queue = PhoenixEventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            
        }
        queue.clearEvents()
    }
    
    func genericEvent() -> Phoenix.Event {
        let event = Phoenix.Event(withType: "Phoenix.Test.Event")
        XCTAssert(event.targetId == 0)
        XCTAssert(event.value == 0)
        XCTAssert(event.eventType == "Phoenix.Test.Event")
        return event
    }
    
    func ensureJSONIncludesMandatoryPopulatedData(json: JSONDictionary) {
        XCTAssert(json[Phoenix.Event.ApplicationIdKey] as! Int == configuration!.applicationID, "Expected application ID to match configuration")
        XCTAssert(json[Phoenix.Event.DeviceTypeKey] as! String == UIDevice.currentDevice().model, "Expected device model to match")
        XCTAssert(json[Phoenix.Event.OperationSystemVersionKey] as! String == UIDevice.currentDevice().systemVersion, "Expected system version to match")
        XCTAssert((json[Phoenix.Event.MetadataKey] as! [String: AnyObject])[Phoenix.Event.MetadataTimestampKey] as! NSTimeInterval > 0, "Expected time interval")
    }
    
    // MARK:- Open Application
    
    /// Test a valid response is parsed correctly
    func testOpenApplicationSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let event = Phoenix.OpenApplicationEvent()
        XCTAssert(event.eventType == "Phoenix.Identity.Application.Opened")
        XCTAssert(event.targetId == 0)
        XCTAssert(event.value == 0)
        
        let eventJSON = analytics.prepareEvent(event)
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsJSONResponse: JSONDictionary = ["TotalRecords": 1, "Data": eventsJSON]
        let successfulResponse = NSString(data: eventsJSONResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        
        // Create request
        let request = NSURLRequest.phx_httpURLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulResponse, statusCode:200, headers:nil))
        
        // Avoid using the EventQueue so we are certain that we are only sending one request here.
        analytics.sendEvents(eventsJSON) { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }

    // MARK:- Analytics Requests
    
    /// Test a valid response is parsed correctly
    func testAnalyticsSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let eventJSON = analytics.prepareEvent(genericEvent())
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsJSONResponse: JSONDictionary = ["TotalRecords": 1, "Data": eventsJSON]
        let successfulResponse = NSString(data: eventsJSONResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        
        // Create request
        let request = NSURLRequest.phx_httpURLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulResponse, statusCode:200, headers:nil))
        
        // Avoid using the EventQueue so we are certain that we are only sending one request here.
        analytics.sendEvents(eventsJSON) { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    /// Test a invalid number of events is returned
    func testAnalyticsInvalidCount() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let eventJSON = analytics.prepareEvent(genericEvent())
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsJSONResponse: JSONDictionary = ["TotalRecords": 2, "Data": [eventJSON, eventJSON]]
        let successfulResponse = NSString(data: eventsJSONResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        
        // Create request
        let request = NSURLRequest.phx_httpURLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulResponse, statusCode:200, headers:nil))
        
        // Avoid using the EventQueue so we are certain that we are only sending one request here.
        analytics.sendEvents(eventsJSON) { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            XCTAssert(error?.domain == RequestError.domain, "Expected RequestError domain")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    /// Test a invalid response
    func testAnalyticsInvalidResponse() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let eventJSON = analytics.prepareEvent(genericEvent())
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsJSONResponse: JSONDictionary = ["Blah": "123"]
        let successfulResponse = NSString(data: eventsJSONResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        
        // Create request
        let request = NSURLRequest.phx_httpURLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulResponse, statusCode:200, headers:nil))
        
        // Avoid using the EventQueue so we are certain that we are only sending one request here.
        analytics.sendEvents(eventsJSON) { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            XCTAssert(error?.domain == RequestError.domain, "Expected RequestError domain")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    /// Test an error
    func testAnalyticsError404() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let eventJSON = analytics.prepareEvent(genericEvent())
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        
        // Create request
        let request = NSURLRequest.phx_httpURLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: "", statusCode:404, headers:nil))
        
        // Avoid using the EventQueue so we are certain that we are only sending one request here.
        analytics.sendEvents(eventsJSON) { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.RequestFailedError.rawValue, "Expected request error")
            XCTAssert(error?.domain == RequestError.domain, "Expected RequestError domain")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    
    // MARK:- Event Queue
    
    /// Test events queue saving/loading
    func testEventsQueueLoad() {
        let queue = PhoenixEventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            
        }
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(eventJSON)
        queue.loadEvents()
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
    }
    
    /// Test events queue sending
    func testEventsQueueFire() {
        let queue = PhoenixEventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == 1)
            completion(error: nil)
        }
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(eventJSON)
        queue.isPaused = false
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
        queue.fire { (error) -> () in
            XCTAssertNil(error, "Expected nil error")
            XCTAssert(queue.eventArray.count == 0, "Expected empty array")
            queue.loadEvents()
            XCTAssert(queue.eventArray.count == 0, "Expected empty file")
        }
    }
    
    /// Test events queue sending failure
    func testEventsQueueFireFailed() {
        let queue = PhoenixEventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == 1)
            completion(error: NSError(domain: RequestError.domain, code: RequestError.RequestFailedError.rawValue, userInfo: nil))
        }
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(eventJSON)
        queue.isPaused = false
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
        queue.fire { (error) -> () in
            XCTAssertNotNil(error, "Expected error")
            XCTAssert(error?.code == RequestError.RequestFailedError.rawValue, "Expected request failed error code")
            XCTAssert(error?.domain == RequestError.domain, "Expected RequestError domain")
            XCTAssert(queue.eventArray.count == 1, "Expected event to stay in array")
            queue.loadEvents()
            XCTAssert(queue.eventArray.count == 1, "Expected event to stay in file")
        }
    }
    
    /// Test that having over 100 events in the queue will fire two calls.
    func test101EventsInQueueRequiresTwoCalls() {
        var remaining: Int = 0
        let queue = PhoenixEventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == remaining)
            completion(error: nil)
        }
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        (0...100).map({ n -> Void in queue.enqueueEvent(eventJSON) })
        remaining = queue.eventArray.count
        XCTAssert(queue.eventArray.count == 101, "Expected 101 events to be saved")
        queue.isPaused = false
        queue.fire { (error) -> () in
            XCTAssertNil(error, "Expected nil error")
            XCTAssert(queue.eventArray.count == 1, "Expected empty array")
            remaining = queue.eventArray.count
        }
        XCTAssert(remaining == 1, "Expected one left")
        queue.fire { (error) -> () in
            XCTAssertNil(error, "Expected nil error")
            XCTAssert(queue.eventArray.count == 0, "Expected empty array")
            queue.loadEvents()
            XCTAssert(queue.eventArray.count == 0, "Expected empty file")
        }
    }
    
}