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
    let cloudSong: CloudSong
    let cloudSongIndex: Int
    let cloudSongCount: Int
    let allLikes: Dictionary<CloudSong, Int>
    let allDislikes: Dictionary<CloudSong, Int>
    let onBackClick: () -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    let onPerformLike: (CloudSong) -> ()
    let onPerformDislike: (CloudSong) -> ()
    let onDownloadCurrent: (CloudSong) -> ()
    let onOpenSongAtYandexMusic: (Music) -> ()
    let onOpenSongAtYoutubeMusic: (Music) -> ()
    let onSendWarning: (Warning) -> ()
    let onShowToast: (String) -> ()
    
    @State var currentChord: String? = nil
    @State var needShowWarningDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            let artist = cloudSong.artist
            let title = cloudSong.visibleTitle
            
            let likeCount = Int(cloudSong.likeCount) + (self.allLikes[cloudSong] ?? 0)
            let dislikeCount = Int(cloudSong.dislikeCount) + (self.allDislikes[cloudSong] ?? 0)
            
            let visibleTitleWithArtistAndRaiting = "\(title) (\(artist)) 👍\(likeCount) 👎\(dislikeCount)"
            
            ZStack {
                VStack {
                    Text(visibleTitleWithArtistAndRaiting)
                        .font(Theme.fontTitle)
                        .bold()
                        .foregroundColor(Theme.colorMain)
                        .padding(24)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                    
                    GeometryReader { scrollViewGeometry in
                        ScrollViewReader { sp in
                            ScrollView(.vertical) {
                                TheTextViewer(
                                    text: cloudSong.text,
                                    width: geometry.size.width,
                                    onChordTapped: onChordTapped,
                                    onHeightChanged: { height in })
                            }
                        }
                    }
                    CloudSongTextPanel(
                        W: geometry.size.width,
                        onOpenYandexMusic: onOpenYandexMusic,
                        onOpenYoutubeMusic: onOpenYoutubeMusuc,
                        onDownloadFromCloud: onDownloadFromCloud,
                        onShowWarning: onShowWarning,
                        onLike: onLike,
                        onDislike: onDislike
                    )
                }
                if let chord = self.currentChord {
                    ChordViewer(chord: chord, onDismiss: {
                        self.currentChord = nil
                    })
                }
            }
        }
        .background(Theme.colorBg)
        .navigationBarItems(leading:
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onBackClick()
                }
            }) {
                Image("ic_back")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
        }, trailing: HStack {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onPrevClick()
                }
            }) {
                Image("ic_left")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
            let indexAndCount = "\(self.cloudSongIndex + 1) / \(self.cloudSongCount)"
            Text(indexAndCount)
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onNextClick()
                }
            }) {
                Image("ic_right")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
        .customDialog(isShowing: self.$needShowWarningDialog, dialogContent: {
            WarningDialog(
                onDismiss: {
                    self.needShowWarningDialog = false
                }, onSend: {
                    if ($0.isEmpty) {
                        self.onShowToast("Комментарий не должен быть пустым")
                    } else {
                        self.needShowWarningDialog = false
                        let warning = self.cloudSong.warningWithComment(comment: $0)
                        self.onSendWarning(warning)
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
        self.onOpenSongAtYandexMusic(self.cloudSong)
    }
    
    func onOpenYoutubeMusuc() {
        print("open youtube music")
        self.onOpenSongAtYoutubeMusic(self.cloudSong)
    }
    
    func onDownloadFromCloud() {
        print("download from cloud")
        self.onDownloadCurrent(self.cloudSong)
    }
    
    func onShowWarning() {
        print("show warning")
        self.needShowWarningDialog = true
    }
    
    func onLike() {
        print("like")
        self.onPerformLike(self.cloudSong)
    }
    
    func onDislike() {
        print("dislike")
        self.onPerformDislike(self.cloudSong)
    }
}

struct CloudSongTextPanel: View {
    let W: CGFloat
    let onOpenYandexMusic: () -> ()
    let onOpenYoutubeMusic: () -> ()
    let onDownloadFromCloud: () -> ()
    let onShowWarning: () -> ()
    let onLike: () -> ()
    let onDislike: () -> ()
    
    var body: some View {
        let A = W / 7
        
        HStack(spacing: A / 5) {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onOpenYandexMusic()
                }
            }) {
                Image("ic_yandex")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onOpenYoutubeMusic()
                }
            }) {
                Image("ic_youtube")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onDownloadFromCloud()
                }
            }) {
                Image("ic_download")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onShowWarning()
                }
            }) {
                Image("ic_warning")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onLike()
                }
            }) {
                Image("ic_like")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onDislike()
                }
            }) {
                Image("ic_dislike")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
        }
        .frame(width: W, height: A)
    }
}
