//
//  TestHelper.swift
//  tvOSTests
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import Foundation
import XCTest

func signIn(_ app: XCUIApplication) {
    if !app.staticTexts["welcome"].exists {
        return
    }
    
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
    
    let doneButton = app.buttons["done"]
    if !doneButton.waitForExistence(timeout: 10) {
        XCTFail("Failed to get library in a reasonable time")
    }

}
