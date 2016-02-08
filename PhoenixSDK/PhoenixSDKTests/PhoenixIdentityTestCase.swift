//
//  IdentityModuleTestCase.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import PhoenixSDK

class IdentityModuleTestCase: PhoenixBaseTestCase {

    let fakeUpdateUser = Phoenix.User(userId: mockUserID, companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    let updateUserWeakPassword = Phoenix.User(userId: mockUserID, companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    let userWeakPassword = Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    var identity: IdentityModule?
    
    let badResponse = "BAD RESPONSE"
    
    let validLogin = "{\n  \"access_token\": \"\(userAccessToken)=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"\(userRefreshToken)\"\n}"
    
    let validRefresh = "{\n  \"access_token\": \"\(userAccessToken)=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7200,\n  \"refresh_token\": \"\(userRefreshToken)\"\n}"
    
    let validValidate = "{\n  \"access_token\": \"\(userAccessToken)=\",\n  \"token_type\": \"bearer\",\n  \"expires_in\": 7172\n}"
    
    let invalidToken = "{\n  \"error\": \"invalid_grant\",\n  \"error_description\": \"Invalid authorization grant request: 'refresh_token not valid'.\"\n}"

    let successfulAssignRoleResponse = "{\"TotalRecords\":1,\"Data\":[{\"Id\":1132,\"UserId\":6161,\"RoleId\":1008,\"ProviderId\":6,\"CompanyId\":3,\"ProjectId\":2030,\"CreateDate\":\"2015-10-06T11:55:40.5245055Z\",\"ModifyDate\":\"2015-10-06T11:55:40.5245055Z\"}]}"
    
    let fakeRoleId = 1008
    let successfulRevokeRoleResponse = "{\"TotalRecords\":1,\"Data\":[{\"Id\":1132,\"UserId\":6161,\"RoleId\":1008,\"CreateDate\":\"2015-10-06T11:55:40.5245055Z\",\"ModifyDate\":\"2015-10-06T11:55:40.5245055Z\"}]}"
    
    let invalidRoleId = 1
    let failureRevokeRoleResponse = "{\"Message\": \"SUCCESS\", \"TotalCount\": 0, \"Data\": []}"
    
    let successfulResponseCreateUser = "{" +
        "\"TotalRecords\": 1," +
        "\"Data\": [{" +
        "\"Id\": 6016," +
        "\"UserTypeId\": 6," +
        "\"CompanyId\": 3," +
        "\"Username\": \"test20\"," +
        "\"FirstName\": \"t\"," +
        "\"LastName\": \"t\"," +
        "\"LockingCount\": 0," +
        "\"Reference\": \"t.t\"," +
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
        "\"UserTypeId\": 6," +
        "\"CompanyId\": 3," +
        "\"Username\": \"test20\"," +
        "\"FirstName\": \"t\"," +
        "\"LastName\": \"t\"," +
        "\"LockingCount\": 0," +
        "\"Reference\": \"t.t\"," +
        "\"IsActive\": true," +
        "\"LastLoginDate\": \"2015-08-05T14:29:01.657\"," +
        "\"CreateDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"ModifyDate\": \"2015-08-04T08:13:02.8004593Z\"," +
        "\"MetaDataParameters\": []," +
        "\"Identifiers\": []" +
        "}]" +
    "}"
    
    let fakeDeviceToken = "d3e3a7db07691f8f698e5139310cce50f5e2d2e36020e2f70187bf23b175ec01"
    let fakeTokenID = 18952
    let successfulResponseCreateIdentifier = "{\"TotalRecords\":1,\"Data\":[{\"Id\":18952,\"ProjectId\":2030,\"UserId\":6161,\"IdentifierTypeId\":\"iOS_Device_Token\",\"IsConfirmed\":false,\"Value\":\"d3e3a7db07691f8f698e5139310cce50f5e2d2e36020e2f70187bf23b175ec01\",\"CreateDate\":\"2015-10-13T08:29:14.9413947Z\",\"ModifyDate\":\"2015-10-13T08:29:14.9413947Z\"}]}"
    let unhandledJSONResponseCreateIdentifier = "{\"TotalRecords\":1,\"Data\":[{\"Identifier\":18952,\"ProjectId\":2030,\"UserId\":6161,\"IdentifierTypeId\":\"iOS_Device_Token\",\"IsConfirmed\":false,\"Value\":\"d3e3a7db07691f8f698e5139310cce50f5e2d2e36020e2f70187bf23b175ec01\",\"CreateDate\":\"2015-10-13T08:29:14.9413947Z\",\"ModifyDate\":\"2015-10-13T08:29:14.9413947Z\"}]}"
    let successfulResponseDeleteIdentifier = "{\"TotalRecords\":1,\"Data\":[{\"Id\":18952,\"IdentifierTypeId\":\"iOS_Device_Token\",\"IsConfirmed\":false,\"Value\":\"d3e3a7db07691f8f698e5139310cce50f5e2d2e36020e2f70187bf23b175ec01\",\"CreateDate\":\"2015-10-13T08:29:14.9413947Z\",\"ModifyDate\":\"2015-10-13T08:29:14.9413947Z\"}]}"
    
    override func setUp() {
        super.setUp()
        self.identity = phoenix?.identity as? IdentityModule
    }
    
    override func tearDown() {
        super.tearDown()
        self.identity =  nil
    }
    
    
    // MARK: - Mock

    func mockGetUser(userId: Int? = nil, status: HTTPStatusCode = .Success, body: String? = nil) {
        guard let userId = userId else {
            return
        }
        
        let guURL = NSURLRequest.phx_URLRequestForGetUser(userId, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL
        mockResponseForURL(guURL,
            method: .GET,
            response: getResponse(status, body: body ?? successfulResponseGetUser))
    }
    
    func mockGetUserMe(status: HTTPStatusCode = .Success, body: String? = nil) {
        let guURL = NSURLRequest.phx_URLRequestForUserMe(mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL
        mockResponseForURL(guURL,
            method: .GET,
            response: getResponse(status, body: body ?? successfulResponseGetUser))
    }
    
    func mockValidate(status: HTTPStatusCode = .Success, body: String? = nil) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForValidate(mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .GET,
            response: getResponse(status, body: body ?? validValidate))
    }
    
    func mockUserCreation(status: HTTPStatusCode = .Success, body: String? = nil, identifier: String? = nil) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserCreation(fakeUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .POST,
            response: getResponse(status, body: body ?? successfulResponseCreateUser), identifier: identifier)
    }
    
    func mockUserUpdateURL() -> NSURL {
        return NSURLRequest.phx_URLRequestForUserUpdate(fakeUpdateUser,
            oauth: mockOAuthProvider.loggedInUserOAuth,
            configuration: mockConfiguration,
            network: mockNetwork).URL!
    }
    
    func mockUserUpdate(status: HTTPStatusCode = .Success, body: String? = nil) {
        mockResponseForURL(mockUserUpdateURL(),
            method: .PUT,
            response: getResponse(status, body: body ?? successfulResponseCreateUser))
    }
    
    func mockUserUpdateResponses(status: HTTPStatusCode = .Unauthorized,
        secondStatus: HTTPStatusCode = .Success) -> [MockResponse] {
        let responses = [
            getResponse(status, body: successfulResponseCreateUser),
            getResponse(secondStatus, body: successfulResponseCreateUser)
        ]
        return responses
    }
    
    func mockUserAssignRole(status: HTTPStatusCode = .Success, body: String? = nil, identifier: String? = nil) {
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserRoleAssignment(fakeUpdateUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .POST,
            response: getResponse(status, body: body ?? successfulAssignRoleResponse), identifier: identifier)
    }
    
    func mockUserRevokeRole(roleId: Int, user: Phoenix.User, shouldFail: Bool = false, var body: String? = nil, identifier: String? = nil) {
        if body == nil {
            body = shouldFail ? failureRevokeRoleResponse : successfulRevokeRoleResponse
        }
        
        mockResponseForURL(NSURLRequest.phx_URLRequestForUserRoleRevoke(roleId, user: user, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).URL,
            method: .DELETE,
            response: getResponse(.Success, body: body!))
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
    
    func mockCreateIdentifierURL() -> NSURL {
        return NSURLRequest.phx_URLRequestForIdentifierCreation(fakeDeviceToken, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL!
    }
    
    func mockCreateIdentifier(status: HTTPStatusCode = .Success, body: String? = nil) {
        mockResponseForURL(mockCreateIdentifierURL(),
            method: .POST,
            response: getResponse(status, body: body ?? successfulResponseCreateIdentifier))
    }
    
    func mockDeleteIdentifierURL() -> NSURL {
        return NSURLRequest.phx_URLRequestForIdentifierDeletion(fakeTokenID, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).URL!
    }
    
    func mockDeleteIdentifier(status: HTTPStatusCode = .Success, body: String? = nil) {
        mockResponseForURL(mockDeleteIdentifierURL(),
            method: .DELETE,
            response: getResponse(status, body: body ?? successfulResponseDeleteIdentifier))
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
            XCTAssertNil(error, "Unexpected login error")
            
            expectation.fulfill()
        })
        
        waitForExpectations()
    }
    
    func testValidateSuccessParseError() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidate(.Success, body: badResponse)
        
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
            XCTAssertNil(error, "Unexpected login error")
            
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
            XCTAssert(error != nil, "Expected login error")
            
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
            XCTAssertNil(error, "Unexpected login error")
            
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
        
        phoenix?.identity.logout()
        
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
        assertLoggedOut(mockOAuthProvider.loggedInUserOAuth)
        
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        XCTAssert(mockOAuthProvider.developerLoggedIn == true)
        fakeLoggedOut(mockOAuthProvider.loggedInUserOAuth)
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
    }
    
    func testUserConstants() {
        let fake = fakeUser
        XCTAssert(fake.lockingCount == 0, "Locking count must be zero")
        XCTAssert(fake.isActive == true, "Active must be true")
        XCTAssert(fake.metadata == "", "Metadata must be empty")
        XCTAssert(fake.userTypeId == 6, "Type ID must be 6 (User)")
    }
    

    // MARK:- Get User
    
    func testGetUserSuccess() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        let userId = fakeUser.userId
        
        // Create
        mockGetUser(userId)
        
        identity!.getUser(userId) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
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
    
    func testAssignRoleFollowsCreateUserOnSuccess() {
        let oauth = mockOAuthProvider.applicationOAuth
        
        let expectCreateUser = expectationWithDescription("Was expecting the createUser callback to be notified")
        let expectAssignRole = expectationWithDescription("Was expecting the assignRole callback to be notified")
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        let createUserKey = "createUser"
        let assignRoleKey = "assignRole"
        
        
        var endpointsCalled : [String] = []
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        OHHTTPStubs.onStubActivation() { request, stub in
            guard let name = stub.name else {
                return
            }
            
            endpointsCalled.append(name)
            
            switch name {
                case createUserKey:
                    expectCreateUser.fulfill()
                case assignRoleKey:
                    expectAssignRole.fulfill()
                default: break
            }
        }
        
        // Create
        mockUserCreation(.Success, identifier: createUserKey)
        mockUserAssignRole(.Success, identifier: assignRoleKey)
        
        identity!.createUser(fakeUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            XCTAssertEqual(endpointsCalled, [createUserKey, assignRoleKey], "Endpoints were not called in the correct order")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testAssignRoleDoesNotFollowCreateUserOnFailure() {
        let oauth = mockOAuthProvider.applicationOAuth
        
        let expectCreateUser = expectationWithDescription("Was expecting the createUser callback to be notified")
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        let createUserKey = "createUser"
        let assignRoleKey = "assignRole"
        
        
        var endpointsCalled : [String] = []
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        OHHTTPStubs.onStubActivation() { request, stub in
            guard let name = stub.name else {
                return
            }
            
            endpointsCalled.append(name)
            
            switch name {
            case createUserKey:
                expectCreateUser.fulfill()
            default: break
            }
        }
        
        // Create
        mockUserCreation(.BadRequest, identifier: createUserKey)
        
        identity!.createUser(fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(!endpointsCalled.contains(assignRoleKey), "Assign Role should not be called")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserSuccessAssignRoleFailure() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        let sdkUser = Phoenix.User(companyId: 1)
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Create
        mockUserCreation(.Success)
        mockUserAssignRole(.BadRequest)
        
        identity!.createUser(sdkUser) { (user, error) -> Void in
            XCTAssert(user == nil, "User not found")
            XCTAssert(error != nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserSuccessAssignRoleParseFailure() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        let sdkUser = Phoenix.User(companyId: 1)
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Create
        mockUserCreation(.Success)
        mockUserAssignRole(.Success, body: badResponse)
        
        identity!.createUser(sdkUser) { (user, error) -> Void in
            XCTAssert(user == nil, "User not found")
            XCTAssert(error != nil, "Error occured while parsing a success request")
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
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
            XCTAssert(error?.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.BadRequest.rawValue, "Expected a BadRequest (400) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserParseFailure() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Mock
        mockUserCreation(.Success, body: badResponse)
        
        identity!.createUser(fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Unexpected error type raised")
            
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
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    // MARK:- Role
    
    func testRevokeRoleSuccess() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserRevokeRole(fakeRoleId, user: fakeUser)
        
        identity!.revokeRole(fakeRoleId, user: fakeUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testRevokeInvalidRoleFailure() {
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserRevokeRole(invalidRoleId, user: fakeUser, shouldFail: true)
        
        identity!.revokeRole(invalidRoleId, user: fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            
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
        
        XCTAssert(Phoenix.User.isUserIdValid(fakeUpdateUser.userId))
        
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
            XCTAssert(error?.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.BadRequest.rawValue, "Expected a BadRequest (400) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateUserParseFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserUpdate(.Success, body: badResponse)
        
        identity!.updateUser(fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == RequestError.ParseError.rawValue, "Unexpected error type raised")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateUserFailureRefreshTokenPassedUpdateUserSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockRefreshAndLogin(.Success, loginStatus: nil)
        mockResponseForURL(mockUserUpdateURL(), method: .PUT, responses: mockUserUpdateResponses())
        
        identity?.updateUser(fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testUpdateUserConditions() {
        XCTAssertFalse(Phoenix.User(userId: mockUserID, companyId: 0, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(userId: mockUserID,companyId: mockCompanyID, username: "", password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No username allows to create user")
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
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testCreateUserConditions() {
        XCTAssertFalse(Phoenix.User(companyId: 0, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No company allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: "", password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No username allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: nil, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: "", lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No firstname allows to create user")
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: "", avatarURL: mockAvatarURL).isValidToCreate, "No lastname allows to create user")
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "").isValidToCreate, "No Avatar blocks to create user")
        
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToCreate, "Can't send a complete user")
        
    }
    
    // MARK:- Create Identifier
    
    func testCreateIdentifierSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockCreateIdentifier()
        
        identity!.registerDeviceToken(fakeDeviceToken.dataUsingEncoding(NSUTF8StringEncoding)!) { (tokenId, error) -> Void in
            XCTAssert(error == nil)
            XCTAssert(tokenId == self.fakeTokenID)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierInvalidDeviceTokenError() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        assertURLNotCalled(mockCreateIdentifierURL())
        
        identity!.registerDeviceToken(NSData()) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == IdentityError.DeviceTokenInvalidError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockCreateIdentifier(.NotFound)
        
        identity!.registerDeviceToken(fakeDeviceToken.dataUsingEncoding(NSUTF8StringEncoding)!) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(tokenId == -1)
            XCTAssert(error?.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.NotFound.rawValue, "Expected a NotFound (404) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierParseFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockCreateIdentifier(.Success, body: unhandledJSONResponseCreateIdentifier)
        
        identity!.registerDeviceToken(fakeDeviceToken.dataUsingEncoding(NSUTF8StringEncoding)!) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(tokenId == -1)
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierParseFailureMalformed() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockCreateIdentifier(.Success, body: badResponse)
        
        identity!.registerDeviceToken(fakeDeviceToken.dataUsingEncoding(NSUTF8StringEncoding)!) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(tokenId == -1)
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    
    // MARK:- Delete Identifier
    
    func testDeleteIdentifierSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifier()
        
        identity!.unregisterDeviceToken(withId: fakeTokenID) { (error) -> Void in
            XCTAssert(error == nil)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testDeleteIdentifierFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifier(.BadRequest)
        
        identity!.unregisterDeviceToken(withId: fakeTokenID) { (error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == RequestError.UnhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.BadRequest.rawValue, "Expected a BadRequest (400) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testDeleteIdentifierZeroIDFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        assertURLNotCalled(mockDeleteIdentifierURL())
        
        identity!.unregisterDeviceToken(withId: 0) { (error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == IdentityError.DeviceTokenInvalidError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testDeleteIdentifierParseFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectationWithDescription("Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifier(.Success, body: badResponse)
        
        identity!.unregisterDeviceToken(withId: fakeTokenID) { (error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == RequestError.ParseError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    
    // MARK:- Password security
    
    func testPasswordRequirementsVerification() {
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "123456789", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only numbers passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "abcdefghf", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only letters passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "abc", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only letters below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "No password")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: nil, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "No password")
        
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only  numbers below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "test123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Numbers and letters below the size passes the check")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "testing123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with no uppercase, numbers and more than 8 characters passes the test")
        XCTAssertFalse(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "test1234", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with no uppercase, numbers and exactly 8 characters passes the test")
        
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with uppercase, numbers and more than 8 characters fails the test")
        XCTAssert(Phoenix.User(companyId: mockCompanyID, username: mockUsername, password: "Test1234", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with uppercase, numbers and exactly 8 characters fails the test")
    }
    
}
