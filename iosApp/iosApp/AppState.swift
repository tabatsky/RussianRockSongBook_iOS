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
    var artists = AppStateMachine.songRepo.getArtists()
    var localState: LocalState = LocalState()
    var cloudState: CloudState = CloudState()
}


struct LocalState {
    var isDrawerOpen: Bool = false
    var currentArtist: String = AppStateMachine.defaultArtist
    var currentSongList: [Song] = {
        AppStateMachine.songRepo.getSongsByArtist(artist: AppStateMachine.defaultArtist)
    }()
    var currentCount: Int = {
        let count = AppStateMachine.songRepo.getCountByArtist(artist: AppStateMachine.defaultArtist)
        return Int(count)
    }()
    var currentSongIndex: Int = 0
    var currentSong: Song? = nil
}

struct CloudState {
    var currentSearchState: SearchState = .loading
    var currentCloudSongList: [CloudSong]? = nil
    var currentCloudSongCount: Int = 0
    var currentCloudSongIndex: Int = 0
    var currentCloudSong: CloudSong? = nil
    var currentCloudOrderBy: OrderBy = OrderBy.byIdDesc
    var searchForBackup: String = ""
    var allLikes: Dictionary<CloudSong, Int> = [:]
    var allDislikes: Dictionary<CloudSong, Int> = [:]
}

enum ScreenVariant {
    case start
    case songList
    case songText
    case cloudSearch
    case cloudSongText
    case settings
}

enum SearchState {
    case loading
    case loadSuccess
    case loadError
    case emptyList
}

struct AppStateMachine {
    static let songRepo: SongRepository = {
        let factory = DatabaseDriverFactory()
        Injector.companion.initiate(databaseDriverFactory: factory)
        return Injector.Companion.shared.songRepo
    }()

    static let predefinedList = SongRepositoryImplKt.predefinedList
    static let ARTIST_FAVORITE = SongRepositoryKt.ARTIST_FAVORITE
    static let ARTIST_CLOUD_SONGS = SongRepositoryKt.ARTIST_CLOUD_SONGS
    static let defaultArtist = "Кино"
    
    let showToast: (String) -> ()
    
    func performAction(changeState: @escaping (AppState) -> (), appState: AppState, action: AppUIAction) {
        var newState = appState
        var asyncMode = false
        if (action is SelectArtist) {
            self.selectArtist(appState: &newState, artist: (action as! SelectArtist).artist)
        } else if (action is OpenSettings) {
            self.openSettings(appState: &newState)
        } else if (action is ReloadSettings) {
            self.reloadSettings(appState: &newState)
        } else if (action is SongClick) {
            self.selectSong(appState: &newState, songIndex: (action as! SongClick).songIndex)
        } else if (action is LocalScroll) {
            self.updateSongIndexByScroll(appState: &newState, songIndex: (action as! LocalScroll).songIndex)
        } else if (action is DrawerClick) {
            self.toggleDrawer(appState: &newState)
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
        } else if (action is UploadCurrentToCloud) {
            self.uploadCurrentToCloud(appState: newState)
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
        } else if (action is CloudSearch) {
            asyncMode = true
            let cloudSearchAction = action as! CloudSearch
            self.searchSongs(changeState: { changeState($0) },
                             appState: newState,
                             searchFor: cloudSearchAction.searchFor,
                             orderBy: cloudSearchAction.orderBy)
        } else if (action is SelectOrderBy) {
            self.selectOrderBy(appState: &newState, orderBy: (action as! SelectOrderBy).orderBy)
        } else if (action is BackupSearchFor) {
            self.backupSearchFor(appState: &newState, searchFor: (action as! BackupSearchFor).searchFor)
        } else if (action is CloudSongClick) {
            self.selectCloudSong(appState: &newState, index: (action as! CloudSongClick).index)
        } else if (action is CloudPrevClick) {
            self.prevCloudSong(appState: &newState)
        } else if (action is CloudNextClick) {
            self.nextCloudSong(appState: &newState)
        } else if (action is LikeClick) {
            asyncMode = true
            self.performLike(changeState: { changeState($0) },
                             appState: newState,
                             cloudSong: (action as! LikeClick).cloudSong)
        } else if (action is DislikeClick) {
            asyncMode = true
            self.performDislike(changeState: { changeState($0) },
                                appState: newState,
                                cloudSong: (action as! DislikeClick).cloudSong)
        } else if (action is DownloadClick) {
            self.downloadCurrent(appState: &newState, cloudSong: (action as! DownloadClick).cloudSong)
        } else if (action is UpdateDone) {
            self.onUpdateDone(appState: &newState)
        }
        
        if (!asyncMode) {
            changeState(newState)
        }
    }
    
