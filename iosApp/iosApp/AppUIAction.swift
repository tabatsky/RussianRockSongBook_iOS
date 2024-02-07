//
//  AppUIAction.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 06.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import shared

protocol AppUIAction {}

struct SelectArtist: AppUIAction {
    let artist: String
}

struct OpenSettings: AppUIAction {}
struct ReloadSettings: AppUIAction {}

struct SongClick: AppUIAction {
    let songIndex: Int
}

struct LocalScroll: AppUIAction {
    let songIndex: Int
}

struct DrawerClick: AppUIAction {}
struct BackClick: AppUIAction {}
struct LocalPrevClick: AppUIAction {}
struct LocalNextClick: AppUIAction {}
struct FavoriteToggle: AppUIAction {}

struct SaveSongText: AppUIAction {
    let newText: String
}

struct ConfirmDeleteToTrash: AppUIAction {}

struct ShowToast: AppUIAction {
    let text: String
}

struct OpenSongAtVkMusic: AppUIAction {
    let music: Music
}

struct OpenSongAtYandexMusic: AppUIAction {
    let music: Music
}

struct OpenSongAtYoutubeMusic: AppUIAction {
    let music: Music
}

struct SendWarning: AppUIAction {
    let warning: Warning
}

struct CloudSearch: AppUIAction {
    let searchFor: String
    let orderBy: OrderBy
}

struct CloudSongClick: AppUIAction {
    let index: Int
}

struct SelectOrderBy: AppUIAction {
    let orderBy: OrderBy
}

struct BackupSearchFor: AppUIAction {
    let searchFor: String
}

struct CloudPrevClick: AppUIAction {}
struct CloudNextClick: AppUIAction {}

struct LikeClick: AppUIAction {
    let cloudSong: CloudSong
}

struct DislikeClick: AppUIAction {
    let cloudSong: CloudSong
}

struct DownloadClick: AppUIAction {
    let cloudSong: CloudSong
}

struct UpdateDone: AppUIAction {}
