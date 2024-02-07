//
//  AppState.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 02.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
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
    let showToast: (String) -> ()
    
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
        } else if (action is LocalPrevClick) {
            self.prevSong(appState: &newState)
        } else if (action is LocalNextClick) {
            self.nextSong(appState: &newState)
        } else if (action is FavoriteToggle) {
            self.toggleFavorite(appState: &newState)
        } else if (action is SaveSongText) {
            self.saveSongText(appState: &newState, newText: (action as! SaveSongText).newText)
        } else if (action is ConfirmDeleteToTrash) {
            self.deleteCurrentToTrash(appState: &newState)
        } else if (action is ShowToast) {
            self.showToast((action as! ShowToast).text)
        } else if (action is OpenSongAtVkMusic) {
            self.openSongAtVkMusic((action as! OpenSongAtVkMusic).music)
        } else if (action is OpenSongAtYandexMusic) {
            self.openSongAtYandexMusic((action as! OpenSongAtYandexMusic).music)
        } else if (action is OpenSongAtYoutubeMusic) {
            self.openSongAtYoutubeMusic((action as! OpenSongAtYoutubeMusic).music)
        } else if (action is SendWarning) {
            self.sendWarning((action as! SendWarning).warning)
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
    
    private func prevSong(appState: inout AppState) {
        if (appState.localState.currentCount == 0) {
            return
        }
        if (appState.localState.currentSongIndex > 0) {
            appState.localState.currentSongIndex -= 1
        } else {
            appState.localState.currentSongIndex = appState.localState.currentCount - 1
        }
        self.refreshCurrentSong(appState: &appState)
    }
    
    func nextSong(appState: inout AppState) {
        if (appState.localState.currentCount == 0) {
            return
        }
        appState.localState.currentSongIndex = (appState.localState.currentSongIndex + 1) % appState.localState.currentCount
        self.refreshCurrentSong(appState: &appState)
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
    
    private func toggleFavorite(appState: inout AppState) {
        let song = appState.localState.currentSong!.copy() as! Song
        let becomeFavorite = !song.favorite
        song.favorite = becomeFavorite
        ContentView.songRepo.updateSong(song: song)
        if (!becomeFavorite && appState.localState.currentArtist == ContentView.ARTIST_FAVORITE) {
            let count = ContentView.songRepo.getCountByArtist(artist: ContentView.ARTIST_FAVORITE)
            appState.localState.currentCount = Int(count)
            if (appState.localState.currentCount > 0) {
                if (appState.localState.currentSongIndex >= appState.localState.currentCount) {
                    appState.localState.currentSongIndex -= 1
                }
                self.refreshCurrentSong(appState: &appState)
            } else {
                self.back(appState: &appState)
            }
        } else {
            self.refreshCurrentSong(appState: &appState)
        }
        if (becomeFavorite) {
            self.showToast("Добавлено в избранное")
        } else {
            self.showToast("Удалено из избранного")
        }
    }
    
    private func saveSongText(appState: inout AppState, newText: String) {
        let song = appState.localState.currentSong!.copy() as! Song
        song.text = newText
        ContentView.songRepo.updateSong(song: song)
        self.refreshCurrentSong(appState: &appState)
    }
    
    private func deleteCurrentToTrash(appState: inout AppState) {
        print("deleting to trash: \(appState.localState.currentSong!.artist) - \(appState.localState.currentSong!.title)")
        let song = appState.localState.currentSong!.copy() as! Song
        song.deleted = true
        ContentView.songRepo.updateSong(song: song)
        let count = ContentView.songRepo.getCountByArtist(artist: appState.localState.currentArtist)
        appState.localState.currentCount = Int(count)
        appState.artists = ContentView.songRepo.getArtists()
        if (appState.localState.currentCount > 0) {
            if (appState.localState.currentSongIndex >= appState.localState.currentCount) {
                appState.localState.currentSongIndex -= 1
            }
            refreshCurrentSong(appState: &appState)
        } else {
            back(appState: &appState)
        }
        showToast("Удалено")
    }
    
    private func openSongAtYandexMusic(_ music: Music) {
        if let url = URL(string: music.yandexMusicUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openSongAtYoutubeMusic(_ music: Music) {
        if let url = URL(string: music.youtubeMusicUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openSongAtVkMusic(_ music: Music) {
        if let url = URL(string: music.vkMusicUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendWarning(_ warning: Warning) {
        CloudRepository.shared.addWarningAsync(
            warning: warning,
            onSuccess: {
                self.showToast("Уведомление отправлено")
            }, onServerMessage: {
                self.showToast($0)
            }, onError: {
                $0.printStackTrace()
                self.showToast("Ошибка в приложении")
            })
    }
}
