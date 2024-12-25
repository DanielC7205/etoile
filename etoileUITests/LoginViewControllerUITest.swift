//
//  LoginViewControllerUITest.swift
//  etoileUITests
//
//  Created by Juliette Bernheisel on 8/22/24.
//

import XCTest
import SimpleKeychain

final class LoginViewControllerUITest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testValidDataFillOut() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset") // Resets the simple keychain, allowing for sign in
        app.launch()

        let instanceUrlField = app.textFields["Instance URL"]
        let instanceUrl = "https://testfin.juliette.page\n"
        instanceUrlField.tap()
        instanceUrlField.typeText(instanceUrl)
        
        let usernameField = app.textFields["Username"]
        let username = "testinguser\n"
        usernameField.tap()
        usernameField.typeText(username)
        
        let passwordField = app.secureTextFields["Password"]
        let password = "verysecurepassword\n"
        passwordField.tap()
        passwordField.typeText(password)
        
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        let alert = app.alerts.buttons["OK"]
        if alert.waitForExistence(timeout: 10) {
            XCTFail("Error signing in")
        } else {
            XCTAssert(true)
        }
    }
    
    func testInvalidDataFillOut() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset") // Resets the simple keychain, allowing for sign in
        app.launch()

        let instanceUrlField = app.textFields["Instance URL"]
        let instanceUrl = "asdfkkasdkf\n"
        instanceUrlField.tap()
        instanceUrlField.typeText(instanceUrl)
        
        let usernameField = app.textFields["Username"]
        let username = "\n"
        usernameField.tap()
        usernameField.typeText(username)
        
        let passwordField = app.secureTextFields["Password"]
        let password = "adfasdf\n"
        passwordField.tap()
        passwordField.typeText(password)
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        let alert = app.alerts.buttons["OK"]
        if alert.waitForExistence(timeout: 10) {
            XCTAssert(true)
        } else {
            XCTFail("Error signing in incorrectly")
        }


    }
}
