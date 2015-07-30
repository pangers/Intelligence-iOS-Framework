//
//  UtilsTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

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
    }

}
