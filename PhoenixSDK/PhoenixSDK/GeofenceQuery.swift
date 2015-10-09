//
//  GeofenceQuery.swift
//  PhoenixSDK
//
//  Created by Małgorzata Dybizbańska on 29/09/15.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation
import CoreLocation

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

@objc public enum GeofenceSortCriteria: Int {
    case Distance
    case Id
    case Name
    case Description
    case Address
    case Reference

    public func stringValue() -> String {
        switch self {
        case .Distance:
            return "Distance"
        case .Id:
            return "Id"
        case .Name:
            return "Name"
        case .Description:
            return "Description"
        case .Address:
            return "Address"
        case .Reference:
            return "Reference"
        }
    }
    
//        = "Distance"
}

///An instance of object using to create query part of URL for Geofence API
@objc(PHXGeofenceQuery) public class GeofenceQuery : NSObject {
    
    public var sortingDirection: GeofenceSortDirection?
    
    public var sortingCriteria: GeofenceSortCriteria?
    
    @objc public var longitude: Double
    
    @objc public var latitude: Double
    
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
}

private extension String {
    
    /// - Return: New string with added url query parameter in formats
    /// '?parameterName=parameterValue' if this is first parameter or
    /// '&parameterName=parameterValue' if not first parameter.
    mutating func appendUrlQueryParameter(parameterName: String, parameterValue: AnyObject, isFirst: Bool = false) {
        self += ((isFirst ? "" : "&") + "\(parameterName)=\(parameterValue)")
    }
}
