//
//  GeofenceQuery.swift
//  IntelligenceSDK
//
//  Created by Małgorzata Dybizbańska on 29/09/15.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

///An instance of object using to create query part of URL for Geofence API
@objc(INTGeofenceQuery) public class GeofenceQuery: NSObject {

    /// The latitude of the coordinates.
    @objc public var longitude: Double

    /// The longitude of the coordinates
    @objc public var latitude: Double

    /// The radius (in meters) to limit the geofences to fetch
    public var radius: Double

    /// The maximum number of geofences in a page
    public var pageSize: Int?

    /// The page to load.
    public var pageNumber: Int?

    ///Default initializer. Requires location coordinates to query for list of geofences.
    /// - Parameters:
    ///     - location: location coordinates to look for geofences related to.

    @objc public init(location: Coordinate, radius: Double) {
        longitude = location.longitude
        latitude = location.latitude
        self.radius = radius
    }

    ///Returns query using required parameters - longitude and latitude.
    ///And any of optional parameter if available.
    /// - Returns:
    ///     - query: String in form of URL query
    func urlQueryString () -> String {
        var queryString: String = ""

        queryString.appendUrlQueryParameter(parameterName: "longitude", parameterValue: longitude, isFirst: true)
        queryString.appendUrlQueryParameter(parameterName: "latitude", parameterValue: latitude)
        //Server accepts radius as integer.
        queryString.appendUrlQueryParameter(parameterName: "radius", parameterValue: Int(radius))

        if let pagenum = pageNumber {
            queryString.appendUrlQueryParameter(parameterName: "pagenumber", parameterValue: pagenum)
        }

        if let pagesize = pageSize {
            queryString.appendUrlQueryParameter(parameterName: "pagesize", parameterValue: pagesize)
        }

        return queryString
    }

    // So that Obj-c can edit the optional values.
    @objc(setPageSize:)
    public func setPageSize(pageSize: Int) {
        self.pageSize = pageSize
    }
    @objc(setPage:)
    public func setPage(page: Int) {
        self.pageNumber = page
    }
}

private extension String {

    /// - Return: New string with added url query parameter in formats
    /// '?parameterName=parameterValue' if this is first parameter or
    /// '&parameterName=parameterValue' if not first parameter.
    mutating func appendUrlQueryParameter(parameterName: String, parameterValue: Any, isFirst: Bool = false) {
        let urlEncodedParameterValue = "\(parameterValue)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        self += ((isFirst ? "" : "&") + "\(parameterName)=\(urlEncodedParameterValue)")
    }
}
