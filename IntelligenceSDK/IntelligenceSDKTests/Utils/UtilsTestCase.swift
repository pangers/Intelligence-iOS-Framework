//
//  UtilsTestCase.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

class UtilsTestCase: XCTestCase {

    func testShuffle() {
        
        measure { () -> Void in
            var values = ["A"]
            var original = values
            values.shuffle()
            XCTAssert(original == values)
            
            values.removeAll()
            XCTAssert(values.count == 0)
            values.shuffle()
            XCTAssert(values.count == 0)
            
            values = ["A","B","C","D","E","F","G","H","I"]
            original = values
            while original == values {
                values.shuffle()
            }
            XCTAssert(original != values)
            XCTAssert(original == values.sorted())
            
            let immutable = [1,2,3,4,5]
            let originalNumbers = immutable
            
            //Chethan : Need to test
//            while immutable.shuffle() == immutable {
//            }
            
            XCTAssert(immutable.sorted() == originalNumbers)
            
            XCTAssert(true)
        }
    }
    
    func testForEachInMainThreadFromSecondaryThread() {
        let expectationsArray = [
            expectation(description: "1"),
            expectation(description: "2"),
            expectation(description: "3"),
            expectation(description: "4"),
            expectation(description: "5"),
            expectation(description: "6"),
            expectation(description: "7")
        ]
        
        //Chethan : Need to check this flow.
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { // 1
            
            // Assert that we are not in the main thread, but forEachInMainThread will run in the main thread.
            XCTAssertFalse(Thread.isMainThread)
            
            expectationsArray.forEachInMainThread {
                // Assert that all runs in the main thread
                XCTAssert(Thread.isMainThread)
                
                // Fulfill all expectation so we can wait for them.
                $0.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2) { (error) -> Void in
            XCTAssertNil(error)
        }
    }
    
    /**
    Checks that if we call it from the main thread there is no deadlock.
    */
    func testForEachInMainThreadFromMainThread() {
        let expectationsArray = [
            expectation(description: "1"),
            expectation(description: "2"),
            expectation(description: "3"),
            expectation(description: "4"),
            expectation(description: "5"),
            expectation(description: "6"),
            expectation(description: "7")
        ]
        
        // Assert that all runs in the main thread
        XCTAssert(Thread.isMainThread)

        expectationsArray.forEachInMainThread {
            // Assert that all runs in the main thread
            XCTAssert(Thread.isMainThread)
            
            // Fulfill all expectation so we can wait for them.
            $0.fulfill()
        }

        waitForExpectations(timeout: 2) { (error) -> Void in
            XCTAssertNil(error)
        }
    }

    func testForEachInQueue() {
        let expectationsArray = [
            expectation(description: "1"),
            expectation(description: "2"),
            expectation(description: "3"),
            expectation(description: "4"),
            expectation(description: "5"),
            expectation(description: "6"),
            expectation(description: "7")
        ]
        
        // Assert that we run in the main thread
        XCTAssert(Thread.isMainThread)
        //dispatch_get_global_queue(Int(DispatchQoS.QoSClass.userInitiated.rawValue), 0)
        expectationsArray.forEach(asyncInQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)) {
            
            // Assert that we are not in the main thread
            XCTAssertFalse(Thread.isMainThread)

            // Fulfill all expectation so we can wait for them.
            $0.fulfill()
        }
        
        waitForExpectations(timeout: 2) { (error) -> Void in
            XCTAssertNil(error)
        }
    }
    
    func testStringContains() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(!"".contains(""), "Empty strings are contained")
        XCTAssert(!"123".contains(""), "A string does contain an empty string.")
        XCTAssert(!"".contains("123"), "An empty string contains a string.")
        XCTAssert(!"1".contains("123"), "A substring of the string contains the second string.")
        XCTAssert("123".contains("123"), "Two equal strings are contained.")
        XCTAssert("PADDING123PADDING".contains("123"), "Strings contain.")
        XCTAssert("123"[1] == "2")
        
        //  isContained
        XCTAssert(!"".isContained(string: ""), "Empty strings are contained")
        XCTAssert(!"123".isContained(string: ""), "A string does contain an empty string.")
        XCTAssert(!"".isContained(string: "123"), "An empty string contains a string.")
        XCTAssert("123".isContained(string: "123"), "Two equal strings are contained.")

        XCTAssert("1".isContained(string: "123"), "A substring of the string contains the second string.")
        XCTAssert(!"PADDING123PADDING".isContained(string: "123"), "Strings contain.")
    }
    //This unit test is failing because of IOS 10.x simulator issue.
    //http://stackoverflow.com/questions/20344255/secitemadd-and-secitemcopymatching-returns-error-code-34018-errsecmissingentit/22305193#22305193
    func testKeychainSubscript() {
        let defaults = IntelligenceKeychain()
        let key = "test"
        let value = "value"
        
        defaults[key] = value
        
        let result = defaults[key] as? String
        
        XCTAssert( (result == value) ,"Failure in subscript method.")
        
        defaults[key] = nil
        
        XCTAssert(defaults[key] == nil ,"Didn't clear the user defaults.")
    }
    
    func testDictionaryToJSONData() {
        
        var dict = [NSString: NSObject]()
        dict["TEST"] = NSObject()
        XCTAssert(dict.int_toJSONData() == nil)
        
    }
    
    func testDateFormatter() {
        let dateFormatter = RFC3339DateFormatter
        XCTAssert(dateFormatter.dateFormat == "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'")
        XCTAssert(dateFormatter.timeZone == TimeZone(abbreviation: "UTC"))
        XCTAssert(dateFormatter.calendar == Calendar(identifier: Calendar.Identifier.gregorian))
        XCTAssert(dateFormatter.locale == Locale(identifier: "en_US_POSIX"))
    }
    
    func testDataToJSONArray() {
        guard let _ = "[{\"0\":\"\",\"1\":\"\"}]".data(using: String.Encoding.utf8)?.int_jsonArray else {
            XCTAssert(false,"Couldn't load an array from the NSData")
            return
        }
    }

    func testGuardedJSONParsing() {
        let wrongJSONData = "sadasda{\\".data(using: String.Encoding.utf8)!
        
        XCTAssertNil(wrongJSONData.int_jsonDictionaryArray, "Json array loaded from wrong data")
        XCTAssertNil(wrongJSONData.int_jsonDictionary, "Json dictionary loaded from wrong data")
    }
}
