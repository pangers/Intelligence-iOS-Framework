//
//  GeofenceQuery.swift
//  PhoenixSDK
//
//  Created by Małgorzata Dybizbańska on 29/09/15.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

public enum GeofenceSortDirection: String {
    case Ascending = "asc"
    case Descending = "desc"
}

public enum GeofenceSortCriteria: String {
    case Distance = "Distance"
}

///An instance of object using to create query part of URL for Geofence API
@objc public class GeofenceQuery : NSObject {
    
    public var sortingDirection: GeofenceSortDirection?
    
    public var sortingCriteria: GeofenceSortCriteria?
    
    public var longitude: Double
    
    public var latitude: Double
    
    public var radius: Double?
    
    public var pageSize: Int?
    
    public var pageNumber: Int?
    
    ///Default initializer. Requires location coordinates to query for list of geofences.
    /// - Parameters:
    ///     - location: location coordinates to look for geofences related to.
    public init(location: PhoenixCoordinate) {
        longitude = location.longitude
        latitude = location.latitude
    }
    
    ///This method provides set of default values to perform GET list of Geofences call.
    public func setDefaultValues () {
        sortingCriteria = GeofenceSortCriteria.Distance
        sortingDirection = GeofenceSortDirection.Ascending
        radius = 40000000.0
        pageSize = 20 //platform limit for Geolocations tracking
        pageNumber = 0
    }
    
    ///Returns query using required parameters - longitude and latitude.
    ///And any of optional parameter if available.
    /// - Returns:
    ///     - query: String in form of URL query
    func getURLQueryString () -> String {
        var queryString : String = ""
            
        queryString.appendUrlQueryParameter("Longitude", parameterValue: longitude, isFirst: true)
        queryString.appendUrlQueryParameter("Latitude", parameterValue: latitude)
        
        if let radiusValue = radius {
            queryString.appendUrlQueryParameter("Radius", parameterValue: radiusValue)
        }
        
        if let sortDir = sortingDirection?.rawValue {
            queryString.appendUrlQueryParameter("sortDir", parameterValue: sortDir)
        }
        
        if let sortBy = sortingCriteria?.rawValue {
            queryString.appendUrlQueryParameter("sortBy", parameterValue: sortBy)
        }
        
        if let pagenum = pageNumber {
            queryString.appendUrlQueryParameter("pagenum", parameterValue: pagenum)
        }
        
        if let pagesize = pageSize {
            queryString.appendUrlQueryParameter("pagesize", parameterValue: pagesize)
        }
        
        return queryString
    }
}

private extension String {
    
    /// - Return: New string with added url query parameter in formats
    /// '?parameterName=parameterValue' if this is first parameter or
    /// '&parameterName=parameterValue' if not first parameter.
    mutating func appendUrlQueryParameter(parameterName: String, parameterValue: AnyObject, isFirst: Bool = false) {
        self += ((isFirst ? "?" : "&") + "\(parameterName)=\(parameterValue)")
    }
}
