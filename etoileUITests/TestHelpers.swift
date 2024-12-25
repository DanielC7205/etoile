//
//  TestHelpers.swift
//  iosTests
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import Foundation
import XCTest

func login(_ app: XCUIApplication) {
    if app.staticTexts["hiLabel"].waitForExistence(timeout: 4) {
        return
    }
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
    
    let done = app.buttons["done"]
    if !done.waitForExistence(timeout: 20) {
        XCTFail("Albums not refreshed after twenty seconds!")
    }
    
    done.tap()
}
