//
//  CloudSongTextView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 15.09.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct CloudSongTextView: View {
    let cloudSongTextComponent: CloudSongTextComponent?
    let theme: Theme
    let cloudState: CloudState
    let onPerformAction: (AppUIAction) -> ()
    
    private var itemsAdapter: CloudItemsAdapter {
        CloudItemsAdapter(items: cloudState.currentCloudSongList, searchState: cloudState.currentSearchState, searchFor: cloudState.searchForBackup, orderBy: cloudState.currentCloudOrderBy, onPerformAction: onPerformAction)
    }
    
    @State var currentChord: String? = nil
    @State var needShowWarningDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            if let cloudSong = self.cloudState.currentCloudSong {
                let artist = cloudSong.artist
                let title = cloudSong.visibleTitle
                
                let likeCount = Int(cloudSong.likeCount) + Int((self.cloudState.allLikes[cloudSong] ?? 0))
                let dislikeCount = Int(cloudSong.dislikeCount) + Int((self.cloudState.allDislikes[cloudSong] ?? 0))
                
                let visibleTitleWithArtistAndRaiting = "\(title) (\(artist)) 👍\(likeCount) 👎\(dislikeCount)"
                
                ZStack {
                    if (!UIDevice.current.orientation.isLandscape) {
                        VStack {
                            Text(visibleTitleWithArtistAndRaiting)
                                .font(self.theme.fontTitle)
                                .bold()
                                .foregroundColor(self.theme.colorMain)
                                .padding(24)
                                .frame(maxWidth: geometry.size.width, alignment: .leading)
                            ScrollViewReader { sp in
                                ScrollView(.vertical) {
                                    TheTextViewer(
                                        theme: self.theme,
                                        text: cloudSong.text,
                                        width: geometry.size.width,
                                        onChordTapped: onChordTapped,
                                        onHeightChanged: { height in })
                                }
                            }
                            HorizontalCloudSongTextPanel(
                                W: geometry.size.width,
                                theme: self.theme,
                                onOpenYandexMusic: onOpenYandexMusic,
                                onOpenYoutubeMusic: onOpenYoutubeMusuc,
                                onOpenVkMusic: onOpenVkMusuc,
                                onDownloadFromCloud: onDownloadFromCloud,
                                onShowWarning: onShowWarning,
                                onLike: onLike,
                                onDislike: onDislike
                            )
                        }
                    } else {
                        HStack {
                            VStack {
                                Text(visibleTitleWithArtistAndRaiting)
                                    .font(self.theme.fontTitle)
                                    .bold()
                                    .foregroundColor(self.theme.colorMain)
                                    .padding(24)
                                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                                GeometryReader { scrollViewGeometry in
                                    ScrollViewReader { sp in
                                        ScrollView(.vertical) {
                                            TheTextViewer(
                                                theme: self.theme,
                                                text: cloudSong.text,
                                                width: scrollViewGeometry.size.width,
                                                onChordTapped: onChordTapped,
                                                onHeightChanged: { height in })
                                        }
                                    }
                                }
                            }
                            VerticalCloudSongTextPanel(
                                H: geometry.size.height,
                                theme: self.theme,
                                onOpenYandexMusic: onOpenYandexMusic,
                                onOpenYoutubeMusic: onOpenYoutubeMusuc,
                                onOpenVkMusic: onOpenVkMusuc,
                                onDownloadFromCloud: onDownloadFromCloud,
                                onShowWarning: onShowWarning,
                                onLike: onLike,
                                onDislike: onDislike
                            )
                        }
                    }
                    if let chord = self.currentChord {
                        ChordViewer(theme: self.theme, chord: chord, onDismiss: {
                            self.currentChord = nil
                        })
                    }
                }
            } else {
                ZStack {}
            }
        }
        .background(self.theme.colorBg)
        .navigationBarItems(leading:
            Button(action: {
                Task.detached { @MainActor in
                    self.onPerformAction(BackClick())
                    self.cloudSongTextComponent?.onBackPressed()
                }
            }) {
                Image("ic_back")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
        }, trailing: HStack {
            Button(action: {
                Task.detached { @MainActor in
                    self.onPerformAction(CloudPrevClick())
                }
            }) {
                Image("ic_left")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
            let indexAndCount = "\(self.cloudState.currentCloudSongIndex + 1) / \(self.itemsAdapter.getCount())"
            Text(indexAndCount)
            Button(action: {
                Task.detached { @MainActor in
                    self.onPerformAction(CloudNextClick())
                    let cloudSong = self.itemsAdapter.getItem(position: Int(self.cloudState.currentCloudSongIndex))
                }
            }) {
                Image("ic_right")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColorAndFontSize(
            backgroundColor: self.theme.colorCommon,
            titleColor: colorBlack,
            fontSize: self.theme.fontSizeNavTitle
        )
        .customDialog(isShowing: self.$needShowWarningDialog, dialogContent: {
            WarningDialog(
                theme: self.theme, 
                onDismiss: {
                    self.needShowWarningDialog = false
                }, onSend: {
                    if ($0.isEmpty) {
                        self.onPerformAction(ShowToast(text: "Комментарий не должен быть пустым"))
                    } else {
                        self.needShowWarningDialog = false
                        let warning = self.cloudState.currentCloudSong!.warningWithComment(comment: $0)
                        self.onPerformAction(SendWarning(warning: warning))
                    }
                }
            )
        })
    }
    
    func onChordTapped(_ chord: String) {
        print("chord: \(chord)")
        self.currentChord = chord
    }
    
    func onOpenYandexMusic() {
        print("open yandex music")
        self.onPerformAction(OpenSongAtYandexMusic(music: self.cloudState.currentCloudSong!))
    }
    
    func onOpenYoutubeMusuc() {
        print("open youtube music")
        self.onPerformAction(OpenSongAtYoutubeMusic(music: self.cloudState.currentCloudSong!))
    }
    
    func onOpenVkMusuc() {
        print("open vk music")
        self.onPerformAction(OpenSongAtVkMusic(music: self.cloudState.currentCloudSong!))
    }
    
    func onDownloadFromCloud() {
        print("download from cloud")
        self.onPerformAction(DownloadClick(cloudSong: self.cloudState.currentCloudSong!))
    }
    
    func onShowWarning() {
        print("show warning")
        self.needShowWarningDialog = true
    }
    
    func onLike() {
        print("like")
        self.onPerformAction(LikeClick(cloudSong: self.cloudState.currentCloudSong!))
    }
    
    func onDislike() {
        print("dislike")
        self.onPerformAction(DislikeClick(cloudSong: self.cloudState.currentCloudSong!))
    }
}

struct HorizontalCloudSongTextPanel: View {
    let W: CGFloat
    let theme: Theme
    let onOpenYandexMusic: () -> ()
    let onOpenYoutubeMusic: () -> ()
    let onOpenVkMusic: () -> ()
    let onDownloadFromCloud: () -> ()
    let onShowWarning: () -> ()
    let onLike: () -> ()
    let onDislike: () -> ()
    
    var body: some View {
        let A = W / 7
        
        HStack(spacing: A / 5) {
            if (Preferences.loadListenToMusicVariant().isYandex()) {
                PanelButton(
                    theme: self.theme,
                    imgName: "ic_yandex",
                    buttonSize: A,
                    onClick: self.onOpenYandexMusic)
            }
            if (Preferences.loadListenToMusicVariant().isVk()) {
                PanelButton(
                    theme: self.theme,
                    imgName: "ic_vk",
                    buttonSize: A,
                    onClick: self.onOpenVkMusic)
            }
            if (Preferences.loadListenToMusicVariant().isYoutube()) {
                PanelButton(
                    theme: self.theme,
                    imgName: "ic_youtube",
                    buttonSize: A,
                    onClick: self.onOpenYoutubeMusic)
            }
            PanelButton(
                theme: self.theme,
                imgName: "ic_download",
                buttonSize: A,
                onClick: self.onDownloadFromCloud)
            PanelButton(
                theme: self.theme,
                imgName: "ic_warning",
                buttonSize: A,
                onClick: self.onShowWarning)
            PanelButton(
                theme: self.theme,
                imgName: "ic_like",
                buttonSize: A,
                onClick: self.onLike)
            PanelButton(
                theme: self.theme,
                imgName: "ic_dislike",
                buttonSize: A,
                onClick: self.onDislike)
        }
        .frame(width: W, height: A)
    }
}

struct VerticalCloudSongTextPanel: View {
    let H: CGFloat
    let theme: Theme
    let onOpenYandexMusic: () -> ()
    let onOpenYoutubeMusic: () -> ()
    let onOpenVkMusic: () -> ()
    let onDownloadFromCloud: () -> ()
    let onShowWarning: () -> ()
    let onLike: () -> ()
    let onDislike: () -> ()
    
    var body: some View {
        let A = H / 7
        
        VStack(spacing: A / 5) {
            if (Preferences.loadListenToMusicVariant().isYandex()) {
                PanelButton(
                    theme: self.theme,
                    imgName: "ic_yandex",
                    buttonSize: A,
                    onClick: self.onOpenYandexMusic)
            }
            if (Preferences.loadListenToMusicVariant().isVk()) {
                PanelButton(
                    theme: self.theme,
                    imgName: "ic_vk",
                    buttonSize: A,
                    onClick: self.onOpenVkMusic)
            }
            if (Preferences.loadListenToMusicVariant().isYoutube()) {
                PanelButton(
                    theme: self.theme,
                    imgName: "ic_youtube",
                    buttonSize: A,
                    onClick: self.onOpenYoutubeMusic)
            }
            PanelButton(
                theme: self.theme,
                imgName: "ic_download",
                buttonSize: A,
                onClick: self.onDownloadFromCloud)
            PanelButton(
                theme: self.theme,
                imgName: "ic_warning",
                buttonSize: A,
                onClick: self.onShowWarning)
            PanelButton(
                theme: self.theme,
                imgName: "ic_like",
                buttonSize: A,
                onClick: self.onLike)
            PanelButton(
                theme: self.theme,
                imgName: "ic_dislike",
                buttonSize: A,
                onClick: self.onDislike)
        }
        .frame(width: A, height: H)
    }
}
