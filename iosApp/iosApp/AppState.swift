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
    var artists = ContentView.songRepo.getArtists()
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

struct AppStateMachine {
    func performAction(appState: AppState, action: AppUIAction) -> AppState? {
        var newState = appState
        if (action is SongClick) {
            self.selectSong(appState: &newState, songIndex: (action as! SongClick).songIndex)
        } else if (action is LocalScroll) {
            self.updateSongIndexByScroll(appState: &newState, songIndex: (action as! LocalScroll).songIndex)
        } else if (action is DrawerClick) {
            self.toggleDrawer(appState: &newState)
        } else if (action is OpenSettings) {
            self.openSettings(appState: &newState)
        } else if (action is BackClick) {
            self.back(appState: &newState)
        } else {
            return nil
        }
        return newState
    }
    
    private func selectSong(appState: inout AppState, songIndex: Int) {
        print("select song with index: \(songIndex)")
        appState.localState.currentSongIndex = songIndex
        self.refreshCurrentSong(appState: &appState)
        appState.currentScreenVariant = ScreenVariant.songText
    }
    
    private func refreshCurrentSong(appState: inout AppState) {
        appState.localState.currentSong = ContentView
            .songRepo
            .getSongByArtistAndPosition(artist: appState.localState.currentArtist, position: Int32(appState.localState.currentSongIndex))
    }
    
    private func updateSongIndexByScroll(appState: inout AppState, songIndex: Int) {
        appState.localState.currentSongIndex = songIndex
    }
    
    private func toggleDrawer(appState: inout AppState) {
        appState.localState.isDrawerOpen.toggle()
    }
    
    private func openSettings(appState: inout AppState) {
        print("opening settings")
        appState.currentScreenVariant = .settings
    }
    
    private func back(appState: inout AppState) {
        if (appState.currentScreenVariant == .songText) {
            appState.currentScreenVariant = .songList
        } else if (appState.currentScreenVariant == .cloudSearch) {
            appState.cloudState.currentCloudSongList = nil
            appState.currentScreenVariant = .songList
        } else if (appState.currentScreenVariant == .cloudSongText) {
            appState.currentScreenVariant = .cloudSearch
        } else if (appState.currentScreenVariant == .settings) {
            appState.currentScreenVariant = .songList
        }
    }
}
