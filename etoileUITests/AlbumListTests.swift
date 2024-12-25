//
//  AlbumListTests.swift
//  iosTests
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import Foundation
import XCTest

final class AlbumListTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoToAlbumList() throws {
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        
        app.tabBars.buttons["albumsTabBarItem"].tap()
        
        XCTAssertTrue(app.tables["albumVerticalTableView"].exists, "Check if album tab navigates to album list")
    }
    
    func testOpenAlbum() throws {
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        
        app.tabBars.buttons["albumsTabBarItem"].tap()
        
        XCTAssertTrue(app.tables["albumVerticalTableView"].exists, "Check if album tab navigates to album list")
        
        app.cells["Atlas: I verticalAlbumCell"].tap()
        
        let albumName = app.staticTexts["albumName"]

        if !albumName.waitForExistence(timeout: 3) {
            XCTFail("Failed to load album in a reasonable time")
        }
    
        XCTAssertEqual(albumName.firstMatch.label, "Atlas: I")
    }
    
    func testScreenshot() throws {
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        
        app.tabBars.buttons["albumsTabBarItem"].tap()
        
        XCTAssertTrue(app.tables["albumVerticalTableView"].exists, "Check if album tab navigates to album list")
        
        app.cells["Atlas: I verticalAlbumCell"].tap()
        
        let albumName = app.staticTexts["albumName"]

        if !albumName.waitForExistence(timeout: 3) {
            XCTFail("Failed to load album in a reasonable time")
        }

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Search view"
        attachment.lifetime = .keepAlways
        add(attachment)

    }
}
