//
//  LoginViewControllerUITest.swift
//  etoileUITests
//
//  Created by Juliette Bernheisel on 8/22/24.
//

import XCTest

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
        
        // Select instance textfield
        XCUIRemote.shared.press(.select)
        
        let instanceUrl = app.textFields["instanceUrl"]
        instanceUrl.typeText("https://testfin.juliette.page\n")
        XCUIRemote.shared.press(.menu)
        
        // Select next button
        sleep(1)
        XCUIRemote.shared.press(.right)
        XCUIRemote.shared.press(.select)
        sleep(2)
        
        // Select instance url field
        XCUIRemote.shared.press(.select)
        let username = app.textFields["username"]
        username.typeText("testinguser\n")
        XCUIRemote.shared.press(.menu)
        
        // Password
        sleep(1)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        let password = app.secureTextFields["password"]
        password.typeText("verysecurepassword\n")
        XCUIRemote.shared.press(.menu)
        sleep(1)
        
        let quickConnectIsVisible = app.staticTexts["quickConnect"]
        XCTAssertTrue(quickConnectIsVisible.exists, "Quick connect visibility")
        
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        
        let alert = app.alerts.buttons["OK"]
        if alert.waitForNonExistence(timeout: 5) {
            XCTAssert(true)
        } else {
            XCTFail("Error signing in")
        }
    }
    
    func testInvalidDataFillOut() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting-reset") // Resets the simple keychain, allowing for sign in
        app.launch()
        
        // Select instance textfield
        XCUIRemote.shared.press(.select)
        
        let instanceUrl = app.textFields["instanceUrl"]
        instanceUrl.typeText("https://testfin.juliette.page\n")
        XCUIRemote.shared.press(.menu)
        
        // Select next button
        sleep(1)
        XCUIRemote.shared.press(.right)
        XCUIRemote.shared.press(.select)
        
        sleep(2)
        // Select instance url field
        XCUIRemote.shared.press(.select)
        let username = app.textFields["username"]
        username.typeText("asdf\n")
        XCUIRemote.shared.press(.menu)
        
        // Password
        sleep(1)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        let password = app.secureTextFields["password"]
        password.typeText("bbbb\n")
        XCUIRemote.shared.press(.menu)
        sleep(1)
        
        let quickConnectIsVisible = app.staticTexts["quickConnect"]
        XCTAssertTrue(quickConnectIsVisible.exists, "Quick connect visibility")
        
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        
        let alert = app.alerts.buttons["OK"]
        if alert.waitForExistence(timeout: 5) {
            XCTAssert(true)
        } else {
            XCTFail("Error signing in incorrectly")
        }
    }


}
