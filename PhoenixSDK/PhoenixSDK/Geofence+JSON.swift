//
//  PHXGeofenceJSON.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 06/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

private enum GeofenceKey: String {
    case DataKey = "Data"
    case IdKey = "Id"
    case ProjectIdKey = "ProjectId"
    case NameKey = "Name"
    case AddressKey = "Address"
    case RadiusKey = "Radius"
    case GeolocationKey = "Geolocation"
    case LatitudeKey = "Latitude"
    case LongitudeKey = "Longitude"
    case ModifyDateKey = "ModifyDate"
    case CreateDateKey = "CreateDate"
}

private enum GeofenceError: ErrorType {
    case InvalidPropertyError(GeofenceKey)
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
    private class func jsonPath() -> String? {
        guard let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first else { return nil }
        return path.stringByAppendingPathComponent("/Geofences.json")
    }
    
    /// Writes JSONDictionary to file.
    private class func storeJSON(json: JSONDictionary?) {
        guard let path = jsonPath(), json = json?.phx_toJSONData() else { return }
        json.writeToFile(path, atomically: true)
    }
    
    /// - Returns: Cached array of Geofence objects or nil.
    private class func readJSON() -> JSONDictionary? {
        guard let path = jsonPath(), json = NSData(contentsOfFile: path)?.phx_jsonDictionary else { return nil }
        return json
    }
    
    /// - Returns: An array of cached Geofence objects.
    class func geofencesFromCache() -> [Geofence] {
        return geofencesFromJSON(readJSON(), readFromCache: true)
    }
    
    /// - Returns: An array of Geofence objects or throws a GeofenceError.
    class func geofencesFromJSON(json: JSONDictionary?, readFromCache: Bool? = false) -> [Geofence] {
        if readFromCache! == false { storeJSON(json) }
        guard let json = json else { return [Geofence]() }
        do {
            let data: JSONArray = try geoValue(forKey: .DataKey, dictionary: json)
            return data.map({ geofenceFromJSON($0) }).filter({ $0 != nil }).map({ $0! })
        }
        catch {
            assert(false, "Failed to load multiple geofences")
            return [Geofence]()
        }
    }
    
    /// - Returns: A Geofence object or throws a GeofenceError.
    class func geofenceFromJSON(json: JSONDictionary) -> Geofence? {
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
        }
        catch let err as GeofenceError {
            switch err {
            case .InvalidPropertyError(let key):
            assert(false, "Failed to load geofence (\(key.rawValue))")
            }
            return nil
        } catch {
            assert(false, "Unhandled error")
        }
    }
}