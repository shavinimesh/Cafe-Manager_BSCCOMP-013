//
//  Cafe_ManagerTests.swift
//  Cafe ManagerTests
//
//  Created by Nimesh Lakshan on 2021-04-27.
//

import XCTest
@testable import Cafe_Manager

class Cafe_ManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testLoginValidations() throws {
        //Testing a valid email
        XCTAssertTrue(InputFieldValidator.isValidEmail("nimeshlakshan923@gmail.com"))
        
        //Testing an invalid email
        XCTAssertFalse(InputFieldValidator.isValidEmail("nimesh@_gmail.com"))
        
        //Testing an invalid email
        XCTAssertFalse(InputFieldValidator.isValidEmail("nimesh@_gmail.@13"))
        
        //Testing a valid password
        XCTAssertTrue(InputFieldValidator.isValidPassword(pass: "Kzqq1430", minLength: 6, maxLength: 20))
        
        //Testing n invalid password
        XCTAssertFalse(InputFieldValidator.isValidPassword(pass: "1234", minLength: 6, maxLength: 20))
        
        //Testing an invalid password
        XCTAssertFalse(InputFieldValidator.isValidPassword(pass: "Kzqq1430@1234Kzqq123421234Kzqq1430", minLength: 6, maxLength: 20))
    }
    
    func testSignUpValidations() throws {
        //Testing a valid name
        XCTAssertTrue(InputFieldValidator.isValidName("nimesh"))
        
        //Testing an invalid name
        XCTAssertFalse(InputFieldValidator.isValidName("Nimesh1234"))
        
        //Testing an invalid name
        XCTAssertFalse(InputFieldValidator.isValidName(""))
        
        //Testing a valid email
        XCTAssertTrue(InputFieldValidator.isValidEmail("nimeshlakshan923@gmail.com"))
        
        //Testing an invalid email
        XCTAssertFalse(InputFieldValidator.isValidEmail("nimesh@_gmail.com"))
        
        //Testing a valid mobileNo
        XCTAssertTrue(InputFieldValidator.isValidMobileNo("0777721525"))
        
        //Testing an invalid mobileNo
        XCTAssertFalse(InputFieldValidator.isValidMobileNo("0112345678"))
        
        //Testing an invalid mobileNo
        XCTAssertFalse(InputFieldValidator.isValidMobileNo("077721525"))
        
        //Testing an invalid mobileNo
        XCTAssertFalse(InputFieldValidator.isValidMobileNo("07777a1525"))
        
        //Testing a valid password
        XCTAssertTrue(InputFieldValidator.isValidPassword(pass: "Kzqq1430", minLength: 6, maxLength: 20))
        
        //Testing n invalid password
        XCTAssertFalse(InputFieldValidator.isValidPassword(pass: "1234", minLength: 6, maxLength: 20))
    }

}

class CafeManagerRegisterTests : XCTestCase, FirebaseActions {
    private var result: XCTestExpectation!
    let firebaseOP = FirebaseOP.instance
    var userRegistered = false
    
    func testRegistration() {
        firebaseOP.delegate = self
        result = expectation(description: "Successful signup!")
        let user = User(_id: "",
                        userName: "Nimesh lankashan",
                        email: "nimeshlakshan123@gmail.com",
                        phoneNo: "0712266686",
                        password: "admin@123", imageRes: "")
        firebaseOP.registerUser(user: user)
        waitForExpectations(timeout: 15)
        XCTAssertEqual(self.userRegistered, true)
    }
    
    func isExisitingUser(error: String) {
        userRegistered = false
        result.fulfill()
    }
    
    func isSignUpSuccessful(user: User?) {
        userRegistered = true
        result.fulfill()
    }
    
    func isSignUpFailedWithError(error: String) {
        userRegistered = false
        result.fulfill()
    }
    
    func onConnectionLost() {
        
    }
}
