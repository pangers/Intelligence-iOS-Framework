//
//  PhoenixURLRequestTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixURLRequestTestCase: XCTestCase {
    
    func testCreateUserRequest() {
        let companyId = 1
        let username = "123"
        let password = "456"
        let firstname = "789"
        let lastname = "012"
        let avatarURL = "345"
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let user = Phoenix.User(companyId: companyId, username: username, password: password, firstName: firstname, lastName: lastname, avatarURL: avatarURL)
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: MockConfiguration())

        XCTAssertEqual(request.URL!.absoluteString, "https://api.phoenixplatform.eu/identity/v1/projects/123/users")
        
        guard let userDictionary = request.HTTPBody?.phx_jsonArray?.first as? JSONDictionary else {
            XCTAssert(false,"Couldn't parse the HTTP Body")
            return
        }

        // Variable
        XCTAssertEqual(userDictionary["CompanyId"] as! Int, companyId)
        XCTAssertEqual(userDictionary["Username"] as! String, username)
        XCTAssertEqual(userDictionary["Password"] as! String, password)
        XCTAssertEqual(userDictionary["FirstName"] as! String, firstname)
        XCTAssertEqual(userDictionary["LastName"] as! String, lastname)
        XCTAssertEqual(userDictionary["AvatarURL"] as! String, avatarURL)

        // Fixed by SDK
        XCTAssertEqual(userDictionary["UserTypeId"] as! String, "User")
        XCTAssertEqual(userDictionary["MetaData"] as! String, "")
        XCTAssertEqual(userDictionary["LockingCount"] as! Int, 0)
        XCTAssertEqual(userDictionary["IsActive"] as! Int, 1)
        XCTAssertEqual(userDictionary["Reference"] as! String, "")
        
        print(userDictionary)
    }
    
}
