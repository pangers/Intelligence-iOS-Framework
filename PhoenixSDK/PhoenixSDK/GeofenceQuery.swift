//
//  GeofenceQuery.swift
//  PhoenixSDK
//
//  Created by Małgorzata Dybizbańska on 29/09/15.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

/**
The direction to sort with when fetching geofences.

- Ascending
- Descending
*/
@objc public enum GeofenceSortDirection:Int {
    
    case Ascending
    case Descending
    
    func stringValue() -> String {
        switch self {
        case .Ascending:
            return "asc"
        case .Descending:
            return "desc"
        }
    }
}

/**
The criteria to sort with when fetching geofences.

- Distance: Distance from the coordinate passed
- Id:       The Id of the geofences
- Name:     The name of the geofences.
*/
@objc public enum GeofenceSortCriteria: Int {
    case Distance
    case Id
    case Name

    /**
    - returns: A non localized value describing the criteria.
    */
    public func stringValue() -> String {
        switch self {
        case .Distance:
            return "Distance"
        case .Id:
            return "Id"
        case .Name:
            return "Name"
        }
    }
}

///An instance of object using to create query part of URL for Geofence API
@objc(PHXGeofenceQuery) public class GeofenceQuery : NSObject {
    
    /// The direction to sort geofences with
    public var sortingDirection: GeofenceSortDirection?
    
    /// The criteria to sort geofences with
    public var sortingCriteria: GeofenceSortCriteria?
    
    /// The latitude of the coordinates.
    @objc public var longitude: Double
    
    /// The longitude of the coordinates
    @objc public var latitude: Double
    
    /// The radius to limit the geofences to fetch
    public var radius: Double?
    
    /// The maximum number of geofences in a page
    public var pageSize: Int?
    
    /// The page to load.
    public var pageNumber: Int?
    
    ///Default initializer. Requires location coordinates to query for list of geofences.
    /// - Parameters:
    ///     - location: location coordinates to look for geofences related to.
    public init(location: Coordinate) {
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
    func urlQueryString () -> String {
        var queryString : String = ""
            
        queryString.appendUrlQueryParameter("Longitude", parameterValue: longitude, isFirst: true)
        queryString.appendUrlQueryParameter("Latitude", parameterValue: latitude)
        
        if let radiusValue = radius {
            queryString.appendUrlQueryParameter("Radius", parameterValue: radiusValue)
        }
        
        if let sortDir = sortingDirection?.stringValue() {
            queryString.appendUrlQueryParameter("sortDir", parameterValue: sortDir)
        }
        
        if let sortBy = sortingCriteria {
            queryString.appendUrlQueryParameter("sortBy", parameterValue: sortBy.stringValue())
        }
        else {
            queryString.appendUrlQueryParameter("sortBy", parameterValue: GeofenceSortCriteria.Distance.stringValue())
        }
        
        if let pagenum = pageNumber {
            queryString.appendUrlQueryParameter("pagenum", parameterValue: pagenum)
        }
        
        if let pagesize = pageSize {
            queryString.appendUrlQueryParameter("pagesize", parameterValue: pagesize)
        }
        
        return queryString
    }
    
    // So that Obj-c can edit the optional values.
    
    public func setRadius(radius:Double) {
        self.radius = radius;
    }

    public func setPageSize(pageSize:Int) {
        self.pageSize = pageSize;
    }
    
    public func setPage(page:Int) {
        self.pageNumber = page;
    }
    
    public func setSortingDirection(direction:GeofenceSortDirection) {
        self.sortingDirection = direction
    }

    public func setSortingCriteria(criteria:GeofenceSortCriteria) {
        self.sortingCriteria = criteria
    }
}

private extension String {
    
    /// - Return: New string with added url query parameter in formats
    /// '?parameterName=parameterValue' if this is first parameter or
    /// '&parameterName=parameterValue' if not first parameter.
    mutating func appendUrlQueryParameter(parameterName: String, parameterValue: AnyObject, isFirst: Bool = false) {
        self += ((isFirst ? "" : "&") + "\(parameterName)=\(parameterValue)")
    }
}
