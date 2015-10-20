//
//  MockLocationProvider.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 13/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
@testable import PhoenixSDK

class MockLocationProvider : LocationModuleProvider {
    var userLocation:Coordinate? {
        return Coordinate(withLatitude: -70, longitude: 40)
    }
}