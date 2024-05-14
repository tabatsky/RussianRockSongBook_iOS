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
        self.kotlinStateMachine = KotlinStateMachine(
            showToast: showToast,
            openUrl: openUrl
        )
    }
    
    func performAction(changeState: @escaping (AppState) -> (), appState: AppState, action: AppUIAction) {
        if (kotlinStateMachine.canPerformAction(action: action)) {
            kotlinStateMachine.performAction(appState: appState, action: action, changeState: changeState)
            return
        }
    }
}

private func openUrl(_ urlString: String) {
    if let url = URL(string: urlString) {
        UIApplication.shared.open(url)
    }
}
