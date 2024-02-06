//
//  AppCallbacks.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 02.02.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import Foundation
import shared

struct CloudCallbacks {
    let onBackClick: () -> ()
    let onLoadSuccess: ([CloudSong]) -> ()
    let onCloudSongClick: (Int) -> ()
    let onOrderBySelected: (OrderBy) -> ()
    let onBackupSearchFor: (String) -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    let onPerformLike: (CloudSong) -> ()
    let onPerformDislike: (CloudSong) -> ()
    let onDownloadCurrent: (CloudSong) -> ()
    let onOpenSongAtYandexMusic: (Music) -> ()
    let onOpenSongAtYoutubeMusic: (Music) -> ()
    let onOpenSongAtVkMusic: (Music) -> ()
    let onSendWarning: (Warning) -> ()
    let onShowToast: (String) -> ()
}
