//
//  INTGeofenceJSON.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

enum GeofenceKey: String {
    /// Top level data key
    case dataKey = "Data"
    /// Identifier within a data object.
    case idKey = "Id"
    /// Project Identifier key within a data object.
    case projectIdKey = "ProjectId"
    /// Name key within a data object.
    case nameKey = "Name"
    /// Address key within a data object.
    case addressKey = "Address"
    /// Radius key within a data object.
    case radiusKey = "Radius"
    /// Modify date key within a data object.
    case dateUpdatedKey = "DateUpdated"
    /// Create date key within a data object.
    case dateCreatedKey = "DateCreated"
    /// Geolocation key within a data object.
    case geolocationKey = "Geolocation"
    /// Latitude key within a geolocation object.
    case latitudeKey = "Latitude"
    /// Longitude key within a geolocation object.
    case longitudeKey = "Longitude"
}

extension Geofence {

    // For some reason this isn't working as a Dictionary extension with a where clause,
    // Apple may have broken that functionality in the current beta.
    /// - Returns: Value for a specific GeofenceKey in our JSONDictionary or throws a GeofenceError.
    private class func geoValue<T>(forKey key: GeofenceKey, dictionary: JSONDictionary) throws -> T {
        guard let output = dictionary[key.rawValue] as? T else {
            //todo chethan
            throw GeofenceError.invalidPropertyError(key)
        }
        return output
    }

    /// - Returns: Path to Geofences JSON file.
    class func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return nil }
        return "\(path)/Geofences.json"
    }

    /// Writes JSONDictionary to file.
    /// - Parameter json: Optional JSONDictionary object.
    class func storeJSON(json: JSONDictionary?) throws {
        guard let path = jsonPath(), let json = json?.int_toJSONData() else {
            throw RequestError.parseError
        }
        try json.write(to: URL(fileURLWithPath: path), options: .atomic)
    }

    /// - Returns: Cached array of Geofence objects or nil.
    private class func readJSON() throws -> JSONDictionary? {
        guard let path = jsonPath(), let json = try? Data.init(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped).int_jsonDictionary else {
            throw RequestError.parseError
        }
        return json
    }

    /// - Returns: An array of cached Geofence objects.
    class func geofencesFromCache() throws -> [Geofence] {
        return try geofences(withJSON: readJSON(), readFromCache: true)
    }

    /// - Returns: An array of Geofence objects or throws a GeofenceError.
    /// - Parameter json: Optional JSONDictionary object.
    /// - Parameter readFromCache: If reading from cache we don't want to save `json` to file.
    class func geofences(withJSON json: JSONDictionary?, readFromCache: Bool? = false) throws -> [Geofence] {
        if readFromCache! == false {
            try storeJSON(json: json)
        }
        guard let json = json else {
            throw RequestError.parseError
        }
        let data: JSONDictionaryArray = try geoValue(forKey: .dataKey, dictionary: json)
        return data.map({ geofence(withJSON: $0) }).filter({ $0 != nil }).map({ $0! })
    }

    /// Initializes a Geofence object or throws a GeofenceError.
    /// - parameter json: Optional JSONDictionary object.
    class func geofence(withJSON json: JSONDictionary) -> Geofence? {
        do {
            let createDate: String = try geoValue(forKey: .dateCreatedKey, dictionary: json)
            let modifyDate: String = try geoValue(forKey: .dateUpdatedKey, dictionary: json)
            let geolocation: JSONDictionary = try geoValue(forKey: .geolocationKey, dictionary: json)
            let geofence = Geofence()
            geofence.latitude = try geoValue(forKey: .latitudeKey, dictionary: geolocation)
            geofence.longitude = try geoValue(forKey: .longitudeKey, dictionary: geolocation)
            geofence.createDate = RFC3339DateFormatter.date(from: createDate)?.timeIntervalSinceReferenceDate ?? 0
            geofence.modifyDate = RFC3339DateFormatter.date(from: modifyDate)?.timeIntervalSinceReferenceDate ?? 0
            geofence.radius = try geoValue(forKey: .radiusKey, dictionary: json)
            geofence.id = try geoValue(forKey: .idKey, dictionary: json)
            geofence.projectId = try geoValue(forKey: .projectIdKey, dictionary: json)
            geofence.name = try geoValue(forKey: .nameKey, dictionary: json)
            geofence.address = try geoValue(forKey: .addressKey, dictionary: json)
            return geofence
        } catch {
            // Silently fail for this geofence, letting others continue to be parsed.
            return nil
        }
    }
}
