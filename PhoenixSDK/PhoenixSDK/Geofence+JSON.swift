//
//  PHXGeofenceJSON.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal enum GeofenceKey: String {
    /// Top level data key
    case DataKey = "Data"
    /// Identifier within a data object.
    case IdKey = "Id"
    /// Project Identifier key within a data object.
    case ProjectIdKey = "ProjectId"
    /// Name key within a data object.
    case NameKey = "Name"
    /// Address key within a data object.
    case AddressKey = "Address"
    /// Radius key within a data object.
    case RadiusKey = "Radius"
    /// Modify date key within a data object.
    case ModifyDateKey = "ModifyDate"
    /// Create date key within a data object.
    case CreateDateKey = "CreateDate"
    /// Geolocation key within a data object.
    case GeolocationKey = "Geolocation"
    /// Latitude key within a geolocation object.
    case LatitudeKey = "Latitude"
    /// Longitude key within a geolocation object.
    case LongitudeKey = "Longitude"
}

internal extension Geofence {
    
    // For some reason this isn't working as a Dictionary extension with a where clause,
    // Apple may have broken that functionality in the current beta.
    /// - Returns: Value for a specific GeofenceKey in our JSONDictionary or throws a GeofenceError.
    private class func geoValue<T>(forKey key: GeofenceKey, dictionary: JSONDictionary) throws -> T {
        guard let output = dictionary[key.rawValue] as? T else {
            throw GeofenceError.InvalidPropertyError(key)
        }
        return output
    }
    
    /// - Returns: Path to Geofences JSON file.
    internal class func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return "\(path)/Geofences.json"
    }
    
    /// Writes JSONDictionary to file.
    /// - Parameter json: Optional JSONDictionary object.
    internal class func storeJSON(json: JSONDictionary?) throws {
        guard let path = jsonPath(), json = json?.phx_toJSONData() else {
            throw RequestError.ParseError
        }
        json.writeToFile(path, atomically: true)
    }
    
    /// - Returns: Cached array of Geofence objects or nil.
    private class func readJSON() throws -> JSONDictionary? {
        guard let path = jsonPath(), json = NSData(contentsOfFile: path)?.phx_jsonDictionary else {
            throw RequestError.ParseError
        }
        return json
    }
    
    /// - Returns: An array of cached Geofence objects.
    internal class func geofencesFromCache() throws -> [Geofence] {
        return try geofences(withJSON: readJSON(), readFromCache: true)
    }
    
    /// - Returns: An array of Geofence objects or throws a GeofenceError.
    /// - Parameter json: Optional JSONDictionary object.
    /// - Parameter readFromCache: If reading from cache we don't want to save `json` to file.
    internal class func geofences(withJSON json: JSONDictionary?, readFromCache: Bool? = false) throws -> [Geofence] {
        if readFromCache! == false {
            try storeJSON(json)
        }
        guard let json = json else {
            throw RequestError.ParseError
        }
        let data: JSONDictionaryArray = try geoValue(forKey: .DataKey, dictionary: json)
        return data.map({ geofence(withJSON: $0) }).filter({ $0 != nil }).map({ $0! })
    }
    
    /// - Returns: A Geofence object or throws a GeofenceError.
    /// - Parameter json: Optional JSONDictionary object.
    internal class func geofence(withJSON json: JSONDictionary) -> Geofence? {
        do {
            let createDate: String = try geoValue(forKey: .CreateDateKey, dictionary: json)
            let modifyDate: String = try geoValue(forKey: .ModifyDateKey, dictionary: json)
            let geolocation: JSONDictionary = try geoValue(forKey: .GeolocationKey, dictionary: json)
            let geofence = Geofence()
            geofence.latitude = try geoValue(forKey: .LatitudeKey, dictionary: geolocation)
            geofence.longitude = try geoValue(forKey: .LongitudeKey, dictionary: geolocation)
            geofence.createDate = RFC3339DateFormatter.dateFromString(createDate)?.timeIntervalSinceReferenceDate ?? 0
            geofence.modifyDate = RFC3339DateFormatter.dateFromString(modifyDate)?.timeIntervalSinceReferenceDate ?? 0
            geofence.radius = try geoValue(forKey: .RadiusKey, dictionary: json)
            geofence.id = try geoValue(forKey: .IdKey, dictionary: json)
            geofence.projectId = try geoValue(forKey: .ProjectIdKey, dictionary: json)
            geofence.name = try geoValue(forKey: .NameKey, dictionary: json)
            geofence.address = try geoValue(forKey: .AddressKey, dictionary: json)
            return geofence
        } catch {
            // Silently fail for this geofence, letting others continue to be parsed.
            return nil
        }
    }
}