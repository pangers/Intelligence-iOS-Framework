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

    let fakeUpdateUser = Phoenix.User(userId: mockUserID, companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    let updateUserWeakPassword = Phoenix.User(userId: mockUserID, companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    let userWeakPassword = Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    var identity:Phoenix.Identity?
    
    let badResponse = "BAD RESPONSE"
    
    let validLogin = "{\n  \"access_token\": \"\(userAccessToken)=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"\(userRefreshToken)\"\n}"
    
    let validRefresh = "{\n  \"access_token\": \"\(userAccessToken)=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"\(userRefreshToken)\"\n}"
    
    let validValidate = "{\n  \"access_token\": \"\(userAccessToken)=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7172\n}"
    
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
    
    func mockGetUserMe(status: HTTPStatusCode = .Success) {
        let guURL = NSURLRequest.phx_URLRequestForUserMe(mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL
        mockResponseForURL(guURL,
            method: .GET,
            response: (data: status == .Success ? successfulResponseGetUser : nil, statusCode:status, headers:nil))
    }
    
    func mockValidate(status: HTTPStatusCode = .Success, alternateResponse: String? = nil) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForValidate(mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .GET,
            response: (data: status == .Success ? (alternateResponse ?? validValidate) : nil, statusCode: status, headers: nil))
    }
    
    func mockUserCreation(status: HTTPStatusCode = .Success) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserCreation(fakeUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .POST,
            response: (data: status == .Success ? successfulResponseCreateUser : nil, statusCode:status, headers:nil))
    }
    
    func mockUserUpdateURL() -> NSURL {
        return NSURLRequest.phx_URLRequestForUserUpdate(fakeUpdateUser, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL!
    }
    
    func mockUserUpdate(status: HTTPStatusCode = .Success) {
        mockResponseForURL(mockUserUpdateURL(),
            method: .PUT,
            response: (data: status == .Success ? successfulResponseCreateUser : nil, statusCode:status, headers:nil))
    }
    
    func mockUserUpdateResponses(status: HTTPStatusCode = .Unauthorized, secondStatus: HTTPStatusCode = .Success) -> [MockResponse] {
        let responses = [
            MockResponse((data: status == .Success ? successfulResponseCreateUser : nil, statusCode: status, headers: nil)),
            MockResponse((data: secondStatus == .Success ? successfulResponseCreateUser : nil, statusCode: secondStatus, headers: nil))
        ]
        return responses
    }
    
    func mockUserAssignRole(status: HTTPStatusCode = .Success) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserRoleAssignment(fakeUpdateUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .POST,
            response: (data: status == .Success ? successfulAssignRoleResponse : nil, statusCode: status, headers: nil))
    }
    
    func mockRefreshAndLogin(status: HTTPStatusCode? = nil,
        loginStatus: HTTPStatusCode? = nil,
        alternateRefreshResponse: String? = nil,
        alternateLoginResponse: String? = nil)
    {
        var responses = [MockResponse]()
        let refreshResponse = alternateRefreshResponse ?? validRefresh
        let loginResponse = alternateLoginResponse ?? validLogin
        
        if status != nil {
            responses.append(MockResponse(status == .Success ? refreshResponse : nil, status!, nil))
        }
        if status != .Success || status == nil && loginStatus != nil {
            responses.append(MockResponse(loginStatus == .Success ? loginResponse : nil, loginStatus!, nil))
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
    
    func testValidateSuccessParseError() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(.Success, alternateResponse: badResponse)
        
        let expectation = expectationWithDescription("mock validate")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateFailureRefreshSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(.Unauthorized)
        mockRefreshAndLogin(.Success, loginStatus: nil)
        mockGetUserMe()
        
        let expectation = expectationWithDescription("mock refresh")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateFailureRefreshSuccessParseError() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(.Unauthorized)
        mockRefreshAndLogin(.Success, loginStatus: nil, alternateRefreshResponse: badResponse)
        
        let expectation = expectationWithDescription("mock refresh")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateRefreshLoginFailure() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(.Unauthorized)
        mockRefreshAndLogin(.Unauthorized, loginStatus: .BadRequest)
        
        let expectation = expectationWithDescription("mock refresh")
        
        phoenix?.identity?.login(withUsername: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error != nil)
            expectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateRefreshFailureLoginSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(.Unauthorized)
        mockRefreshAndLogin(.Unauthorized, loginStatus: .Success)
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
        
        mockRefreshAndLogin(nil, loginStatus: .Success)
        mockGetUserMe()
        
        let expectation = expectationWithDescription("mock logout")
        
        phoenix?.identity.login(withUsername: fakeUser.username, password: fakeUser.password!) { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user != nil && error == nil, "Method should return authenticated = true")
            XCTAssert(self.mockOAuthProvider.loggedInUserOAuth.password == nil, "Password should be cleared")
            XCTAssert(user?.userId == mockUserID, "User ID should be available")
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
        mockRefreshAndLogin(nil, loginStatus: .Success)
        mockGetUserMe(.BadRequest)
        
        let expectation = expectationWithDescription("Expectation")
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
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
        mockRefreshAndLogin(nil, loginStatus: .BadRequest)
        
        let expectation = expectationWithDescription("Expectation")
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
            XCTAssert(user == nil && error != nil, "Method should return authenticated = false")
            
            XCTAssertFalse(self.mockOAuthProvider.developerLoggedIn)
            self.assertLoggedOut(self.mockOAuthProvider.loggedInUserOAuth)
            
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginSuccessParseError() {
        XCTAssert(!self.mockOAuthProvider.developerLoggedIn, "Phoenix is authenticated before a response")
        
        // Create expectation for login...
        mockRefreshAndLogin(nil, loginStatus: .Success, alternateLoginResponse: badResponse)
        
        let expectation = expectationWithDescription("Expectation")
        phoenix?.identity.login(withUsername: "username", password: "password") { (user, error) -> () in
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
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
        let user = Phoenix.User(companyId: mockCompanyID, username: "", password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
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
        mockUserCreation(.Success)
        mockUserAssignRole(.Success)
        
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
        mockUserCreation(.BadRequest)
        
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
        mockUserUpdate(.BadRequest)
        
        identity!.updateUser(fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.UserUpdateError.rawValue, "Unexpected error type raised")
            XCTAssert(error?.domain == IdentityError.domain, "Unexpected error type raised")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    func testUpdateUserFailureLoginPassedUpdateSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockRefreshAndLogin(.Success, loginStatus: nil)
        mockResponseForURL(mockUserUpdateURL(), method: .PUT, responses: mockUserUpdateResponses())
        
        identity?.updateUser(fakeUpdateUser) { (user, error) -> Void in
            print(error)
            print(user)
            //XCTAssert(user != nil, "User not found")
            //XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testUpdateUserConditions() {
        XCTAssertFalse(Phoenix.User(userId: mockUserID, companyId: 0, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: "", password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No username allows to create user")
        XCTAssertFalse(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: "", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: "", lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No firstname allows to create user")
        XCTAssertFalse(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: "", avatarURL: mockAvatarURL).isValidToUpdate, "No lastname allows to create user")
        XCTAssertFalse(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "").isValidToUpdate, "No Avatar blocks to create user")
        XCTAssert(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToUpdate, "Can't send a complete user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToUpdate, "No user id")
    }
    
    func testUpdateUserFailureDueToPasswordSecurity() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let URL = NSURLRequest.phx_URLRequestForUserUpdate(updateUserWeakPassword, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).URL!
        
        // Assert that the call won't be done.
        assertURLNotCalled(URL, method: .PUT)
        
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
        XCTAssertFalse(Phoenix.User(companyId: 0, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: "", password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No username allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: "", lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No firstname allows to create user")
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: "", avatarURL: mockAvatarURL).isValidToCreate, "No lastname allows to create user")
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "").isValidToCreate, "No Avatar blocks to create user")
        
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToCreate, "Can't send a complete user")
        
    }
    // MARK:- Password security
    
    func testPasswordRequirementsVerification() {
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "123456789", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only numbers passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "abcdefghf", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only letters passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "abc", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only letters below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only  numbers below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "test123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Numbers and letters below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "testing123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with no uppercase, numbers and more than 8 characters passes the test")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "test1234", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with no uppercase, numbers and exactly 8 characters passes the test")
        
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with uppercase, numbers and more than 8 characters fails the test")
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "Test1234", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with uppercase, numbers and exactly 8 characters fails the test")
    }
    
}
