//
//  AlbumsTest.swift
//  tvOSTests
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import Foundation
import XCTest

final class AlbumsTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetAlbum() {
        let app = XCUIApplication()
        app.launch()

        signIn(app)
        
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        
        sleep(1)
        
        let albumName = app.staticTexts["albumName"]
        
        XCTAssert(albumName.label == "Atlas: I", "Album name is not correct")
    }
    
    func testPlaySongFromAlbum() {
        let app = XCUIApplication()
        app.launch()

        signIn(app)
        
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.select)
        
        sleep(1)
        
        XCUIRemote.shared.press(.select)
        
        sleep(4)
        
        let songName = app.staticTexts["songName"]
        XCTAssert(songName.label == "Overture", "Check if right song is playing")
    }
}
