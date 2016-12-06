//
//  IntelligenceAnalyticsTestCase.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class IntelligenceAnalyticsTestCase: IntelligenceBaseTestCase {
    
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
        "\"DateCreated\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"DateUpdated\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"Address\": \"65 Tottenham Court Road, Fitzrovia, London W1T 2EU, UK\"," +
        "\"Radius\": 3.09" +
        "}]" +
    "}"
    
    func fakeGeofence() -> Geofence {
        let data = fakeGeofenceString.data(using: String.Encoding.utf8)?.int_jsonDictionary
        return try! Geofence.geofences(withJSON: data).first!
    }
    
    override func tearDown() {
        super.tearDown()
        let queue = EventQueue { (events, completion: (_ error: NSError?) -> ()) -> () in
            
        }
        queue.clearEvents()
    }
    
    func testAppTimeEvent() {
        let event = TrackApplicationTimeEvent(withSeconds: 10)
        XCTAssert(event.value == Double(10))
        XCTAssert(event.eventType == TrackApplicationTimeEvent.EventType)
    }
    
    func testAnalyticsModule() {
        let analytics = intelligence.analytics as! AnalyticsModule
        analytics.eventQueue = EventQueue { (events, completion) -> () in
            completion(nil)
        }
        let storage = MockTimeTrackerStorage()
        analytics.timeTracker = TimeTracker(storage: storage, callback: { (event) -> () in
        })
        
        let locationProvider = MockLocationProvider()
        
        analytics.locationProvider = locationProvider
        
        sleep(1)
        analytics.pause()
        
        XCTAssert(analytics.eventQueue?.isPaused == true)
        
        let seconds = analytics.timeTracker!.seconds
        
        XCTAssert(seconds > 0)
        
        analytics.resume()
        sleep(1)
        
        XCTAssert(analytics.eventQueue?.isPaused == false)
        
        analytics.pause()
        analytics.resume()
        
        XCTAssert(analytics.timeTracker!.seconds - seconds > 0)
        
        analytics.pause()
        
        analytics.eventQueue?.clearEvents()
        
        let testEvent = Event(withType: "TestType")
        analytics.track(event: testEvent)
        
        XCTAssert(analytics.eventQueue?.eventArray.count == 1)
        let dictionary = analytics.eventQueue!.eventArray.first as JSONDictionary!
        ensureJSONIncludesMandatoryPopulatedData(dictionary!)
        
        guard let rootGeo = dictionary?[Event.GeolocationKey] as? JSONDictionary else {
            XCTFail("Invalid event, expected user location")
            return
        }
        
        XCTAssert(rootGeo[Event.GeolocationLatitudeKey] as! Double == -70)
        XCTAssert(rootGeo[Event.GeolocationLongitudeKey] as! Double == 40)
    }
    
    func testTimeTracker() {
        var expectCallbacks = [expectation(description: "Was expecting a callback to be notified"),
        expectation(description: "Was expecting a callback to be notified 2")]
        let storage = MockTimeTrackerStorage()
        storage.duration = 10
        var timeTracker: TimeTracker? = TimeTracker(storage: storage, callback: { (event) -> () in
            if expectCallbacks.count == 2 {
                XCTAssert(event.value == 10)
            }
            XCTAssert(event.eventType == TrackApplicationTimeEvent.EventType)
            expectCallbacks.first?.fulfill()
            expectCallbacks.removeFirst()
        })
        sleep(1)
        timeTracker?.pause()
        XCTAssert((timeTracker?.seconds)! > 0)
        
        timeTracker?.backgroundThreshold = 1
        sleep(2)
        
        timeTracker?.resume()
        timeTracker?.runTimer(timer: Timer())
        
        waitForExpectations()
        
        let actualStorage = TimeTrackerStorage(userDefaults: UserDefaults())
        actualStorage.reset()
        actualStorage.update(10)
        XCTAssert(actualStorage.seconds() == 10)
        actualStorage.reset()
        XCTAssert(actualStorage.seconds() == nil)
        
        timeTracker = nil
    }
    
    func genericEvent() -> Event {
        let event = Event(withType: "Intelligence.Test.Event")
        XCTAssertNil(event.targetId)
        XCTAssert(event.value == 0)
        XCTAssert(event.eventType == "Intelligence.Test.Event")
        return event
    }
    
    func ensureJSONIncludesMandatoryPopulatedData(_ json: JSONDictionary) {
        XCTAssert(json[Event.ApplicationIdKey] as! Int == mockConfiguration.applicationID, "Expected application ID to match configuration")
        XCTAssert(json[Event.DeviceTypeKey] as! String == UIDevice.current.model, "Expected device model to match")
        XCTAssert(json[Event.OperationSystemVersionKey] as! String == UIDevice.current.systemVersion, "Expected system version to match")
        XCTAssert(json[Event.EventDateKey] as? String != nil, "Expected time interval")
    }
    
    func testEventQueue() {
        let myQueue = EventQueue { (events, completion) -> () in
            
        }
        XCTAssert(myQueue.maxEvents == 100, "Expected 100 max")
        XCTAssert(myQueue.isPaused, "Expected to start paused")
        myQueue.runTimer(Timer())
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
    
    func mockSendAnalytics(_ status: HTTPStatusCode = .success, event: Event, eventsJSONResponse: JSONDictionary? = nil, completion: @escaping (_ error: NSError?) -> ()) {
        let analytics = (intelligence?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(event: event)
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        let eventsJSON: JSONDictionaryArray = [eventJSON]
        let eventsResponse = eventsJSONResponse ?? ["TotalRecords": 1, "Data": eventsJSON]
        let successfulResponse = NSString(data: eventsResponse.int_toJSONData()!, encoding: String.Encoding.utf8.rawValue) as! String
        let URL = URLRequest.int_URLRequestForAnalytics(json: eventsJSON, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url
        mockResponseForURL(URL,
            method: .POST,
            response: (data: status == .success ? successfulResponse : nil, statusCode: status, headers:nil))
        analytics.sendEvents(events: eventsJSON, completion: completion)
    }
    
    /// Test if event type is correct and id matches.
    func testGeofenceEnterSuccess() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Create event, avoiding queueing/storage system.
        let geofence = fakeGeofence()
        let event = GeofenceEnterEvent(geofence: geofence)
        XCTAssert(event.eventType == GeofenceEnterEvent.EventType)
        XCTAssert(event.targetId == String(geofence.id))
        XCTAssert(event.value == 0)
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.success,
            event: event,
            completion: { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test if event type is correct and id matches.
    func testGeofenceExitSuccess() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Create event, avoiding queueing/storage system.
        let geofence = fakeGeofence()
        let event = GeofenceExitEvent(geofence: geofence)
        XCTAssert(event.eventType == GeofenceExitEvent.EventType)
        XCTAssert(event.targetId == String(geofence.id))
        XCTAssert(event.value == 0)
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.success,
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
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Create event, avoiding queueing/storage system.
        let event = OpenApplicationEvent(applicationID: mockConfiguration.applicationID)
        XCTAssert(event.eventType == OpenApplicationEvent.EventType)
        XCTAssert(event.targetId == String(mockConfiguration.applicationID))
        XCTAssert(event.value == 0)
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.success,
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
		let expectCallback = expectation(description: "Was expecting a callback to be notified")
		
		// Create event, avoiding queueing/storage system.
		let screenName = "Unit Test Screen"
		let viewingDuration = 42.0
		let event = ScreenViewedEvent(screenName: screenName, viewingDuration: viewingDuration)
		XCTAssert(event.eventType == ScreenViewedEvent.EventType)
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
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.success,
            event: genericEvent(),
            completion: { (error) -> () in
            XCTAssertNil(error, "Expected success")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test a invalid number of events is returned
    func testAnalyticsInvalidCount() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.success,
            event: genericEvent(),
            eventsJSONResponse: ["TotalRecords": 2, "Data": [genericEvent().toJSON(), genericEvent().toJSON()]],
            completion: { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.parseError.rawValue, "Expected parse error")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test a invalid response
    func testAnalyticsInvalidResponse() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.success,
            event: genericEvent(),
            eventsJSONResponse: ["Blah": "123"],
            completion: { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.parseError.rawValue, "Expected parse error")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test an error
    func testAnalyticsError404() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        mockOAuthProvider.fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth, fakeUser: fakeUser)
        mockSendAnalytics(.NotFound,
            event: genericEvent(),
            completion: { (error) -> () in
            XCTAssertNotNil(error, "Expected failure")
            XCTAssert(error?.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.NotFound.rawValue, "Expected a NotFound (404) error")
            expectCallback.fulfill()
        })
        
        waitForExpectations()
    }
    
    /// Test an error
    func testAnalyticsError400InvalidRequest() {
        let analytics = intelligence.analytics as! AnalyticsModule
        let failureResponse = "{ \"error\": \"invalid_request\", \"error_description\": \"Invalid parameter.\" }"
        let URL = URLRequest.int_URLRequestForAnalytics(json: [], oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url
        
        // Expect the analytics response.
        let expectation = self.expectation(description: "Expected analytics callback")

        // Mock the 400 response with error invalid_request.
        mockResponseForURL(URL,
            method: .POST,
            response: (data: failureResponse, statusCode: .badRequest, headers:nil))
        
        analytics.sendEvents(events: []) { (error) -> () in
            // The operation should throw the error for the callback to handle.
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    
    // MARK:- Event Queue
    
    /// Test events queue saving/loading
    func testEventsQueueLoad() {
        let queue = EventQueue { (events, completion: (_ error: NSError?) -> ()) -> () in
            
        }
        let analytics = (intelligence?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(event: genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(event: eventJSON)
        queue.loadEvents()
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
    }
    
    /// Test events queue sending
    func testEventsQueueFire() {
        let queue = EventQueue { (events, completion: (_ error: NSError?) -> ()) -> () in
            XCTAssert(events.count == 1)
            completion(nil)
        }
        let analytics = (intelligence?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(event: genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(event: eventJSON)
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
        let queue = EventQueue { (events, completion: (_ error: NSError?) -> ()) -> () in
            XCTAssert(events.count == 1)
            completion(NSError(code: RequestError.unhandledError.rawValue))
        }
        let analytics = (intelligence?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(event: genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        queue.enqueueEvent(event: eventJSON)
        queue.isPaused = false
        XCTAssert(queue.eventArray.count == 1, "Expected 1 event to be saved")
        queue.fire { (error) -> () in
            XCTAssertNotNil(error, "Expected error")
            XCTAssert(error?.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(queue.eventArray.count == 1, "Expected event to stay in array")
            queue.loadEvents()
            XCTAssert(queue.eventArray.count == 1, "Expected event to stay in file")
        }
    }
    
    /// Test that having over 100 events in the queue will fire two calls.
    func test101EventsInQueueRequiresTwoCalls() {
        var comparisonCount: Int = 0
        let queue = EventQueue { (events, completion: (_ error: NSError?) -> ()) -> () in
            XCTAssert(events.count == comparisonCount)
            completion(nil)
        }
        let analytics = (intelligence?.analytics as! AnalyticsModule)
        let eventJSON = analytics.prepareEvent(event: genericEvent())
        queue.clearEvents() // Empty file first
        ensureJSONIncludesMandatoryPopulatedData(eventJSON)
        (0...queue.maxEvents).forEach({ n -> Void in queue.enqueueEvent(event: eventJSON) })
        var remaining = queue.eventArray.count
        XCTAssert(remaining == queue.maxEvents + 1, "Expected 101 events to be saved")
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
