//
//  SettingsTests.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/14/24.
//

import Foundation
import XCTest

final class SettingsTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRefreshFromSettings() throws {
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        
        app.navigationBars.children(matching: .button).firstMatch.tap()
        
        if !app.staticTexts["settingsLabel"].waitForExistence(timeout: 2) {
            XCTFail("Failed to load settings view controller in a reasonable time")
        }
        
        app.buttons["refreshButton"].tap()
        
        let done = app.buttons["done"]
        if !done.waitForExistence(timeout: 20) {
            XCTFail("Albums not refreshed after twenty seconds!")
        }
        
        done.tap()
        XCTAssertTrue(true)
    }
    
    func testLogoutFromSettings() throws {
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        
        app.navigationBars.children(matching: .button).firstMatch.tap()
        
        if !app.staticTexts["settingsLabel"].waitForExistence(timeout: 2) {
            XCTFail("Failed to load settings view controller in a reasonable time")
        }
        
        app.buttons["logoutButton"].tap()
        
        if !app.secureTextFields["Password"].waitForExistence(timeout: 5) {
            XCTFail("Failed to load login view controller in a reasonable time")
        }
    }
}
