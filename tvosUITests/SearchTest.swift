//
//  SearchTest.swift
//  tvOSTests
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import Foundation
import XCTest

final class SearchTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
        
    func testPlaySongFromSearch() {
        let app = XCUIApplication()
        app.launch()

        signIn(app)
        
        XCUIRemote.shared.press(.right)
        XCUIRemote.shared.press(.right)
        
        sleep(3)
        
        XCUIRemote.shared.press(.down)
            
        app.searchFields.element(boundBy: 0).typeText("Ov")
        
        sleep(2)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.left)
        XCUIRemote.shared.press(.select)
        
        sleep(1)
        
        let songName = app.staticTexts["songName"]
        XCTAssert(songName.label == "Overture", "Check if right song is playing")
    }
    
    func testOpenAlbumFromSearch() {
        let app = XCUIApplication()
        app.launch()

        signIn(app)
        
        XCUIRemote.shared.press(.right)
        XCUIRemote.shared.press(.right)
        
        sleep(3)
        
        XCUIRemote.shared.press(.down)
            
        app.searchFields.element(boundBy: 0).typeText("Atlas: I")
        
        sleep(2)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.down)
        XCUIRemote.shared.press(.left)
        XCUIRemote.shared.press(.select)
        
        sleep(1)
        let albumName = app.staticTexts["albumName"]
        
        XCTAssert(albumName.label == "Atlas: I", "Album name is not correct")
    }
}
