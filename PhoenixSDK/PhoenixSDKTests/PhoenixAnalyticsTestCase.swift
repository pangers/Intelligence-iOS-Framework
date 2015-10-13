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
        let queue = EventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            
        }
        queue.clearEvents()
    }
    
    func testAppTimeEvent() {
        let event = TrackApplicationTimeEvent(withSeconds: 10)
        XCTAssert(event.value == Double(10))
        XCTAssert(event.eventType == TrackEventType)
    }
    
    func testTimeTracker() {
        var expectCallbacks = [expectationWithDescription("Was expecting a callback to be notified"),
        expectationWithDescription("Was expecting a callback to be notified 2")]
        let storage = MockTimeTrackerStorage()
        storage.duration = 10
        var timeTracker: TimeTracker? = TimeTracker(storage: storage, callback: { (event) -> () in
            if expectCallbacks.count == 2 {
                XCTAssert(event.value == 10)
            }
            XCTAssert(event.eventType == TrackEventType)
            expectCallbacks.first?.fulfill()
            expectCallbacks.removeFirst()
        })
        sleep(1)
        timeTracker?.pause()
        XCTAssert(timeTracker?.seconds > 0)
        
        timeTracker?.backgroundThreshold = 1
        sleep(2)
        
        timeTracker?.resume()
        timeTracker?.runTimer(NSTimer())
        
        waitForExpectations()
        
        let actualStorage = TimeTrackerStorage(userDefaults: NSUserDefaults())
        actualStorage.reset()
        actualStorage.update(10)
        XCTAssert(actualStorage.seconds() == 10)
        actualStorage.reset()
        XCTAssert(actualStorage.seconds() == nil)
        
        timeTracker = nil
    }
    
    func genericEvent() -> Event {
        let event = Event(withType: "Phoenix.Test.Event")
        XCTAssertNil(event.targetId)
        XCTAssert(event.value == 0)
        XCTAssert(event.eventType == "Phoenix.Test.Event")
        return event
    }
    
    func ensureJSONIncludesMandatoryPopulatedData(json: JSONDictionary) {
        XCTAssert(json[Event.ApplicationIdKey] as! Int == mockConfiguration.applicationID, "Expected application ID to match configuration")
        XCTAssert(json[Event.DeviceTypeKey] as! String == UIDevice.currentDevice().model, "Expected device model to match")
        XCTAssert(json[Event.OperationSystemVersionKey] as! String == UIDevice.currentDevice().systemVersion, "Expected system version to match")
        XCTAssert(json[Event.EventDateKey] as? String != nil, "Expected time interval")
    }
    
    func testEventQueue() {
        let myQueue = EventQueue { (events, completion) -> () in
            
        }
        XCTAssert(myQueue.maxEvents == 100, "Expected 100 max")
        XCTAssert(myQueue.isPaused, "Expected to start paused")
        myQueue.runTimer(NSTimer())
        myQueue.fire(withCompletion: nil)
        myQueue.startQueue()
        myQueue.startQueue()    // Call second time to check 'isPaused'.
        myQueue.fire(withCompletion: nil)
        XCTAssertFalse(myQueue.isPaused, "Expected to be unpaused after start")
        myQueue.stopQueue()
        XCTAssert(myQueue.isPaused, "Expected to be paused after stop")
        myQueue.fire(withCompletion: nil)
        myQueue.stopQueue() // Call while stopped to check 'isPaused'.
        
        XCTAssertNotNil(myQueue.jsonPath())
    }
    
    // MARK:- Geofences
    
    func mockSendAnalytics(status: HTTPStatusCode = .Success, event: Event, eventsJSONResponse: JSONDictionary? = nil, completion: (error: NSError?) -> ()) {
        let analytics = (phoenix?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(event)
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsResponse = eventsJSONResponse ?? ["TotalRecords": 1, "Data": eventsJSON]
        let successfulResponse = NSString(data: eventsResponse.phx_toJSONData()!, encoding: NSUTF8StringEncoding) as! String
        let URL = NSURLRequest.phx_URLRequestForAnalytics(eventsJSON, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL
        mockResponseForURL(URL,
            method: .POST,
            response: (data: status == .Success ? successfulResponse : nil, statusCode: status, headers:nil))
        analytics.sendEvents(eventsJSON, completion: completion)
    }
    
    /// Test if event type is correct and id matches.
    func testGeofenceEnterSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Create event, avoiding queueing/storage system.
        let geofence = fakeGeofence()
        let event = GeofenceEnterEvent(geofence: geofence)
        XCTAssert(event.eventType == "Phoenix.Location.Geofence.Enter")
        XCTAssert(event.targetId == String(geofence.id))
        XCTAssert(event.value == 0)
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.Success,
            event: event,
            completion: { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test if event type is correct and id matches.
    func testGeofenceExitSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Create event, avoiding queueing/storage system.
        let geofence = fakeGeofence()
        let event = GeofenceExitEvent(geofence: geofence)
        XCTAssert(event.eventType == "Phoenix.Location.Geofence.Exit")
        XCTAssert(event.targetId == String(geofence.id))
        XCTAssert(event.value == 0)
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.Success,
            event: event,
            completion: { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    // MARK:- Open Application
    
    /// Test a valid response is parsed correctly
    func testOpenApplicationSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Create event, avoiding queueing/storage system.
        let event = OpenApplicationEvent()
        XCTAssert(event.eventType == "Phoenix.Identity.Application.Opened")
        XCTAssertNil(event.targetId)
        XCTAssert(event.value == 0)
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.Success,
            event: event,
            completion: { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
	
	// MARK:- Screen Viewed
	
	/// Test if event type is correct and id matches.
	func testScreenViewedSuccess() {
		let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
		
		// Create event, avoiding queueing/storage system.
		let screenName = "Unit Test Screen"
		let viewingDuration = 42.0
		let event = ScreenViewedEvent(screenName: screenName, viewingDuration: viewingDuration)
		XCTAssert(event.eventType == "Phoenix.Identity.Application.ScreenViewed")
		XCTAssert(event.targetId == screenName)
		XCTAssert(event.value == viewingDuration)
		
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(event: event) { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
	}

    // MARK:- Analytics Requests
    
    /// Test a valid response is parsed correctly
    func testAnalyticsSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.Success,
            event: genericEvent(),
            completion: { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test a invalid number of events is returned
    func testAnalyticsInvalidCount() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.Success,
            event: genericEvent(),
            eventsJSONResponse: ["TotalRecords": 2, "Data": [genericEvent().toJSON(), genericEvent().toJSON()]],
            completion: { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            XCTAssert(error?.domain == RequestError.domain, "Expected RequestError domain")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test a invalid response
    func testAnalyticsInvalidResponse() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.Success,
            event: genericEvent(),
            eventsJSONResponse: ["Blah": "123"],
            completion: { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Expected parse error")
            XCTAssert(error?.domain == RequestError.domain, "Expected RequestError domain")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test an error
    func testAnalyticsError404() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.NotFound,
            event: genericEvent(),
            completion: { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == AnalyticsError.SendAnalyticsError.rawValue, "Expected analytics error")
            XCTAssert(error?.domain == AnalyticsError.domain, "Expected AnalyticsError domain")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    
    // MARK:- Event Queue
    
    /// Test events queue saving/loading
    func testEventsQueueLoad() {
        let queue = EventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            
        }
        let analytics = (phoenix?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(eventJSON)
        queue.loadEvents()
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
    }
    
    /// Test events queue sending
    func testEventsQueueFire() {
        let queue = EventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == 1)
            completion(error: nil)
        }
        let analytics = (phoenix?.analytics as! AnalyticsModule)
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
        let queue = EventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == 1)
            completion(error: NSError(domain: AnalyticsError.domain, code: AnalyticsError.SendAnalyticsError.rawValue, userInfo: nil))
        }
        let analytics = (phoenix?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(eventJSON)
        queue.isPaused = false
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
        queue.fire { (error) -> () in
            XCTAssertNotNil(error, "Expected error")
            XCTAssert(error?.code == AnalyticsError.SendAnalyticsError.rawValue, "Expected SendAnalyticsError error code")
            XCTAssert(error?.domain == AnalyticsError.domain, "Expected AnalyticsError domain")
            XCTAssert(queue.eventArray.count == 1, "Expected event to stay in array")
            queue.loadEvents()
            XCTAssert(queue.eventArray.count == 1, "Expected event to stay in file")
        }
    }
    
    /// Test that having over 100 events in the queue will fire two calls.
    func test101EventsInQueueRequiresTwoCalls() {
        var comparisonCount: Int = 0
        let queue = EventQueue { (events, completion: (error: NSError?) -> ()) -> () in
            XCTAssert(events.count == comparisonCount)
            completion(error: nil)
        }
        let analytics = (phoenix?.analytics as! AnalyticsModule)
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