    func selectArtist(appState: inout AppState, artist: String) {
        print("select artist: \(artist)")
        if (Self.predefinedList.contains(artist) && artist != Self.ARTIST_FAVORITE) {
            if (artist == Self.ARTIST_CLOUD_SONGS) {
                appState.cloudState.searchForBackup = ""
                appState.cloudState.currentCloudSongIndex = 0
                appState.cloudState.currentCloudOrderBy = OrderBy.byIdDesc
                appState.cloudState.currentCloudSongList = nil
                appState.currentScreenVariant = ScreenVariant.cloudSearch
            }
        } else if (appState.localState.currentArtist != artist || appState.localState.currentCount == 0) {
            print("artist changed")
            appState.localState.currentArtist = artist
            let count = Self.songRepo.getCountByArtist(artist: artist)
            appState.localState.currentCount = Int(count)
            appState.localState.currentSongList = Self.songRepo.getSongsByArtist(artist: artist)
            appState.localState.currentSongIndex = 0
        }
        appState.localState.isDrawerOpen = false
    }
    
    private func openSettings(appState: inout AppState) {
        print("opening settings")
        appState.currentScreenVariant = .settings
    }
    
    private func reloadSettings(appState: inout AppState) {
        appState.theme = Preferences.loadThemeVariant().theme(fontScale: Preferences.loadFontScaleVariant().fontScale())
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
        appState.localState.currentSong = Self.songRepo
            .getSongByArtistAndPosition(artist: appState.localState.currentArtist, position: Int32(appState.localState.currentSongIndex))
    }
    
    private func updateSongIndexByScroll(appState: inout AppState, songIndex: Int) {
        appState.localState.currentSongIndex = songIndex
    }
    
