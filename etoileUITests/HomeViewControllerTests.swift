//
//  HomeViewControllerTests.swift
//  etoileUITests
//
//  Created by Juliette Bernheisel on 8/23/24.
//

import XCTest

final class HomeViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAlbumGetsRightAlbum() throws {
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
        
        XCTAssertEqual(albumName.firstMatch.label, "Atlas: I")
    }
    
    /// Plays song from album and checks if miniplayer is accurate
    func testPlaySongFromAlbum() throws {
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
    
        XCTAssertEqual(albumName.firstMatch.label, "Atlas: I")
        
        let song = app.cells["Overture"]
        
        if !song.waitForExistence(timeout: 2) {
            XCTFail("Failed to load song list in a reasonable time")
        }
        
        song.tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
    
        let miniPlayerLabel = app.staticTexts["miniPlayerSongNameLabel"]
        
        XCTAssertEqual(miniPlayerLabel.label, "Overture")
    }
    
    func testRecentlyPlayed() throws {
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
    
        XCTAssertEqual(albumName.firstMatch.label, "Atlas: I")
        
        let song = app.cells["Woodwork"]
        
        if !song.waitForExistence(timeout: 2) {
            XCTFail("Failed to load song list in a reasonable time")
        }
        
        song.tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
    
        let miniPlayerLabel = app.staticTexts["miniPlayerSongNameLabel"]
        
        XCTAssertEqual(miniPlayerLabel.label, "Woodwork")

        let player = app.staticTexts["Woodwork richSongSongNameLabel"]
        
        XCTAssert(player.exists, "Found the right song in recently playing")
        
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Home with recently played and mini player"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    
}
