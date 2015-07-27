//
//  NSDataToJSON.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 27/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension NSData {
    typealias JSONArray = [JSONDictionary]
    typealias JSONDictionary = [String: AnyObject]
    func toJsonArray() -> JSONArray? {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments) as? JSONArray {
                return json
            }
        } catch let err {
            print(err)
        }
        return nil
    }
    func toJsonDictionary() -> JSONDictionary? {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions.AllowFragments) as? JSONDictionary {
                return json
            }
        } catch let err {
            print(err)
        }
        return nil
    }
}