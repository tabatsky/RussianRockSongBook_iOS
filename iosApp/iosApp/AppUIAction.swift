//
//  AppUIAction.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 06.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import shared

class ShowToast: AppUIAction {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

class OpenSongAtVkMusic: AppUIAction {
    let music: Music
    
    init(music: Music) {
        self.music = music
    }
}

class OpenSongAtYandexMusic: AppUIAction {
    let music: Music
    
    init(music: Music) {
        self.music = music
    }
}

class OpenSongAtYoutubeMusic: AppUIAction {
    let music: Music
    
    init(music: Music) {
        self.music = music
    }
}

class SelectOrderBy: AppUIAction {
    let orderBy: OrderBy
    
    init(orderBy: OrderBy) {
        self.orderBy = orderBy
    }
}

class BackupSearchFor: AppUIAction {
    let searchFor: String
    
    init(searchFor: String) {
        self.searchFor = searchFor
    }
}


class LikeClick: AppUIAction {
    let cloudSong: CloudSong
    
    init(cloudSong: CloudSong) {
        self.cloudSong = cloudSong
    }
}

class DislikeClick: AppUIAction {
    let cloudSong: CloudSong
    
    init(cloudSong: CloudSong) {
        self.cloudSong = cloudSong
    }
}

class DownloadClick: AppUIAction {
    let cloudSong: CloudSong
    
    init(cloudSong: CloudSong) {
        self.cloudSong = cloudSong
    }
}

class UpdateDone: AppUIAction {}