    private func toggleDrawer(appState: inout AppState) {
        appState.localState.isDrawerOpen.toggle()
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
        Self.songRepo.updateSong(song: song)
        if (!becomeFavorite && appState.localState.currentArtist == Self.ARTIST_FAVORITE) {
            let count = Self.songRepo.getCountByArtist(artist: Self.ARTIST_FAVORITE)
            appState.localState.currentCount = Int(count)
            if (appState.localState.currentCount > 0) {
                if (appState.localState.currentSongIndex >= appState.localState.currentCount) {
                    appState.localState.currentSongIndex -= 1
                }
                self.refreshCurrentSong(appState: &appState)
            } else {
                self.back(appState: &appState)
            }
            appState.localState.currentSongList = Self.songRepo.getSongsByArtist(artist: Self.ARTIST_FAVORITE)
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
        Self.songRepo.updateSong(song: song)
        self.refreshCurrentSong(appState: &appState)
    }
    
    private func deleteCurrentToTrash(appState: inout AppState) {
        print("deleting to trash: \(appState.localState.currentSong!.artist) - \(appState.localState.currentSong!.title)")
        let song = appState.localState.currentSong!.copy() as! Song
        song.deleted = true
        Self.songRepo.updateSong(song: song)
        let count = Self.songRepo.getCountByArtist(artist: appState.localState.currentArtist)
        appState.localState.currentCount = Int(count)
        appState.artists = Self.songRepo.getArtists()
        if (appState.localState.currentCount > 0) {
            if (appState.localState.currentSongIndex >= appState.localState.currentCount) {
                appState.localState.currentSongIndex -= 1
            }
            refreshCurrentSong(appState: &appState)
        } else {
            back(appState: &appState)
        }
        appState.localState.currentSongList = Self.songRepo.getSongsByArtist(artist: appState.localState.currentArtist)
        showToast("Удалено")
    }

    private func uploadCurrentToCloud(appState: AppState) {
        print("upload to cloud")
        let song = appState.localState.currentSong!
        let textWasChanged = song.textWasChanged
        if (!textWasChanged) {
            showToast("Нельзя залить в облако: данный вариант аккордов поставляется вместе с приложением либо был сохранен из облака")
        } else {
            CloudRepository.shared.addCloudSongAsync(
                cloudSong: song.asCloudSong(),
                onSuccess: {
                    showToast("Успешно добавлено в облако")
                },
                onServerMessage: {
                    showToast($0)
                }, onError: {
                    $0.printStackTrace()
                    showToast("Ошибка в приложении")
                })
        }
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
    
    private func searchSongs(changeState: @escaping (AppState) -> Void, appState: AppState, searchFor: String, orderBy: OrderBy) {
        var newState = appState
        newState.cloudState.currentSearchState = SearchState.loading
        changeState(newState)
        CloudRepository.shared.searchSongsAsync(
            searchFor: searchFor,
            orderBy: orderBy,
            onSuccess: { data in
                self.refreshCloudSongList(appState: &newState, cloudSongList: data)
                if (data.isEmpty) {
                    newState.cloudState.currentSearchState = .emptyList
               } else {
                   newState.cloudState.currentSearchState = .loadSuccess
               }
                changeState(newState)
            },onError: { t in
                t.printStackTrace()
                newState.cloudState.currentSearchState = SearchState.loadError
                changeState(newState)
            }
        )
    }
    
    private func refreshCloudSongList(appState: inout AppState, cloudSongList: [CloudSong]) {
        print(cloudSongList.count)
        
        appState.cloudState.allLikes = [:]
        appState.cloudState.allDislikes = [:]
        appState.cloudState.currentCloudSongList = cloudSongList
        appState.cloudState.currentCloudSongCount = cloudSongList.count
        appState.cloudState.currentCloudSongIndex = 0
        appState.cloudState.currentCloudSong = nil
    }
    
    private func selectOrderBy(appState: inout AppState, orderBy: OrderBy) {
        appState.cloudState.currentCloudSongIndex = 0
        appState.cloudState.currentCloudSong = nil
        appState.cloudState.currentCloudOrderBy = orderBy
    }
    
    
    private func backupSearchFor(appState: inout AppState, searchFor: String) {
        appState.cloudState.searchForBackup = searchFor
    }
    
    private func selectCloudSong(appState: inout AppState, index: Int) {
        print("select cloud song: \(index)")
        appState.cloudState.currentCloudSongIndex = index
        appState.cloudState.currentCloudSong = appState.cloudState.currentCloudSongList![index]
        appState.currentScreenVariant = .cloudSongText
    }
    
    private func prevCloudSong(appState: inout AppState) {
        if (appState.cloudState.currentCloudSongIndex - 1 >= 0) {
            self.selectCloudSong(appState: &appState, index: appState.cloudState.currentCloudSongIndex - 1)
        }
    }
    
    private func nextCloudSong(appState: inout AppState) {
        if (appState.cloudState.currentCloudSongIndex + 1 < appState.cloudState.currentCloudSongCount) {
            self.selectCloudSong(appState: &appState, index: appState.cloudState.currentCloudSongIndex + 1)
        }
    }
    
    private func performLike(changeState: @escaping (AppState) -> Void, appState: AppState, cloudSong: CloudSong) {
        CloudRepository.shared.voteAsync(
            cloudSong: cloudSong, voteValue: 1,
            onSuccess: {
                var newState = appState
                print($0)
                let oldCount = newState.cloudState.allLikes[cloudSong] ?? 0
                newState.cloudState.allLikes[cloudSong] = oldCount + 1
                changeState(newState)
                self.showToast("Ваш голос засчитан")
            }, onServerMessage: {
                self.showToast($0)
            }, onError: {
                $0.printStackTrace()
                self.showToast("Ошибка в приложении")
            })
    }
    
    private func performDislike(changeState: @escaping (AppState) -> Void, appState: AppState, cloudSong: CloudSong) {
        CloudRepository.shared.voteAsync(
            cloudSong: cloudSong, voteValue: -1,
            onSuccess: {
                var newState = appState
                print($0)
                let oldCount = newState.cloudState.allDislikes[cloudSong] ?? 0
                newState.cloudState.allDislikes[cloudSong] = oldCount + 1
                changeState(newState)
                self.showToast("Ваш голос засчитан")
            }, onServerMessage: {
                self.showToast($0)
            }, onError: {
                $0.printStackTrace()
                self.showToast("Ошибка в приложении")
            })
    }
    
    private func downloadCurrent(appState: inout AppState, cloudSong: CloudSong) {
        Self.songRepo.addSongFromCloud(song: cloudSong.asSong())
        appState.artists = Self.songRepo.getArtists()
        let count = Self.songRepo.getCountByArtist(artist: appState.localState.currentArtist)
        appState.localState.currentCount = Int(count)
        appState.localState.currentSongList = Self.songRepo.getSongsByArtist(artist: appState.localState.currentArtist)
        self.showToast("Аккорды сохранены в локальной базе данных и добавлены в избранное")
    }
    
    func onUpdateDone(appState: inout AppState) {
        self.selectArtist(appState: &appState, artist: Self.defaultArtist)
        appState.currentScreenVariant = .songList
    }
}
