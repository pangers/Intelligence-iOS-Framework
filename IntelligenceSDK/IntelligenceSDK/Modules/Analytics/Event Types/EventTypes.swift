//
//  EventTypes.swift
//  IntelligenceSDK
//
//  Created by chethan.palaksha on 18/1/17.
//  Copyright © 2017 Tigerspike. All rights reserved.
//

import Foundation


internal enum EventTypes : String {
    
    case ApplicationInstall = "Phoenix.Identity.Application.Installed"
    case ApplicationUpdate = "Phoenix.Identity.Application.Updated"
    case UserCreated = "Phoenix.Identity.User.Created"
    
    func  saveToUserDefault(Obj : Any) {
        UserDefaults.standard.set(Obj, forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func  object() -> Any? {
        let obj = UserDefaults.standard.object(forKey: self.rawValue)
        return obj
    }
    
    func  reset()  {
        UserDefaults.standard.removeObject(forKey: self.rawValue)
        UserDefaults.standard.synchronize()
    }
}
