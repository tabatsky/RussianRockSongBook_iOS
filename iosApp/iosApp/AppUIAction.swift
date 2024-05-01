//
//  AppUIAction.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 06.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import shared

class ReloadSettings: AppUIAction {}

class LocalScroll: AppUIAction {
    let songIndex: Int
    
    init(songIndex: Int) {
        self.songIndex = songIndex
    }
}

class DrawerClick: AppUIAction {}
class BackClick: AppUIAction {}
class LocalPrevClick: AppUIAction {}
class LocalNextClick: AppUIAction {}
class FavoriteToggle: AppUIAction {
    let emptyListCallback: () -> ()
    
    init(emptyListCallback: @escaping () -> Void) {
        self.emptyListCallback = emptyListCallback
    }
}

class SaveSongText: AppUIAction {
    let newText: String
    
    init(newText: String) {
        self.newText = newText
    }
}

class ConfirmDeleteToTrash: AppUIAction {
    let emptyListCallback: () -> ()
    
    init(emptyListCallback: @escaping () -> Void) {
        self.emptyListCallback = emptyListCallback
    }
}
class UploadCurrentToCloud: AppUIAction {}

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

class SendWarning: AppUIAction {
    let warning: Warning
    
    init(warning: Warning) {
        self.warning = warning
    }
}

class CloudSearch: AppUIAction {
    let searchFor: String
    let orderBy: OrderBy
    
    init(searchFor: String, orderBy: OrderBy) {
        self.searchFor = searchFor
        self.orderBy = orderBy
    }
}

class CloudSongClick: AppUIAction {
    let index: Int
    
    init(index: Int) {
        self.index = index
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

class CloudPrevClick: AppUIAction {}
class CloudNextClick: AppUIAction {}

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
