//
//  PlaylistTests.swift
//  iosTests
//
//  Created by Juliette Bernheisel on 9/19/24.
//

import Foundation
import XCTest

final class PlaylistTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreatePlaylist() throws {
        let app = XCUIApplication()
        app.launch()
        
        login(app)
        
        let atlas = app.cells["Atlas: I"]
        
        if !atlas.waitForExistence(timeout: 5) {
            XCTFail("Failed to get Atlas I album in a reasonable time")
        }
        
        atlas.tap()
        
        let albumName = app.staticTexts["albumName"]

        if !albumName.waitForExistence(timeout: 3) {
            XCTFail("Failed to load album in a reasonable time")
        }
    
        let song = app.cells["Overture"]
        
        if !song.waitForExistence(timeout: 2) {
            XCTFail("Failed to load song list in a reasonable time")
        }
        
        song.tap()

    }
}
