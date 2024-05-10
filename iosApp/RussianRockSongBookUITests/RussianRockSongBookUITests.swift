//
//  RussianRockSongBookUITests.swift
//  RussianRockSongBookUITests
//
//  Created by User on 04.05.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import XCTest
import shared

let ARTIST_1 = "Немного Нервно"
let ARTIST_2 = "Чайф"
let ARTIST_3 = "ДДТ"

let TITLE_1_1 = "Santa Maria"
let TITLE_1_2 = "Яблочный остров"
let TITLE_1_3 = "Над мертвым городом сон"
let TITLE_1_4 = "Atlantica"
let TITLE_2_1 = "17 лет"
let TITLE_2_2 = "Поплачь о нем"
let TITLE_3_1 = "Белая ночь"

final class RussianRockSongBookUITests: XCTestCase {
    var app: XCUIApplication!
    
    static let songRepo: SongRepository = {
        let factory = DatabaseDriverFactory()
        Injector.companion.initiate(databaseDriverFactory: factory)
        let repo = Injector.Companion.shared.songRepo
        JsonLoaderKt.testFillDbFromJSON(
            artists: [ARTIST_1],
            songRepo: repo,
            onProgressChanged: { done, total in
                print("\(done) of \(total)")
            }
        )
        return repo
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test0101_menuIsOpeningAndClosingWithDrawerButtonCorrectly() throws {
        while(!app.buttons["drawerButton"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton"].isHittable)
        app.buttons["drawerButton"].tap()
        sleep(1)
        while(!app.staticTexts["Меню"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts["Меню"].isHittable)
        while(!app.buttons["drawerButton2"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton2"].isHittable)
        app.buttons["drawerButton2"].tap()
        sleep(1)
        while(!app.staticTexts["Кино"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts["Кино"].isHittable)
    }
    
    func test0102_menuPredefinedArtistsAreDisplayingCorrectly() throws {
        while(!app.buttons["drawerButton"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton"].isHittable)
        app.buttons["drawerButton"].tap()
        sleep(1)
        while(!app.staticTexts["Меню"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts["Меню"].isHittable)
        SongRepositoryImplKt.predefinedList.forEach { label in
            while(!app.staticTexts[label].isHittable) {
                sleep(1)
            }
            XCTAssertTrue(app.staticTexts[label].isHittable)
        }
    }
    
    func test0103_menuIsScrollingCorrectly() throws {
        while(!app.buttons["drawerButton"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton"].isHittable)
        app.buttons["drawerButton"].tap()
        sleep(1)
        while (!app.scrollViews["menuScrollView"].isHittable) {
            sleep(1)
        }
        while (!app.staticTexts["Т"].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Т"].isHittable)
    }

    func test0104_songListForArtistIsOpeningFromMenuCorrectly() throws {
        let artists = Self.songRepo.getArtists()
        XCTAssertTrue(artists.contains(ARTIST_1))
        let songs = Self.songRepo.getSongsByArtist(artist: ARTIST_1)
        
        while(!app.buttons["drawerButton"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton"].isHittable)
        app.buttons["drawerButton"].tap()
        sleep(1)
        while (!app.scrollViews["menuScrollView"].isHittable) {
            sleep(1)
        }
        while (!app.staticTexts[ARTIST_1.artistGroup()].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[ARTIST_1.artistGroup()].isHittable)
        app.staticTexts[ARTIST_1.artistGroup()].tap()
        sleep(1)
        while (!app.staticTexts[ARTIST_1].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[ARTIST_1].isHittable)
        app.staticTexts[ARTIST_1].tap()
        while (!app.staticTexts[songs[0].title].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts[songs[0].title].isHittable)
        XCTAssertTrue(app.staticTexts[songs[1].title].isHittable)
        XCTAssertTrue(app.staticTexts[songs[2].title].isHittable)
    }
    
    func test0105_songListIsScrollingCorrectly() throws {
        while(!app.buttons["drawerButton"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton"].isHittable)
        app.buttons["drawerButton"].tap()
        sleep(1)
        while (!app.scrollViews["menuScrollView"].isHittable) {
            sleep(1)
        }
        while (!app.staticTexts[ARTIST_1.artistGroup()].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[ARTIST_1.artistGroup()].isHittable)
        app.staticTexts[ARTIST_1.artistGroup()].tap()
        sleep(1)
        while (!app.staticTexts[ARTIST_1].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[ARTIST_1].isHittable)
        app.staticTexts[ARTIST_1].tap()
        sleep(1)
        while (!app.staticTexts[TITLE_1_1].isHittable) {
            app.scrollViews["songListScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[TITLE_1_1].isHittable)
        while (!app.staticTexts[TITLE_1_2].isHittable) {
            app.scrollViews["songListScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[TITLE_1_2].isHittable)
        while (!app.staticTexts[TITLE_1_3].isHittable) {
            app.scrollViews["songListScrollView"].swipeDown()
        }
        XCTAssertTrue(app.staticTexts[TITLE_1_3].isHittable)
        while (!app.staticTexts[TITLE_1_4].isHittable) {
            app.scrollViews["songListScrollView"].swipeDown()
        }
        XCTAssertTrue(app.staticTexts[TITLE_1_4].isHittable)
    }
    
    func test0201_songTextIsOpeningFromSongListCorrectly() throws {
        let songs = Self.songRepo.getSongsByArtist(artist: ARTIST_1)
        let song = songs.first(where: {
            $0.title == TITLE_1_3
        })
        
        while(!app.buttons["drawerButton"].isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.buttons["drawerButton"].isHittable)
        app.buttons["drawerButton"].tap()
        sleep(1)
        while (!app.scrollViews["menuScrollView"].isHittable) {
            sleep(1)
        }
        while (!app.staticTexts[ARTIST_1.artistGroup()].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[ARTIST_1.artistGroup()].isHittable)
        app.staticTexts[ARTIST_1.artistGroup()].tap()
        sleep(1)
        while (!app.staticTexts[ARTIST_1].isHittable) {
            app.scrollViews["menuScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[ARTIST_1].isHittable)
        app.staticTexts[ARTIST_1].tap()
        sleep(1)
        while (!app.staticTexts[TITLE_1_3].isHittable) {
            app.scrollViews["songListScrollView"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts[TITLE_1_3].isHittable)
        app.staticTexts[TITLE_1_3].tap()
        sleep(1)
        while (!app.staticTexts.containing(NSPredicate(format: "label == %@", song!.text)).firstMatch.isHittable) {
            sleep(1)
        }
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label == %@", song!.text)).firstMatch.isHittable)
        XCTAssertTrue(app.staticTexts[TITLE_1_3].isHittable)
    }
    
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}

extension String {
    func artistGroup() -> String {
        return self.prefix(1).uppercased()
    }
}
