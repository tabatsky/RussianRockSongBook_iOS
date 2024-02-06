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

struct SongClick: AppUIAction {
    let songIndex: Int
}

struct LocalScroll: AppUIAction {
    let songIndex: Int
}

struct DrawerClick: AppUIAction {}
struct OpenSettings: AppUIAction {}
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
