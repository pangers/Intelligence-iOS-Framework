//
//  IntelligenceTests.swift
//  IntelligenceTests
//
//  Created by chethan.palaksha on 23/4/17.
//  Copyright © 2017 TigerSpike. All rights reserved.
//

import XCTest

@testable import IntelligenceSDK

let timeout = 20
let noOfDiffrentEvents = 20
class IntelligenceTests: XCTestCase, IntelligenceDelegate {

    override func setUp() {
        super.setUp()

       let testExpectation: XCTestExpectation = expectation(description: "Intilialize Intelligence")
        do {
            let intelligence = try Intelligence(withDelegate: self, file: "IntelligenceConfiguration")
//            intelligence.location.includeLocationInEvents = true

            // Startup all modules.
            intelligence.startup { (success) -> Void in

                OperationQueue.main.addOperation {
                    if success {
                        IntelligenceManager.startup(with: intelligence)
                        testExpectation.fulfill()
                    } else {
                        XCTFail("Failed to Initalize intelligence")
                    }
                }
            }
        } catch IntelligenceSDK.ConfigurationError.fileNotFoundError {
            XCTAssert(false, "The file you specified does not exist!")
        } catch IntelligenceSDK.ConfigurationError.invalidFileError {
            XCTAssert(false, "The file is invalid! Check that the JSON provided is correct.")
        } catch IntelligenceSDK.ConfigurationError.missingPropertyError {
            XCTAssert(false, "You missed a property!")
        } catch IntelligenceSDK.ConfigurationError.invalidPropertyError {
            XCTAssert(false, "There is an invalid property!")
        } catch {
            XCTAssert(false, "Treat the error with care!")
        }

        waitForExpectations(timeout: TimeInterval(timeout)) { (error) in
            if ((error) != nil) {
                let str = String(format: "Failed to Initalize intelligence - %@", error.debugDescription)
                XCTFail(str)
            }
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testStartIdentityModule() {

        let testClass = TestClass()

        //Start Module
        let testStartIdentityModule: XCTestExpectation = expectation(description: "Intilialize Intelligence")
        testClass.startupIdentitModule { (status) in
            if (status) {
                testStartIdentityModule.fulfill()
            } else {
                XCTFail("Failed to Start Identity Module")
            }
        }
        waitForExpectations(timeout: TimeInterval(timeout))

        //get Me
        var intelligenceUser: Intelligence.User? = nil
        let testGetme: XCTestExpectation = expectation(description: "GetMe")
        testClass.getMe { (user, error) in
            if (nil != error) {
                XCTFail("Failed to Start Identity Module")
            } else {
                intelligenceUser = user
                testGetme.fulfill()
            }
        }
        waitForExpectations(timeout: TimeInterval(timeout))

        //logout
        let logout: XCTestExpectation = self.expectation(description: "logout Intelligence")
        testClass.logout(complition: { (error) in
            if (error != nil) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                logout.fulfill()
            }
        })
        self.waitForExpectations(timeout: TimeInterval(timeout))

       //login
        let userName = intelligenceUser?.username
        let password = UserDefaults.standard.string(forKey: "Test_Password")

        let logIn: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.loginUser(with: userName!, password: password!) { (user, error) in
            if (nil != error) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                intelligenceUser = user
                logIn.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //update user
        intelligenceUser?.firstName = "Test-FirstName"
        intelligenceUser?.lastName = "Test-lastName"

        let updateUser: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.updateUser(user: intelligenceUser!) { (user, error) in
            if (nil != error) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                intelligenceUser = user
                updateUser.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //Assign Role
        let assignRole: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.assisgn(role: 1063, user: intelligenceUser!) { (user, error) in
            if (nil != error) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                intelligenceUser = user
                assignRole.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //Revoke Role
        let revokeRole: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.revoke(role: 1063, user: intelligenceUser!) { (user, error) in
            if (nil != error) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                intelligenceUser = user
                revokeRole.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //Re-assign role
        let reAssignRole: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.assisgn(role: 1063, user: intelligenceUser!) { (user, error) in
            if (nil != error) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                intelligenceUser = user
                reAssignRole.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //get User
        let getUser: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.getUser(userId: (intelligenceUser?.userId)!) { (user, error) in
            if (nil != error) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                intelligenceUser = user
                getUser.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //logout
        let logoutUser: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.logout { (error) in

            if (error != nil) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                logoutUser.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //Shutdown
        let shutdownModule: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.shutDownIdentitModule { (error) in
            if (error != nil) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                shutdownModule.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        //GetUser
        let againGetUser: XCTestExpectation = self.expectation(description: "login Intelligence")
        testClass.getUser(userId: (intelligenceUser?.userId)!) { (user, error) in
            if (error != nil) {
                XCTFail("Failed to logout from Identity Module")
            } else {
                againGetUser.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))
    }

//    func testDeviceRegister()  {
//        
//        let testClass = TestClass()
//        
//        var tokenId = 1234
//
//        if let data = "1A31D9A4-07F8-4DD1-9505-B162F709FA4C".data(using: .utf8){
//            //Register device
//            let register:XCTestExpectation = self.expectation(description: "login Intelligence")
//            testClass.registerDevice(token:data, complition: { (token, error) in
//                if (nil != error){
//                    XCTFail("Failed to register device")
//                }
//                else{
//                    tokenId = token
//                    register.fulfill()
//                }
//            })
//            self.waitForExpectations(timeout: TimeInterval(timeout))
//        }
//        
//        //Unregister device
//        let unregister:XCTestExpectation = self.expectation(description: "login Intelligence")
//        testClass.unRegisterDevice(tokenID: tokenId) { (error) in
//            if (nil != error){
//                XCTFail("Failed to unregister device")
//            }
//            else{
//                unregister.fulfill()
//            }
//        }
//        self.waitForExpectations(timeout: TimeInterval(timeout))
//    }

    func testPostEvents() {

        let testClass = TestClass()

        //Startup Analytics Module
        let startupModule: XCTestExpectation = self.expectation(description: "Start up Analytics Module")
        testClass.startupAnalyticsModule { (status) in
            if (status) {
                startupModule.fulfill()
            } else {
                XCTFail("Failed to startup analytics module")
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        testClass.sendSampleEvents(eventCount: noOfDiffrentEvents)

        //Pause Module
        let pauseModule: XCTestExpectation = self.expectation(description: "Start up Analytics Module")
        testClass.pauseAnalyticsModule { (error) in
            if (nil != error) {
                XCTFail("Failed to pause analytics module")
            } else {
                pauseModule.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        testClass.sendSampleEvents(eventCount: noOfDiffrentEvents)

        //Resume
        let resumeModule: XCTestExpectation = self.expectation(description: "Start up Analytics Module")
        testClass.resumeAnalyticsModule { (error) in
            if (nil != error) {
                XCTFail("Failed to resume analytics module")
            } else {
                resumeModule.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))

        testClass.sendSampleEvents(eventCount: noOfDiffrentEvents)

        let shutdownModule: XCTestExpectation = self.expectation(description: "Start up Analytics Module")

        testClass.shutDownAnalyticsModule { (error) in
            if (nil != error) {
                XCTFail("Failed to shutdown analytics module")
            } else {
                shutdownModule.fulfill()
            }
        }
        self.waitForExpectations(timeout: TimeInterval(timeout))
        testClass.sendSampleEvents(eventCount: noOfDiffrentEvents)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    /// Credentials provided are incorrect.
    /// Will not distinguish between incorrect client or user credentials.
    public func credentialsIncorrect(for intelligence: IntelligenceSDK.Intelligence) {

    }

    /// Account has been disabled and no longer active.
    /// Credentials are no longer valid.
    public func accountDisabled(for intelligence: IntelligenceSDK.Intelligence) {

    }

    /// Account has failed to authentication multiple times and is now locked.
    /// Requires an administrator to unlock the account.
    public func accountLocked(for intelligence: IntelligenceSDK.Intelligence) {

    }

    /// This error and description is only returned from the Validate endpoint
    /// if providing an invalid or expired token.
    public func tokenInvalidOrExpired(for intelligence: IntelligenceSDK.Intelligence) {

    }

    /// Unable to create SDK user, this may occur if a user with the randomized
    /// credentials already exists (highly unlikely) or your Application is
    /// configured incorrectly and has the wrong permissions.
    public func userCreationFailed(for intelligence: IntelligenceSDK.Intelligence) {

    }

    /// User is required to login again, developer must implement this method
    /// you may present a 'Login Screen' or silently call identity.login with
    /// stored credentials.
    public func userLoginRequired(for intelligence: IntelligenceSDK.Intelligence) {

    }

    /// Unable to assign provided sdk_user_role to your newly created user.
    /// This may occur if the Application is configured incorrectly in the backend
    /// and doesn't have the correct permissions or the role doesn't exist.
    public func userRoleAssignmentFailed(for intelligence: IntelligenceSDK.Intelligence) {

    }

}
