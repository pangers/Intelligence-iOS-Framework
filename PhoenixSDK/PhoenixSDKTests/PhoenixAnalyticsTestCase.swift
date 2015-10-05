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
    
    let fakeGeofenceString = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Geolocation\": {" +
        "\"Latitude\": 51.5201906," +
        "\"Longitude\": -0.1341973" +
        "}," +
        "\"Id\": 2005," +
        "\"ProjectId\": 2030," +
        "\"Name\": \"DeskChriss\"," +
        "\"CreateDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"ModifyDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"Address\": \"65 Tottenham Court Road, Fitzrovia, London W1T 2EU, UK\"," +
        "\"Radius\": 3.09" +
        "}]" +
    "}"
    
    func fakeGeofence() -> Geofence {
        let data = fakeGeofenceString.dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonDictionary
        return try! Geofence.geofences(withJSON: data).first!
    }
    
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
        XCTAssert(json[Phoenix.Event.EventDateKey] as? String != nil, "Expected time interval")
    }
    
    func testEventQueue() {
        let myQueue = PhoenixEventQueue { (events, completion) -> () in
            
        }
        XCTAssert(myQueue.maxEvents == 100, "Expected 100 max")
        XCTAssert(myQueue.isPaused, "Expected to start paused")
        myQueue.runTimer()
        myQueue.fire(withCompletion: nil)
        myQueue.startQueue()
        myQueue.fire(withCompletion: nil)
        XCTAssertFalse(myQueue.isPaused, "Expected to be unpaused after start")
        myQueue.stopQueue()
        myQueue.fire(withCompletion: nil)
        XCTAssert(myQueue.isPaused, "Expected to be paused after stop")
    }
    
    // MARK:- Geofences
    
    /// Test if event type is correct and id matches.
    func testGeofenceEnterSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let geofence = fakeGeofence()
        let event = Phoenix.GeofenceEnterEvent(geofence: geofence)
        XCTAssert(event.eventType == "Phoenix.Location.Geofence.Enter")
        XCTAssert(event.targetId == geofence.id)
        XCTAssert(event.value == 0)
        
        let eventJSON = analytics.prepareEvent(event)
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsJSONResponse: JSONDictionary = ["TotalRecords": 1, "Data": eventsJSON]
        let successfulResponse = NSString(data: eventsJSONResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        
        // Create request
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
    
    /// Test if event type is correct and id matches.
    func testGeofenceExitSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        
        // Create event, avoiding queueing/storage system.
        let geofence = fakeGeofence()
        let event = Phoenix.GeofenceExitEvent(geofence: geofence)
        XCTAssert(event.eventType == "Phoenix.Location.Geofence.Exit")
        XCTAssert(event.targetId == geofence.id)
        XCTAssert(event.value == 0)
        
        let eventJSON = analytics.prepareEvent(event)
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsJSONResponse: JSONDictionary = ["TotalRecords": 1, "Data": eventsJSON]
        let successfulResponse = NSString(data: eventsJSONResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        
        // Create request
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
        let request = NSURLRequest.phx_URLRequestForAnalytics(configuration!, json: eventsJSON).URL!
        
        // Mock 200 on auth
        mockValidPhoenixOAuthStorage()
        
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
        var comparisonCount: Int = 0
        let queue = PhoenixEventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == comparisonCount)
            completion(error: nil)
        }
        let analytics = (phoenix?.analytics as! Phoenix.Analytics)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        (0...queue.maxEvents).forEach({ n -> Void in queue.enqueueEvent(eventJSON) })
        var remaining = queue.eventArray.count
        XCTAssert(remaining == 101, "Expected 101 events to be saved")
        queue.isPaused = false
        comparisonCount = remaining > queue.maxEvents ? queue.maxEvents : remaining
        queue.fire { (error) -> () in
            XCTAssertNil(error, "Expected nil error")
            XCTAssert(queue.eventArray.count == 1, "Expected empty array")
            remaining = queue.eventArray.count
        }
        XCTAssert(remaining == 1, "Expected one left")
        comparisonCount = remaining > queue.maxEvents ? queue.maxEvents : remaining
        XCTAssert(comparisonCount == 1, "Expected one")
        queue.fire { (error) -> () in
            XCTAssertNil(error, "Expected nil error")
            XCTAssert(queue.eventArray.count == 0, "Expected empty array")
            queue.loadEvents()
            XCTAssert(queue.eventArray.count == 0, "Expected empty file")
        }
    }
    
}