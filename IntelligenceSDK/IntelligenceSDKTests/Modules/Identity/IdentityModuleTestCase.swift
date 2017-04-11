//
//  IdentityModuleTestCase.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import IntelligenceSDK

class IdentityModuleTestCase: IntelligenceBaseTestCase {

    let fakeUpdateUser = Intelligence.User(userId: mockUserID, companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    let updateUserWeakPassword = Intelligence.User(userId: mockUserID, companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
    let userWeakPassword = Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
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
    let successfulResponseDeleteIdentifierOnBehalf = "{\"TotalRecords\":1,\"Data\":[{\"Id\":18952,\"IdentifierTypeId\":\"iOS_Device_Token\",\"IsConfirmed\":false,\"Value\":\"d3e3a7db07691f8f698e5139310cce50f5e2d2e36020e2f70187bf23b175ec01\",\"CreateDate\":\"2015-10-13T08:29:14.9413947Z\",\"ModifyDate\":\"2015-10-13T08:29:14.9413947Z\"}]}"
    
    override func setUp() {
        super.setUp()
        self.identity = intelligence?.identity as? IdentityModule
    }
    
    override func tearDown() {
        super.tearDown()
        self.identity =  nil
    }
    
    
    // MARK: - Mock

    func mockGetUserResponse(_ userId: Int? = nil, status: HTTPStatusCode = .success, body: String? = nil) {
        guard let userId = userId else {
            return
        }
        
        let guURL = URLRequest.int_URLRequestForGetUser(userId: userId, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url
        mockResponseForURL(guURL,
            method: .get,
            response: getResponse(status, body: body ?? successfulResponseGetUser))
    }
    
    func mockGetUserMeResponse(_ status: HTTPStatusCode = .success, body: String? = nil) {
        let guURL = URLRequest.int_URLRequestForUserMe(oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url
        mockResponseForURL(guURL,
            method: .get,
            response: getResponse(status, body: body ?? successfulResponseGetUser))
    }
    
    func mockValidateResponse(_ status: HTTPStatusCode = .success, body: String? = nil) {
        mockResponseForURL(URLRequest.int_URLRequestForValidate(oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url,
            method: .get,
            response: getResponse(status, body: body ?? validValidate))
    }
    
    func mockUserCreationResponse(_ status: HTTPStatusCode = .success, body: String? = nil, identifier: String? = nil) {
        mockResponseForURL(URLRequest.int_URLRequestForUserCreation(user: fakeUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).url,
            method: .post,
            response: getResponse(status, body: body ?? successfulResponseCreateUser), identifier: identifier)
    }
    
    func mockUserUpdateURL() -> URL {
        return URLRequest.int_URLRequestForUserUpdate(user: fakeUpdateUser,
            oauth: mockOAuthProvider.loggedInUserOAuth,
            configuration: mockConfiguration,
            network: mockNetwork).url!
    }
    
    func mockUserUpdateResponse(_ status: HTTPStatusCode = .success, body: String? = nil) {
        mockResponseForURL(mockUserUpdateURL(),
            method: .put,
            response: getResponse(status, body: body ?? successfulResponseCreateUser))
    }
    
    func mockUserUpdateResponses(_ status: HTTPStatusCode = .unauthorized,
        secondStatus: HTTPStatusCode = .success) -> [MockResponse] {
        let responses = [
            getResponse(status, body: successfulResponseCreateUser),
            getResponse(secondStatus, body: successfulResponseCreateUser)
        ]
        return responses
    }
    
    func mockUserAssignRoleResponse(_ status: HTTPStatusCode = .success, body: String? = nil, identifier: String? = nil) {
        mockResponseForURL(URLRequest.int_URLRequestForUserRoleAssignment(roleId: mockConfiguration.sdkUserRole, user: fakeUpdateUser, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).url,
            method: .post,
            response: getResponse(status, body: body ?? successfulAssignRoleResponse), identifier: identifier)
    }
    
    func mockUserRevokeRoleResponse(_ roleId: Int, user: Intelligence.User, shouldFail: Bool = false, body: String? = nil, identifier: String? = nil) {
        var body = body
        if body == nil {
            body = shouldFail ? failureRevokeRoleResponse : successfulRevokeRoleResponse
        }
        
        mockResponseForURL(URLRequest.int_URLRequestForUserRoleRevoke(roleId: roleId, user: user, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).url,
            method: .delete,
            response: getResponse(.success, body: body!))
    }
    
    func mockRefreshAndLoginResponse(_ status: HTTPStatusCode? = nil,
        loginStatus: HTTPStatusCode? = nil,
        alternateRefreshResponse: String? = nil,
        alternateLoginResponse: String? = nil)
    {
        var responses = [MockResponse]()
        let refreshResponse = alternateRefreshResponse ?? validRefresh
        let loginResponse = alternateLoginResponse ?? validLogin
        
        if status != nil {
            responses.append(MockResponse(status == .success ? refreshResponse : nil, status!, nil))
        }
        if status != .success || status == nil && loginStatus != nil {
            responses.append(MockResponse(loginStatus == .success ? loginResponse : nil, loginStatus!, nil))
        }
        mockAuthenticationResponses(responses)
    }
    
    func hexStringFromDeviceToken(_ deviceToken: String) -> String? {
        let data = deviceToken.data(using: String.Encoding.utf8)
        return data?.hexString()
    }
    
    func mockCreateIdentifierURL() -> URL {
        return (URLRequest.int_URLRequestForIdentifierCreation(tokenString: hexStringFromDeviceToken(fakeDeviceToken)!, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url! as NSURL) as URL
    }
    
    func mockCreateIdentifierResponse(_ status: HTTPStatusCode = .success, body: String? = nil) {
        mockResponseForURL(mockCreateIdentifierURL(),
            method: .post,
            response: getResponse(status, body: body ?? successfulResponseCreateIdentifier))
    }
    
    func mockDeleteIdentifierURL() -> URL {
        return URLRequest.int_URLRequestForIdentifierDeletion(tokenId: fakeTokenID, oauth: mockOAuthProvider.loggedInUserOAuth, configuration: mockConfiguration, network: mockNetwork).url!
    }
    
    func mockDeleteIdentifierResponse(_ status: HTTPStatusCode = .success, body: String? = nil) {
        mockResponseForURL(mockDeleteIdentifierURL(),
            method: .delete,
            response: getResponse(status, body: body ?? successfulResponseDeleteIdentifier))
    }
    
    func mockDeleteIdentifierOnBehalfResponse(_ status: HTTPStatusCode = .success, body: String? = nil) {
        mockResponseForURL(URLRequest.int_URLRequestForIdentifierDeletionOnBehalf(token: hexStringFromDeviceToken(fakeDeviceToken)!, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).url,
            method: .delete,
            response: getResponse(status, body: body ?? successfulResponseDeleteIdentifierOnBehalf))
    }
    
    // MARK:- Login/Logout
    
    func fakeLoggedIn(_ oauth: IntelligenceOAuthProtocol) {
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
    }
    
    func fakeLoggedOut(_ oauth: IntelligenceOAuthProtocol) {
        mockOAuthProvider.reset(oauth)
    }
    
    func assertLoggedOut(_ oauth: IntelligenceOAuthProtocol) {
        XCTAssert(oauth.userId == nil)
        XCTAssert(oauth.refreshToken == nil)
        XCTAssert(oauth.accessToken == nil)
        XCTAssert(oauth.password == nil)
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
    }
    
    func testValidateSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidateResponse()
        mockGetUserMeResponse()
        
        let testExpectation = expectation(description: "mock validate")
        
        intelligence?.identity?.login(with: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error, "Unexpected login error")
            
            testExpectation.fulfill()
        })
        
        waitForExpectations()
    }
    
    func testValidateSuccessParseError() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidateResponse(.success, body: badResponse)
        
        let expectation1 = expectation(description: "mock validate")
        
        intelligence?.identity?.login(with: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            
            expectation1.fulfill()
        })
        
        waitForExpectations()
    }
    
    func testValidateFailureRefreshSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidateResponse(.unauthorized)
        mockRefreshAndLoginResponse(.success, loginStatus: nil)
        mockGetUserMeResponse()
        
        let testExpectation = expectation(description: "mock refresh")
        
        intelligence?.identity?.login(with: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error, "Unexpected login error")
            
            testExpectation.fulfill()
        })
        waitForExpectations()
    }
    
    func testValidateFailureRefreshSuccessParseError() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidateResponse(.unauthorized)
        mockRefreshAndLoginResponse(.success, loginStatus: nil, alternateRefreshResponse: badResponse)
        
        let expectation1 = expectation(description: "mock refresh")
        
        intelligence?.identity?.login(with: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            
            expectation1.fulfill()
        })
        
        waitForExpectations()
    }
    
    func testValidateRefreshLoginFailure() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidateResponse(.unauthorized)
        mockRefreshAndLoginResponse(.unauthorized, loginStatus: .badRequest)
        
        let expectation1 = expectation(description: "mock refresh")
        
        intelligence?.identity?.login(with: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssert(error != nil, "Expected login error")
            
            expectation1.fulfill()
        })
        
        waitForExpectations()
    }
    
    func testValidateRefreshFailureLoginSuccess() {
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        mockValidateResponse(.unauthorized)
        mockRefreshAndLoginResponse(.unauthorized, loginStatus: .success)
        mockGetUserMeResponse()
        
        let testExpectation = expectation(description: "mock refresh")
        
        intelligence?.identity?.login(with: fakeUser.username, password: fakeUser.password!, callback: { (user, error) -> Void in
            XCTAssertNil(error, "Unexpected login error")
            
            testExpectation.fulfill()
        })
        
        waitForExpectations()
    }
    
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginLogoutSuccess() {
        XCTAssert(self.mockOAuthProvider.developerLoggedIn == false, "Should be logged out")
        
        mockOAuthProvider.loggedInUserOAuth.username = fakeUser.username
        mockOAuthProvider.loggedInUserOAuth.password = fakeUser.password
        
        mockRefreshAndLoginResponse(nil, loginStatus: .success)
        mockGetUserMeResponse()
        
        let expectation = self.expectation(description: "mock logout")
        
        intelligence?.identity.login(with: fakeUser.username, password: fakeUser.password!) { (user, error) -> () in
            // Ensure we're logged in...
            XCTAssert(user != nil && error == nil, "Method should return authenticated = true")
            XCTAssert(self.mockOAuthProvider.loggedInUserOAuth.password == nil, "Password should be cleared")
            XCTAssert(user?.userId == mockUserID, "User ID should be available")
            XCTAssert(self.mockOAuthProvider.loggedInUserOAuth.userId != nil, "User ID should be stored")
            XCTAssert(self.mockOAuthProvider.developerLoggedIn == true, "Logged in flag should be set")
            
            // Logout...
            self.intelligence?.identity.logout()
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
        XCTAssert(!self.mockOAuthProvider.developerLoggedIn, "Intelligence is authenticated before a response")
        
        // Create expectation for login...
        mockRefreshAndLoginResponse(nil, loginStatus: .success)
        mockGetUserMeResponse(.badRequest)
        
        let testExpectation = expectation(description: "Expectation")
        intelligence?.identity.login(with: "username", password: "password") { (user, error) -> () in
            XCTAssert(user == nil && error != nil, "Method should return authenticated = false")
            XCTAssert(self.mockOAuthProvider.developerLoggedIn == false)
            
            testExpectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginFailure() {
        XCTAssert(!self.mockOAuthProvider.developerLoggedIn, "Intelligence is authenticated before a response")
        
        // Create expectation for login...
        mockRefreshAndLoginResponse(nil, loginStatus: .badRequest)
        
        let testExpectation = expectation(description: "Expectation")
        intelligence?.identity.login(with: "username", password: "password") { (user, error) -> () in
            XCTAssert(user == nil && error != nil, "Method should return authenticated = false")
            XCTAssertFalse(self.mockOAuthProvider.developerLoggedIn)
            self.assertLoggedOut(self.mockOAuthProvider.loggedInUserOAuth)
            
            testExpectation.fulfill()
        }
        waitForExpectations()
    }
    
    
    /// Verify if a user logs out, then logs in anonymously (triggered by a request being added to the queue)
    /// that the userId does gets set and unset correctly.
    func testLoginSuccessParseError() {
        XCTAssert(!self.mockOAuthProvider.developerLoggedIn, "Intelligence is authenticated before a response")
        
        // Create expectation for login...
        mockRefreshAndLoginResponse(nil, loginStatus: .success, alternateLoginResponse: badResponse)
        
        let expectation = self.expectation(description: "Expectation")
        
        intelligence?.identity.login(with: "username", password: "password") { (user, error) -> () in
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    /// Verify that we logout clearing our tokens successfully when anonymously logged in.
    func testLogout() {
        XCTAssert(mockOAuthProvider.developerLoggedIn == false)
        
        // Fake login
        fakeLoggedIn(mockOAuthProvider.loggedInUserOAuth)
        
        intelligence?.identity.logout()
        
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
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        let userId = fakeUser.userId
        
        // Create
        mockGetUserResponse(userId)
        
        identity!.getUser(with: userId) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    
    // MARK:- Create User
    
    // Assures that when the user is not valid to create, an error is returned.
    func testCreateUserErrorOnUserCondition() {
        let user = Intelligence.User(companyId: mockCompanyID, username: "", password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL)
        let URL = URLRequest.int_URLRequestForUserCreation(user: user, oauth: mockOAuthProvider.applicationOAuth, configuration: mockConfiguration, network: mockNetwork).url!
        
        assertURLNotCalled(URL)
        
        let expectation = self.expectation(description: "mock create user")
        
        identity!.createUser(user: user) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.invalidUserError.rawValue, "Unexpected error type raised")
            
            expectation.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserSuccess() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Create
        mockUserCreationResponse(.success)
        mockUserAssignRoleResponse(.success)
        
        identity!.createUser(user: fakeUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testAssignRoleFollowsCreateUserOnSuccess() {
        let oauth = mockOAuthProvider.applicationOAuth
        
        let expectCreateUser = expectation(description: "Was expecting the createUser callback to be notified")
        let expectAssignRole = expectation(description: "Was expecting the assignRole callback to be notified")
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        let createUserKey = "createUser"
        let assignRoleKey = "assignRole"
        
        
        var endpointsCalled : [String] = []
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        OHHTTPStubs.onStubActivation { (request, stub, stubResponse) in
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
        mockUserCreationResponse(.success, identifier: createUserKey)
        mockUserAssignRoleResponse(.success, identifier: assignRoleKey)
        
        identity!.createUser(user: fakeUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            XCTAssertEqual(endpointsCalled, [createUserKey, assignRoleKey], "Endpoints were not called in the correct order")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testAssignRoleDoesNotFollowCreateUserOnFailure() {
        let oauth = mockOAuthProvider.applicationOAuth
        
        let expectCreateUser = expectation(description: "Was expecting the createUser callback to be notified")
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        let createUserKey = "createUser"
        let assignRoleKey = "assignRole"
        
        
        var endpointsCalled : [String] = []
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        OHHTTPStubs.onStubActivation { (request, stub, stubResponse) in
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
        mockUserCreationResponse(.badRequest, identifier: createUserKey)
        
        identity!.createUser(user: fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(!endpointsCalled.contains(assignRoleKey), "Assign Role should not be called")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserSuccessAssignRoleFailure() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        let sdkUser = Intelligence.User(companyId: 1)
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Create
        mockUserCreationResponse(.success)
        mockUserAssignRoleResponse(.badRequest)
        
        identity!.createUser(user: sdkUser) { (user, error) -> Void in
            XCTAssert(user == nil, "User not found")
            XCTAssert(error != nil, "Error occured while parsing a success request")
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserSuccessAssignRoleParseFailure() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        let sdkUser = Intelligence.User(companyId: 1)
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Create
        mockUserCreationResponse(.success)
        mockUserAssignRoleResponse(.success, body: badResponse)
        
        identity!.createUser(user: sdkUser) { (user, error) -> Void in
            XCTAssert(user == nil, "User not found")
            XCTAssert(error != nil, "Error occured while parsing a success request")
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserFailure() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Mock
        mockUserCreationResponse(.badRequest)
        
        identity!.createUser(user: fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.badRequest.rawValue, "Expected a BadRequest (400) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserParseFailure() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeAccessToken(oauth)
        
        // Mock
        mockUserCreationResponse(.success, body: badResponse)
        
        identity!.createUser(user: fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == RequestError.parseError.rawValue, "Unexpected error type raised")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateUserFailureDueToPasswordSecurity() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        let URL = URLRequest.int_URLRequestForUserCreation(user: fakeUser, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url!
        
        // Assert that the call won't be done.
        assertURLNotCalled(URL)
        
        identity!.createUser(user: userWeakPassword) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.weakPasswordError.rawValue, "Unexpected error type raised")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    // MARK:- Role
    
    func testRevokeRoleSuccess() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserRevokeRoleResponse(fakeRoleId, user: fakeUser)
        
        identity!.revokeRole(with: fakeRoleId, user: fakeUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testRevokeInvalidRoleFailure() {
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        let oauth = mockOAuthProvider.applicationOAuth
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserRevokeRoleResponse(invalidRoleId, user: fakeUser, shouldFail: true)
        
        identity!.revokeRole(with: invalidRoleId, user: fakeUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }

    // MARK:- Update User
    
    func testUpdateUserSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserUpdateResponse()
        
        XCTAssert(Intelligence.User.isUserIdValid(userId: fakeUpdateUser.userId))
        
        identity!.update(user:fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateUserFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserUpdateResponse(.badRequest)
        
        identity!.update(user:fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.badRequest.rawValue, "Expected a BadRequest (400) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateUserParseFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        // Mock
        mockUserUpdateResponse(.success, body: badResponse)
        
        identity!.update(user:fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == RequestError.parseError.rawValue, "Unexpected error type raised")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testUpdateUserFailureRefreshTokenPassedUpdateUserSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockRefreshAndLoginResponse(.success, loginStatus: nil)
        mockResponseForURL(mockUserUpdateURL(), method: .put, responses: mockUserUpdateResponses())
        
        identity?.update(user:fakeUpdateUser) { (user, error) -> Void in
            XCTAssert(user != nil, "User not found")
            XCTAssert(error == nil, "Error occured while parsing a success request")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testUpdateUserConditions() {
        XCTAssertFalse(Intelligence.User(userId: mockUserID, companyId: 0, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No company allows to create user")
        XCTAssertFalse(Intelligence.User(userId: mockUserID,companyId: mockCompanyID, username: "", password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No username allows to create user")
        XCTAssertFalse(Intelligence.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: "", lastName: mockLastName, avatarURL: mockAvatarURL).isValidToUpdate, "No firstname allows to create user")
        XCTAssertFalse(Intelligence.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: "", avatarURL: mockAvatarURL).isValidToUpdate, "No lastname allows to create user")
        XCTAssertFalse(Intelligence.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "").isValidToUpdate, "No Avatar blocks to create user")
        XCTAssert(Intelligence.User(userId: mockUserID,companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToUpdate, "Can't send a complete user")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToUpdate, "No user id")
    }
    
    func testUpdateUserFailureDueToPasswordSecurity() {
        let oauth = mockOAuthProvider.applicationOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        let URL = URLRequest.int_URLRequestForUserUpdate(user: updateUserWeakPassword, oauth: oauth, configuration: mockConfiguration, network: mockNetwork).url!
        
        // Assert that the call won't be done.
        assertURLNotCalled(URL, method: .put)
        
        identity!.update(user:updateUserWeakPassword) { (user, error) -> Void in
            XCTAssert(user == nil, "Didn't expect to get a user from a failed response")
            XCTAssert(error != nil, "No error raised")
            XCTAssert(error?.code == IdentityError.weakPasswordError.rawValue, "Unexpected error type raised")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    // Test the method that is used to see if the user is valid to be created
    func testCreateUserConditions() {
        XCTAssertFalse(Intelligence.User(companyId: 0, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No company allows to create user")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: "", password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No username allows to create user")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: nil, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No password allows to create user")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: "", lastName: mockLastName, avatarURL: mockAvatarURL).isValidToCreate, "No firstname allows to create user")
        XCTAssert(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: "", avatarURL: mockAvatarURL).isValidToCreate, "No lastname allows to create user")
        XCTAssert(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "").isValidToCreate, "No Avatar blocks to create user")
        
        XCTAssert(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: "1").isValidToCreate, "Can't send a complete user")
        
    }
    
    // MARK:- Create Identifier
    
    func testCreateIdentifierSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierOnBehalfResponse()
        mockCreateIdentifierResponse()
        
        identity!.registerDeviceToken(with: fakeDeviceToken.data(using: String.Encoding.utf8)!) { (tokenId, error) -> Void in
            XCTAssert(error == nil)
            XCTAssert(tokenId == self.fakeTokenID)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierInvalidDeviceTokenError() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        assertURLNotCalled(mockCreateIdentifierURL())
        
        identity!.registerDeviceToken(with: Data()) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == IdentityError.deviceTokenInvalidError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierOnBehalfResponse()
        mockCreateIdentifierResponse(.notFound)
        
        identity!.registerDeviceToken(with: fakeDeviceToken.data(using: String.Encoding.utf8)!) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(tokenId == -1)
            XCTAssert(error?.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.notFound.rawValue, "Expected a NotFound (404) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierParseFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierOnBehalfResponse()
        mockCreateIdentifierResponse(.success, body: unhandledJSONResponseCreateIdentifier)
        
        identity!.registerDeviceToken(with: fakeDeviceToken.data(using: String.Encoding.utf8)!) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(tokenId == -1)
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testCreateIdentifierParseFailureMalformed() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierOnBehalfResponse()
        mockCreateIdentifierResponse(.success, body: badResponse)
        
        identity!.registerDeviceToken(with: fakeDeviceToken.data(using: String.Encoding.utf8)!) { (tokenId, error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(tokenId == -1)
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    
    // MARK:- Delete Identifier
    
    func testDeleteIdentifierSuccess() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierResponse()
        
        identity!.unregisterDeviceToken(with: fakeTokenID) { (error) -> Void in
            XCTAssert(error == nil)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testDeleteIdentifierFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierResponse(.badRequest)
        
        identity!.unregisterDeviceToken(with: fakeTokenID) { (error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == RequestError.unhandledError.rawValue, "Expected an unhandleable error")
            XCTAssert(error?.httpStatusCode() == HTTPStatusCode.badRequest.rawValue, "Expected a BadRequest (400) error")
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testDeleteIdentifierZeroIDFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        assertURLNotCalled(mockDeleteIdentifierURL())
        
        identity!.unregisterDeviceToken(with: 0) { (error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == IdentityError.deviceTokenInvalidError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    func testDeleteIdentifierParseFailure() {
        let oauth = mockOAuthProvider.loggedInUserOAuth
        let expectCallback = expectation(description: "Was expecting a callback to be notified")
        
        // Mock auth
        mockOAuthProvider.fakeLoggedIn(oauth, fakeUser: fakeUser)
        
        mockDeleteIdentifierResponse(.success, body: badResponse)
        
        identity!.unregisterDeviceToken(with: fakeTokenID) { (error) -> Void in
            XCTAssert(error != nil)
            XCTAssert(error?.code == RequestError.parseError.rawValue)
            
            expectCallback.fulfill()
        }
        
        waitForExpectations()
    }
    
    
    // MARK:- Password security
    
    func testPasswordRequirementsVerification() {
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "123456789", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only numbers passes the check")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "abcdefghf", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only letters passes the check")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "abc", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only letters below the size passes the check")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "No password")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: nil, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "No password")
        
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Only  numbers below the size passes the check")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "test123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Numbers and letters below the size passes the check")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "testing123", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with no uppercase, numbers and more than 8 characters passes the test")
        XCTAssertFalse(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "test1234", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with no uppercase, numbers and exactly 8 characters passes the test")
        
        XCTAssert(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: mockPassword, firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with uppercase, numbers and more than 8 characters fails the test")
        XCTAssert(Intelligence.User(companyId: mockCompanyID, username: mockUsername, password: "Test1234", firstName: mockFirstName, lastName: mockLastName, avatarURL: mockAvatarURL).isPasswordSecure(), "Letters with uppercase, numbers and exactly 8 characters fails the test")
    }
    
}
