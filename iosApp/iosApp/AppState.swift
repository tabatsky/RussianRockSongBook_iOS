//
//  AppState.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 02.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import shared

struct AppState {
    var currentScreenVariant: ScreenVariant = ScreenVariant.start
    var localState: LocalState = LocalState()
}


struct LocalState {
    var isDrawerOpen: Bool = false
    var currentArtist: String = ContentView.defaultArtist
    var currentCount: Int = {
        let count = ContentView.songRepo.getCountByArtist(artist: ContentView.defaultArtist)
        return Int(count)
    }()
    var currentSongIndex: Int = 0
    var currentSong: Song? = nil
}
