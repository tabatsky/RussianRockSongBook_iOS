//
//  AppState.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 02.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI
import shared

extension AppState {
    var theme: Theme {
        self.themeVariant.theme(fontScale: self.fontScaleVariant.fontScale())
    }
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
    
    let kotlinStateMachine: KotlinStateMachine
    
    init(showToast: @escaping (String) -> Void) {
        self.showToast = showToast
        self.kotlinStateMachine = KotlinStateMachine(showToast: showToast)
    }
    
    func performAction(changeState: @escaping (AppState) -> (), appState: AppState, action: AppUIAction) {
        if (kotlinStateMachine.canPerformAction(action: action)) {
            kotlinStateMachine.performAction(appState: appState, action: action, changeState: changeState)
            return
        }
        
        var newState = appState
        var asyncMode = false
        if (action is UploadCurrentToCloud) {
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
            self.onUpdateDone(appState: newState, changeState: changeState)
        }
        
        if (!asyncMode) {
            changeState(newState)
        }
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
        newState = newState.changeCloudState(cloudState: newState.cloudState.changeSearchState(searchState: SearchState.loading))
        changeState(newState)
        CloudRepository.shared.searchSongsAsync(
            searchFor: searchFor,
            orderBy: orderBy,
            onSuccess: { data in
                self.refreshCloudSongList(appState: &newState, cloudSongList: data)
                if (data.isEmpty) {
                    newState = newState.changeCloudState(cloudState: newState.cloudState.changeSearchState(searchState: SearchState.emptyList))
               } else {
                   newState = newState.changeCloudState(cloudState: newState.cloudState.changeSearchState(searchState: SearchState.loadSuccess))
               }
                changeState(newState)
            },onError: { t in
                t.printStackTrace()
                newState = newState.changeCloudState(cloudState: newState.cloudState.changeSearchState(searchState: SearchState.loadError))
                changeState(newState)
            }
        )
    }
    
    private func refreshCloudSongList(appState: inout AppState, cloudSongList: [CloudSong]) {
        print(cloudSongList.count)
        
        appState = appState.changeCloudState(cloudState: appState.cloudState
            .resetLikes()
            .resetDislikes()
            .changeCloudSongList(cloudSongList: cloudSongList)
            .changeCount(count: Int32(cloudSongList.count))
            .changeCloudSongIndex(index: 0)
            .changeCloudSong(cloudSong: nil))
    }
    
    private func selectOrderBy(appState: inout AppState, orderBy: OrderBy) {
        appState = appState.changeCloudState(cloudState: appState.cloudState
            .changeCloudSongIndex(index: 0)
            .changeCloudSong(cloudSong: nil)
            .changeOrderBy(orderBy: orderBy))
    }
    
    
    private func backupSearchFor(appState: inout AppState, searchFor: String) {
        appState = appState.changeCloudState(cloudState: appState.cloudState.changeSearchForBackup(backup: searchFor))
    }
    
    private func selectCloudSong(appState: inout AppState, index: Int) {
        print("select cloud song: \(index)")
        appState = appState.changeCloudState(cloudState: appState.cloudState
            .changeCloudSongIndex(index: Int32(index))
            .changeCloudSong(cloudSong: appState.cloudState.currentCloudSongList![index]))
            .changeScreenVariant(screenVariant: .cloudSongText)
    }
    
    private func prevCloudSong(appState: inout AppState) {
        if (appState.cloudState.currentCloudSongIndex - 1 >= 0) {
            self.selectCloudSong(appState: &appState, index: Int(appState.cloudState.currentCloudSongIndex - 1))
        }
    }
    
    private func nextCloudSong(appState: inout AppState) {
        if (appState.cloudState.currentCloudSongIndex + 1 < appState.cloudState.currentCloudSongCount) {
            self.selectCloudSong(appState: &appState, index: Int(appState.cloudState.currentCloudSongIndex + 1))
        }
    }
    
    private func performLike(changeState: @escaping (AppState) -> Void, appState: AppState, cloudSong: CloudSong) {
        CloudRepository.shared.voteAsync(
            cloudSong: cloudSong, voteValue: 1,
            onSuccess: {
                var newState = appState
                print($0)
                newState = newState.changeCloudState(cloudState: newState.cloudState.addLike(cloudSong: cloudSong))
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
                newState = newState.changeCloudState(cloudState: newState.cloudState.addDislike(cloudSong: cloudSong))
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
        appState = appState.changeArtists(artists: Self.songRepo.getArtists())
        let count = Self.songRepo.getCountByArtist(artist: appState.localState.currentArtist)
        appState = appState.changeLocalState(localState: appState.localState
            .changeCount(count: count)
            .changeSongList(songList: Self.songRepo.getSongsByArtist(artist: appState.localState.currentArtist)))
        self.showToast("Аккорды сохранены в локальной базе данных и добавлены в избранное")
    }
    
    func onUpdateDone(appState: AppState, changeState: @escaping (AppState) -> ()) {
        self.performAction(changeState: { newState in
            changeState(newState.changeScreenVariant(screenVariant: .songList))
        }, appState: appState, action: SelectArtist(artist: Self.defaultArtist, callback: {}))
    }
}
