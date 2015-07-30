//
//  PhoenixBaseTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
@testable import PhoenixSDK

class PhoenixBaseTestCase : XCTestCase {

    override func setUp() {
        Injector.storage = MockSimpleStorage()
    }
}