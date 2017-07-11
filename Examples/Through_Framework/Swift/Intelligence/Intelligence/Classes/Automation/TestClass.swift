//
//  TestClass.swift
//  Intelligence
//
//  Created by chethan.palaksha on 23/4/17.
//  Copyright © 2017 TigerSpike. All rights reserved.
//

import Foundation
import IntelligenceSDK

class TestClass {
    
    //Identity
    func startupIdentitModule(complition:@escaping(Bool)->()) {
        
        IntelligenceManager.intelligence?.identity.startup(completion: { (status) in
            complition(status)
        })
    }
    
    func shutDownIdentitModule(complition:@escaping(NSError?)->()) {
        
        IntelligenceManager.intelligence?.identity.shutdown()
        complition(nil)
    }
    
    
    func loginUser(complition: @escaping(Intelligence.User?,NSError?) -> ()) {
        
        IntelligenceManager.intelligence?.identity.getMe(callback: { (user, error) in
            
            let userName = user?.username
            let password = UserDefaults.standard.string(forKey: "Test_Password")
            
            self.loginUser(with: userName!, password: password!, callback: { (user, error) in
                
                guard let _ = error else {
                    print("Error")
                    return
                }
            })
        })
    }
    
    
    func getMe(complition: @escaping(Intelligence.User?,NSError?) -> ())  {
        IntelligenceManager.intelligence?.identity.getCurrentSDKUser(callback: { (user, error) in
                    complition(user,error)
            })
    }
    
    func getUser(userId:Int, complition: @escaping(Intelligence.User?,Error?) -> ()) {
        
        IntelligenceManager.intelligence?.identity.getUser(with: userId, callback: { (user, error) in
            complition(user,error)
        })
    }
    
    func updateUser(user:Intelligence.User,complition: @escaping(Intelligence.User?,NSError?) -> ()){
        
        user.firstName = "Test-FirstName"
        user.lastName = "Test-lastName"
        user.avatarURL = "http://google.com"
        
        IntelligenceManager.intelligence?.identity.update(user: user, callback: { (user, error) in
            complition(user,error)
        })
    }
    
    func assisgn(role:Int, user:Intelligence.User,complition:@escaping(Intelligence.User?,NSError?) -> ()){
        
        IntelligenceManager.intelligence?.identity.assignRole(to: role, user: user, callback: { (user, error) in
            complition(user,error)
        })
    }
    
    func revoke(role:Int, user:Intelligence.User,complition:@escaping(Intelligence.User?,NSError?) -> ()) {
        
        IntelligenceManager.intelligence?.identity.revokeRole(with: role, user: user, callback: { (user, error) in
            complition(user,error)
        })
    }
    
    func logout(complition:@escaping(NSError?) -> ())  {
        IntelligenceManager.intelligence?.identity.logout()
        complition(nil)
    }
    
    
    func registerDevice(token:Data,complition:@escaping(Int,NSError?) -> ())  {
        IntelligenceManager.intelligence?.identity.registerDeviceToken(with: token, callback: { (connectionID, error) in
            complition(connectionID,error)
        })
    }
    
    func unRegisterDevice(tokenID:Int,complition:@escaping(NSError?) -> ())  {
        
        IntelligenceManager.intelligence?.identity.unregisterDeviceToken(with: tokenID, callback: { (error) in
            complition(nil)
        })
    }
    
    
    //No need of test case
    func loginUser(with username:String, password:String, callback: @escaping (Intelligence.User?, NSError?) -> ()){
        
        IntelligenceManager.intelligence?.identity.logout()
        
        IntelligenceManager.intelligence?.identity.login(with: username, password: password, callback: { [weak self] (user, error) -> () in
            guard self != nil else {
                return
            }
            
            DispatchQueue.main.async{
                
                guard error == nil else {
                    callback(nil,error)
                    return
                }
                callback(user,error)
            }
        })
    }
    
    // Analytics event
    func  sendSampleEvents(eventCount : Int) {
        
        let metaData:[String:AnyObject] = ["AppName" : "Intelleigence Sample APP" as AnyObject]
        for i in 0 ..< eventCount{
            let str = String(format:"SampleEvent - %d",i)
            let event = Event(withType: str, value: 0.0, targetId:String(format:"SampleEvent - %d",i), metadata: metaData)
            IntelligenceManager.intelligence?.analytics.track(event: event)
        }
    }
    
    func startupAnalyticsModule(complition:@escaping(Bool)->()) {
        
        IntelligenceManager.intelligence?.analytics.startup(completion: { (status) in
            complition(status)
        })
    }
    
    func shutDownAnalyticsModule(complition:@escaping(NSError?)->()) {
        
        IntelligenceManager.intelligence?.analytics.shutdown()
        complition(nil)
    }
    
    func pauseAnalyticsModule(complition:@escaping(NSError?)->()) {
        
        IntelligenceManager.intelligence?.analytics.pause()
        complition(nil)
    }
    
    func resumeAnalyticsModule(complition:@escaping(NSError?)->()) {
        
        IntelligenceManager.intelligence?.analytics.resume()
        complition(nil)
    }
    

}
