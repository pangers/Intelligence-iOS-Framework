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

    let fakeUpdateUser = Phoenix.User(userId: 6016, companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t")
    let updateUserWeakPassword = Phoenix.User(userId: 6016, companyId: 1, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "t")
    let userWeakPassword = Phoenix.User(companyId: 1, username: "123", password: "123", firstName: "t", lastName: "t", avatarURL: "t")
    var identity:Phoenix.Identity?
    
    let validLogin = "{\n  \"access_token\": \"ZG1iY3dydWJudHYzY3FodHQ2cTdxdmhicWpoZDh1ODQ=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"rkdrdbyuh3awnsybvqvpgfvf4ymc8f5tmtbsbrfg7uppmnpxj7ggxjmapxnepmm3\"\n}"
    
    let validRefresh = "{\n  \"access_token\": \"dmdhdGc4MjZhZWdtczl1ZmFudDJ5bXc0ODI0ZDUydGs=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"9nr6dwgb7c8h3yhf5852tk3bm7kf5m29mwd6gp3d7gunec28hnawvssnkfj7a27k\"\n}"
    
    let validValidate = "{\n  \"access_token\": \"dmdhdGc4MjZhZWdtczl1ZmFudDJ5bXc0ODI0ZDUydGs=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7172\n}"
    
    let invalidToken = "{\n  \"error\": \"invalid_grant\",\n  \"error_description\": \"Invalid authorization grant request: 'refresh_token not valid'.\"\n}"

    let successfulAssignRoleResponse = "{\"TotalRecords\":1,\"Data\":[{\"Id\":1132,\"UserId\":6161,\"RoleId\":1008,\"ProviderId\":6,\"CompanyId\":3,\"ProjectId\":2030,\"CreateDate\":\"2015-10-06T11:55:40.5245055Z\",\"ModifyDate\":\"2015-10-06T11:55:40.5245055Z\"}]}"
    
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
    
    override func setUp() {
        super.setUp()
        self.identity = phoenix?.identity as? Phoenix.Identity
        mockOAuthProvider.reset()
    }
    
    override func tearDown() {
        super.tearDown()
        self.identity =  nil
    }
    
    
    // MARK: - Mock
    
    func mockGetUserMe(status: Int32 = 200) {
        let guURL = NSURLRequest.phx_URLRequestForUserMe(mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL
        mockResponseForURL(guURL,
            method: "GET",
            response: (data: status == 200 ? successfulResponseGetUser : nil, statusCode:status, headers:nil))
    }
    
    func mockValidate(status: Int32 = 200) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForValidate(mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: "GET",
            response: (data: status == 200 ? validValidate : nil, statusCode: status, headers: nil))
    }
    
    func mockUserCreation(status: Int32 = 200) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserCreation(fakeUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: "POST",
            response: (data: status == 200 ? successfulResponseCreateUser : nil, statusCode:status, headers:nil))
    }
    
    func mockUserUpdate(status: Int32 = 200) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserUpdate(fakeUpdateUser, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL!,
            method: "PUT",
            response: (data: status == 200 ? successfulResponseCreateUser : nil, statusCode:status, headers:nil))
    }
    
    func mockUserAssignRole(status: Int32 = 200) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserRoleAssignment(fakeUpdateUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: "POST",
            response: (data: status == 200 ? successfulAssignRoleResponse : nil, statusCode: status, headers: nil))
    }
    
    func mockRefreshAndLogin(status: Int32? = nil, loginStatus: Int32? = nil) {
        var responses = [MockResponse]()
        if status != nil {
            responses.append(MockResponse(status == 200 ? validRefresh : nil, status!, nil))
        }
        if status != 200 || status == nil && loginStatus != nil {
            responses.append(MockResponse(loginStatus == 200 ? validLogin : nil, loginStatus!, nil))
        }
        mockAuthenticationResponses(responses)
    }
    
    
    // MARK:- Login/Logout
    
    func fakeLoggedIn(oauth: PhoenixOAuthProtocol) {
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
    }
    
    func fakeLoggedOut(oauth: PhoenixOAuthProtocol) {
        mockOAuthProvider.reset(oauth)
    }
    
    func assertLoggedOut(oauth: PhoenixOAuthProtocol) {
        XCTAssert(oauth.userId == nil)
        XCTAssert(oauth.refreshToken == nil)
        XCTAssert(oauth.accessToken == nil)
        XCTAssert(oauth.password == nil)
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
    }
    
    func testValidateSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate()
        mockGetUserMe()
        
        let expectation = expectationWithDescription("mock validate")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateFailureRefreshSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(401)
        mockRefreshAndLogin(200, loginStatus: nil)
        mockGetUserMe()
        
        let expectation = expectationWithDescription("mock refresh")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateRefreshLoginFailure() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(401)
        mockRefreshAndLogin(401, loginStatus: 400)
        
        let expectation = expectationWithDescription("mock refresh")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error != nil)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateRefreshFailureLoginSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(401)
        mockRefreshAndLogin(401, loginStatus: 200)
        mockGetUserMe()
        
        let expectation = expectationWithDescription("mock refresh")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error, "Unexpeced login error")
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginLogoutSuccess() {
        XCTAssert(self.mockOAuthProvider.developerLoggedIn == false, "Should be logged out")
        
        mockOAuthProvider.loggedInUserOAuth.username = fakeUser.username
        mockOAuthProvider.loggedInUserOAuth.password = fakeUser.password
        
        mockRefreshAndLogin(nil, loginStatus: 200)
        mockGetUserMe()
        
        let expectation = expectationWithDescription("mock logout")
        
        phoenix?.identity.login(withUsername: fakeUser.username, password: fakeUser.password!) { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user != nil && error == nil, "Method should return authenticated = true")
            XCTAssert(self.mockOAuthProvider.loggedInUserOAuth.password == nil, "Password should be cleared")
            XCTAssert(user?.userId == 6016, "User ID should be available")
            XCTAssert(self.mockOAuthProvider.loggedInUserOAuth.userId != nil, "User ID should be stored")
            XCTAssert(self.mockOAuthProvider.developerLoggedIn == true, "Logged in flag should be set")
            
            // Logout...
            self.phoenix?.identity.logout()
            XCTAssert(self.mockOAuthProvider.developerLoggedIn == false)
            
            // Ensure details were cleared
            self.assertLoggedOut(self.mockOAuthProvider.loggedInUserOAuth)
            XCTAssert(self.mockOAuthProvider.loggedInUserOAuth.username == nil)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginSuccessGetMeFailure() {
        XCTAssert(!self.mockOAuthProvider.developerLoggedIn, "Phoenix is authenticated before a response")
        
        // Create expectation for login...
        mockRefreshAndLogin(nil, loginStatus: 200)
        mockGetUserMe(400)
        
        let expectation = expectationWithDescription("Expectation")
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user == nil && error != nil, "Method should return authenticated = false")
            
            XCTAssert(self.mockOAuthProvider.developerLoggedIn == false)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginFailure() {
        XCTAssert(!self.mockOAuthProvider.developerLoggedIn, "Phoenix is authenticated before a response")
        
        // Create expectation for login...
        mockRefreshAndLogin(nil, loginStatus: 400)
        
        let expectation = expectationWithDescription("Expectation")
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user == nil && error != nil, "Method should return authenticated = false")
            
            XCTAssertFalse(self.mockOAuthProvider.developerLoggedIn)
            self.assertLoggedOut(self.mockOAuthProvider.loggedInUserOAuth)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /// Verify that we logout clearing our tokens successfully when anonymously logged in.
    func testLogout() {
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
        
        // Fake login
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        mockOAuthProvider.developerLoggedIn = true
        
        phoenix?.identity.logout()
        
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
        assertLoggedOut(mockOAuthProvider.loggedInUserOAuth)
    }
    
    func testUserConstants() {
        let fake = fakeUser
        XCTAssert(fake.lockingCount == 0, "Locking count must be zero")
        XCTAssert(fake.reference == "", "Reference must be empty")
        XCTAssert(fake.isActive == true, "Active must be true")
        XCTAssert(fake.metadata == "", "Metadata must be empty")
        XCTAssert(fake.userTypeId == "User", "Type ID must be user")
    }
    

    // MARK:- Create User
    
    // Assures that when the user is not valid to create, an error is returned.
    func testCreateUserErrorOnUserCondition() {
        let user = Phoenix.User(companyId: 1, username: "", password: "123", firstName: "t", lastName: "t", avatarURL: "t")
        let URL = NSURLRequest.phx_URLRequestForUserCreation(user, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        assertURLNotCalled(URL)
        
        let expectation = expectationWithDescription("mock create user")
        
        identity!.createUser(user) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.InvalidUserError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    func testCreateUserSuccess() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Create
        mockUserCreation(200)
        mockUserAssignRole(200)
        
        identity!.createUser(fakeUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    func testCreateUserFailure() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Mock
        mockUserCreation(400)
        
        identity!.createUser(fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.UserCreationError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    func testCreateUserFailureDueToPasswordSecurity() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let URL = NSURLRequest.phx_URLRequestForUserCreation(fakeUser, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        // Assert that the call won't be done.
        assertURLNotCalled(URL)
        
        identity!.createUser(userWeakPassword) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.WeakPasswordError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }

    // MARK:- Update User
    
    func testUpdateUserSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserUpdate()
        
        identity!.updateUser(fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    func testUpdateUserFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserUpdate(400)
        
        identity!.updateUser(fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.UserUpdateError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testUpdateUserConditions() {
        XCTAssertFalse(Phoenix.User(userId: 6016, companyId: 0, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t").isValidToUpdate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(userId: 6016,companyId: 1, username: "", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t").isValidToUpdate, "No username allows to create user")
        XCTAssertFalse(Phoenix.User(userId: 6016,companyId: 1, username: "123", password: "", firstName: "t", lastName: "t", avatarURL: "t").isValidToUpdate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(userId: 6016,companyId: 1, username: "123", password: "Testing123", firstName: "", lastName: "t", avatarURL: "t").isValidToUpdate, "No firstname allows to create user")
        XCTAssertFalse(Phoenix.User(userId: 6016,companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "", avatarURL: "t").isValidToUpdate, "No lastname allows to create user")
        XCTAssertFalse(Phoenix.User(userId: 6016,companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "").isValidToUpdate, "No Avatar blocks to create user")
        XCTAssert(Phoenix.User(userId: 6016,companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "1").isValidToUpdate, "Can't send a complete user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "1").isValidToUpdate, "No user id")
    }
    
    func testUpdateUserFailureDueToPasswordSecurity() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let URL = NSURLRequest.phx_URLRequestForUserUpdate(updateUserWeakPassword, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        // Assert that the call won't be done.
        assertURLNotCalled(URL, method: "PUT")
        
        identity!.updateUser(updateUserWeakPassword) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.WeakPasswordError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testCreateUserConditions() {
        XCTAssertFalse(Phoenix.User(companyId: 0, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t").isValidToCreate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "t").isValidToCreate, "No username allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "", firstName: "t", lastName: "t", avatarURL: "t").isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "", lastName: "t", avatarURL: "t").isValidToCreate, "No firstname allows to create user")
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "", avatarURL: "t").isValidToCreate, "No lastname allows to create user")
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "").isValidToCreate, "No Avatar blocks to create user")
        
        XCTAssert(Phoenix.User(companyId: 1, username: "123", password: "Testing123", firstName: "t", lastName: "t", avatarURL: "1").isValidToCreate, "Can't send a complete user")
        
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
    
}
