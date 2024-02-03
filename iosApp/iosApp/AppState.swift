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
    var theme = Preferences.loadThemeVariant().theme(fontScale: Preferences.loadFontScaleVariant().fontScale())
    var currentScreenVariant: ScreenVariant = ScreenVariant.start
    var localState: LocalState = LocalState()
    var cloudState: CloudState = CloudState()
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

struct CloudState {
    var currentCloudSongList: [CloudSong]? = nil
    var currentCloudSongCount: Int = 0
    var currentCloudSongIndex: Int = 0
    var currentCloudSong: CloudSong? = nil
    var currentCloudOrderBy: OrderBy = OrderBy.byIdDesc
    var searchForBackup: String = ""
    var allLikes: Dictionary<CloudSong, Int> = [:]
    var allDislikes: Dictionary<CloudSong, Int> = [:]
}
