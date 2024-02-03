//
//  AppCallbacks.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 02.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import shared

class LocalCallbacks {
    let onSongClick: (Int) -> ()
    let onScroll: (Int) -> ()
    let onDrawerClick: () -> ()
    let onOpenSettings: () -> ()
    let onBackClick: () -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    let onFavoriteToggle: () -> ()
    let onSaveSongText: (String) -> ()
    let onDeleteToTrashConfirmed: () -> ()
    let onShowToast: (String) -> ()
    let onOpenSongAtYandexMusic: (Music) -> ()
    let onOpenSongAtYoutubeMusic: (Music) -> ()
    let onOpenSongAtVkMusic: (Music) -> ()
    let onSendWarning: (Warning) -> ()
    
    init(onSongClick: @escaping (Int) -> Void, onScroll: @escaping (Int) -> Void, onDrawerClick: @escaping () -> Void, onOpenSettings: @escaping () -> Void, onBackClick: @escaping () -> Void, onPrevClick: @escaping () -> Void, onNextClick: @escaping () -> Void, onFavoriteToggle: @escaping () -> Void, onSaveSongText: @escaping (String) -> Void, onDeleteToTrashConfirmed: @escaping () -> Void, onShowToast: @escaping (String) -> Void, onOpenSongAtYandexMusic: @escaping (Music) -> Void, onOpenSongAtYoutubeMusic: @escaping (Music) -> Void, onOpenSongAtVkMusic: @escaping (Music) -> Void, onSendWarning: @escaping (Warning) -> Void) {
        self.onSongClick = onSongClick
        self.onScroll = onScroll
        self.onDrawerClick = onDrawerClick
        self.onOpenSettings = onOpenSettings
        self.onBackClick = onBackClick
        self.onPrevClick = onPrevClick
        self.onNextClick = onNextClick
        self.onFavoriteToggle = onFavoriteToggle
        self.onSaveSongText = onSaveSongText
        self.onDeleteToTrashConfirmed = onDeleteToTrashConfirmed
        self.onShowToast = onShowToast
        self.onOpenSongAtYandexMusic = onOpenSongAtYandexMusic
        self.onOpenSongAtYoutubeMusic = onOpenSongAtYoutubeMusic
        self.onOpenSongAtVkMusic = onOpenSongAtVkMusic
        self.onSendWarning = onSendWarning
    }
}
