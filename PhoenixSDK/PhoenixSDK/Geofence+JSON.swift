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

extension Geofence {
    
    /// - Returns: Date formatter capable of parsing dates formatted like: '2015-07-08T08:04:48.403'
    private class var dateFormatter: NSDateFormatter {
        struct Static {
            static var instance : NSDateFormatter? = nil
            static var token : dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = NSDateFormatter()
            Static.instance?.dateFormat = "yyyy-MM-dd’T’HH:mm:ss.SSS"
        }
        return Static.instance!
    }
    
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
    class func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return "\(path)/Geofences.json"
    }
    
    /// Writes JSONDictionary to file.
    /// - Parameter json: Optional JSONDictionary object.
    class func storeJSON(json: JSONDictionary?) throws {
        guard let path = jsonPath(), json = json?.phx_toJSONData() else {
            throw GeofenceError.InvalidJSONError
        }
        json.writeToFile(path, atomically: true)
    }
    
    /// - Returns: Cached array of Geofence objects or nil.
    private class func readJSON() throws -> JSONDictionary? {
        guard let path = jsonPath(), json = NSData(contentsOfFile: path)?.phx_jsonDictionary else {
            throw GeofenceError.InvalidJSONError
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
            try storeJSON(json)
        }
        guard let json = json else {
            throw GeofenceError.InvalidJSONError
        }
        let data: JSONDictionaryArray = try geoValue(forKey: .DataKey, dictionary: json)
        return data.map({ geofence(withJSON: $0) }).filter({ $0 != nil }).map({ $0! })
    }
    
    /// - Returns: A Geofence object or throws a GeofenceError.
    /// - Parameter json: Optional JSONDictionary object.
    class func geofence(withJSON json: JSONDictionary) -> Geofence? {
        do {
            let createDate: String = try geoValue(forKey: .CreateDateKey, dictionary: json)
            let modifyDate: String = try geoValue(forKey: .ModifyDateKey, dictionary: json)
            let geolocation: JSONDictionary = try geoValue(forKey: .GeolocationKey, dictionary: json)
            let geofence = Geofence()
            geofence.latitude = try geoValue(forKey: .LatitudeKey, dictionary: geolocation)
            geofence.longitude = try geoValue(forKey: .LongitudeKey, dictionary: geolocation)
            geofence.createDate = dateFormatter.dateFromString(createDate)?.timeIntervalSinceReferenceDate ?? 0
            geofence.modifyDate = dateFormatter.dateFromString(modifyDate)?.timeIntervalSinceReferenceDate ?? 0
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