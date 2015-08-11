//
//  PhoenixIdentityTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest

@testable import PhoenixSDK

class PhoenixIdentityTestCase: PhoenixBaseTestCase {

    let fakeUser = Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t")
    let userWeakPassword = Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "t")
    var identity:Phoenix.Identity?
    
    let expectationTimeout:NSTimeInterval = 5
    
    let successfulResponseCreateUser = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Id\": 6016," +
        "\"UserTypeId\": \"User\"," +
        "\"CompanyId\": 3," +
        "\"Username\": \"test20\"," +
        "\"FirstName\": \"t\"," +
        "\"LastName\": \"t\"," +
        "\"LockingCount\": 0," +
        "\"Reference\": \"\"," +
        "\"IsActive\": true," +
        "\"CreateDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"ModifyDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"MetaDataParameters\": []," +
        "\"Identifiers\": []" +
        "}]" +
    "}"

    let successfulResponseGetUser = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Id\": 6016," +
        "\"UserTypeId\": \"User\"," +
        "\"CompanyId\": 3," +
        "\"Username\": \"test20\"," +
        "\"FirstName\": \"t\"," +
        "\"LastName\": \"t\"," +
        "\"LockingCount\": 0," +
        "\"Reference\": \"\"," +
        "\"IsActive\": true," +
        "\"LastLoginDate\": \"2015-08-05T14:29:01.657\"," +
        "\"CreateDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"ModifyDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"MetaDataParameters\": []," +
        "\"Identifiers\": []" +
        "}]" +
    "}"
    
    let noUsersResponse = "{" +
        "\"TotalRecords\": 0," +
        "\"Data\": []" +
    "}"
    
    override func setUp() {
        super.setUp()
        self.identity = phoenix?.identity as? Phoenix.Identity
    }
    
    override func tearDown() {
        super.tearDown()
        self.configuration = nil
        self.identity =  nil
    }
    
    // MARK:- Create User
    
    func testCreateUserSuccess() {
        let user = fakeUser
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration!).URL!

        // Mock 200 on auth
        mockResponseForAuthentication(200)
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulResponseCreateUser, statusCode:200, headers:nil))
        
        identity!.createUser(user) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testCreateUserFailure() {
        let user = fakeUser
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration!).URL!

        // Mock 200 on auth
        mockResponseForAuthentication(200)
        
        // Mock
        mockResponseForURL(request,
            method: "POST",
            response: (data: successfulResponseCreateUser, statusCode:400, headers:nil))

        identity!.createUser(user) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.UserCreationError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testCreateUserConditions() {
        XCTAssertFalse(Phoenix.User(companyId: 0, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "t").isValidToCreate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "", password: "123", firstName: "t", lastName: "t", avatarURL: "t").isValidToCreate, "No username allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "", firstName: "t", lastName: "t", avatarURL: "t").isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "", lastName: "t", avatarURL: "t").isValidToCreate, "No firstname allows to create user")
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "t", lastName: "", avatarURL: "t").isValidToCreate, "No lastname allows to create user")
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "").isValidToCreate, "No Avatar blocks to create user")
    
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "1").isValidToCreate, "Can't send a complete user")
    }
    
    // MARK:- GetMe
    
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testAnonymousAuthThenUserLoginThenUserLogout() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        // Create expectation for login...
        
        let responses = [MockResponse(loggedInTokenSuccessfulResponse, 200, nil),
            MockResponse(anonymousTokenSuccessfulResponse, 200, nil)]
        mockAuthenticationResponses(responses)
        
        let initialRequest = NSURLRequest(URL: NSURL(string: "http://www.google.com/")!)
        let stringData = "Hola"
        let statusCode = Int32(200)
        // We're logged out, lets enqeuue a generic request to force enqueue an anonymous login
        mockResponseForURL(initialRequest.URL!, method: nil, response: (data: stringData, statusCode: statusCode, headers: nil))
        
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration!).URL!
        mockResponseForURL(request,
            method: "GET",
            response: (data: successfulResponseGetUser, statusCode:200, headers:nil))
        
        let expectation = expectationWithDescription("login-logout-google-anonymous-login expectation")
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user != nil && error == nil, "Method should return authenticated = true")
            
            // Ensure user was parsed.
            XCTAssert(user?.userId == 6016)
            
            // Ensure user id was stored
            XCTAssert(self.phoenix?.network.authentication.userId != nil)
            
            XCTAssert(self.checkLoggedIn == true, "Phoenix should be logged in")
            
            // Logout...
            self.phoenix?.identity.logout()
            XCTAssert(self.checkLoggedIn == false, "Phoenix should be logged out")
            
            XCTAssert(self.phoenix?.network.authentication.userId == nil)
            
            // Execute google request to enqueue authentication
            self.phoenix?.network.executeRequest(initialRequest, callback: { (data, response, error) -> () in
                expectation.fulfill()
            })
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkAuthenticated == true, "Phoenix is authenticated after a login-logout-anonymouslogin")
        }
    }
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the access_token does not match the previous one.
    /*func testLoginFailed() {
        XCTAssert(!checkAuthenticated, "Phoenix is authenticated before a response")
        
        // Create expectation for login...
        
        let responses = [MockResponse(loggedInTokenSuccessfulResponse, 200, nil)]
        mockAuthenticationResponses(responses)
        
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration!).URL!
        mockResponseForURL(request,
            method: "GET",
            response: (data: successfulResponseGetUser, statusCode:200, headers:nil))
        
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user != nil && error == nil, "Method should return authenticated = true")
            
            // Ensure user was parsed.
            XCTAssert(user?.userId == 6016)
            
            // Ensure user id was stored
            XCTAssert(self.phoenix?.network.authentication.userId != nil)
        }
        
        waitForExpectationsWithTimeout(expectationTimeout) { (error:NSError?) -> Void in
            XCTAssertNil(error,"Error in expectation")
            XCTAssert(self.checkAuthenticated == false, "Phoenix is authenticated after a login-logout-anonymouslogin")
        }
    }*/
    
    /// Verify that we logout clearing our tokens successfully when anonymously logged in.
    func testLogout() {
        // Mock that we have a token
        mockValidTokenStorage()
        XCTAssert(checkAuthenticated, "Phoenix is authenticated before a response")
        
        phoenix?.identity.logout()
        XCTAssert(!checkLoggedIn, "Phoenix is not authenticated after a successful response")
    }
    
    
    

    /*func testGetMeSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration!).URL!
        
        // Mock request being authorized
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: successfulResponseGetUser, statusCode:200, headers:nil))
        
        identity!.getMe { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testGetMeFailure() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration!).URL!
        
        // Mock request being authorized
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: "", statusCode:400, headers:nil))
        
        identity!.getMe { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.GetUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testGetUserMeNoUsersBack() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForGetUserMe(configuration!).URL!
        
        // Mock request being authorized
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: noUsersResponse, statusCode:200, headers:nil))
        
        identity!.getMe { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.GetUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }*/
    
    // MARK:- Get User by id
    
    func testGetUserByIdSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForGetUserById(10, withConfiguration: configuration!).URL!
        
        // Mock request being authorized
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: successfulResponseGetUser, statusCode:200, headers:nil))
        
        identity!.getUser(10) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    func testGetUserByIdFailure() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForGetUserById(10, withConfiguration: configuration!).URL!
        
        // Mock request being authorized
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: "", statusCode:400, headers:nil))
        
        identity!.getUser(10) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.GetUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }

    func testGetUserByIdInvalidId() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock request being authorized
        mockValidTokenStorage()

        identity!.getUser(-1) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.InvalidUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }

    func testGetUserByIdNoUsersBack() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForGetUserById(10, withConfiguration: configuration!).URL!
        
        // Mock request being authorized
        mockValidTokenStorage()
        
        // Mock
        mockResponseForURL(request,
            method: "GET",
            response: (data: noUsersResponse, statusCode:200, headers:nil))
        
        identity!.getUser(10) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.GetUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }
    
    // MARK:- Helpers
    
    // Assures that when the user is not valid to create, an error is returned.
    func testIdentityErrorOnUserCondition() {
        let user = Phoenix.User(companyId: 1, username: "", password: "123", firstName: "t", lastName: "t", avatarURL: "t")
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration!).URL!

        assertURLNotCalled(request)
        
        identity!.createUser(user) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.InvalidUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
        }
    }

    // MARK:- Password security
    
    func testPasswordRequirementsVerification() {
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "123456789", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Only numbers passes the check")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "abcdefghf", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Only letters passes the check")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "abc", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Only letters below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Only  numbers below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "test123", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Numbers and letters below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "testing123", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Letters with no uppercase, numbers and more than 8 characters passes the test")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "test1234", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Letters with no uppercase, numbers and exactly 8 characters passes the test")
        
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Letters with uppercase, numbers and more than 8 characters fails the test")
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "Test1234", firstName: "t", lastName: "t", avatarURL: "t").isPasswordSecure(), "Letters with uppercase, numbers and exactly 8 characters fails the test")
    }
    
    func testCreateUserFailureDueToPasswordSecurity() {
        let user = userWeakPassword
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let request = NSURLRequest.phx_httpURLRequestForCreateUser(user, configuration: configuration!).URL!

        // Assert that the call won't be done.
        assertURLNotCalled(request)

        identity!.createUser(user) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.WeakPasswordError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        
        waitForExpectationsWithTimeout(2) { (_:NSError?) -> Void in
            // Wait for calls to be made and the callback to be notified
        }
    }

}
