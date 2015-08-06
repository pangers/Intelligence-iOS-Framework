//
//  UtilsTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class UtilsTestCase: PhoenixBaseTestCase {

    func testStringContains() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(!"".contains(""), "Empty strings are contained")
        XCTAssert(!"123".contains(""), "A string does contain an empty string.")
        XCTAssert(!"".contains("123"), "An empty string contains a string.")
        XCTAssert(!"1".contains("123"), "A substring of the string contains the second string.")
        XCTAssert("123".contains("123"), "Two equal strings are contained.")
        XCTAssert("PADDING123PADDING".contains("123"), "Strings contain.")
        
        
        //  isContained
        XCTAssert(!"".isContained(""), "Empty strings are contained")
        XCTAssert(!"123".isContained(""), "A string does contain an empty string.")
        XCTAssert(!"".isContained("123"), "An empty string contains a string.")
        XCTAssert("123".isContained("123"), "Two equal strings are contained.")

        XCTAssert("1".isContained("123"), "A substring of the string contains the second string.")
        XCTAssert(!"PADDING123PADDING".isContained("123"), "Strings contain.")
    }
    
    func testKeychainSubscript() {
        let defaults = PhoenixKeychain()
        let key = "test"
        let value = "value"
        
        defaults[key] = value
        
        let result = defaults[key] as? String
        
        XCTAssert( (result == value) ,"Failure in subscript method.")
        
        defaults[key] = nil
        
        XCTAssert(defaults[key] == nil ,"Didn't clear the user defaults.")
    }
    
    func testTokenStorageNoDate() {
        let storage = MockSimpleStorage()
        storage.tokenExpirationDate = nil
        
        XCTAssert(storage.tokenExpirationDate == nil ,"Can clear the storage date correctly.")
    }
    
    func testDataToJSONArray() {
        guard let array = "[0,1,2,3]".dataUsingEncoding(NSUTF8StringEncoding)?.phx_jsonArray else {
            XCTAssert(false,"Couldn't load an array from the NSData")
            return
        }
        
        for (index,value) in array.enumerate() {
            XCTAssert(index == value as! Int, "Unexpected value parsed")
        }
    }

    func testGuardedJSONParsing() {
        let wrongJSONData = "sadasda{\\".dataUsingEncoding(NSUTF8StringEncoding)!
        
        XCTAssertNil(wrongJSONData.phx_jsonArray, "Json array loaded from wrong data")
        XCTAssertNil(wrongJSONData.phx_jsonDictionary, "Json dictionary loaded from wrong data")
    }
}
