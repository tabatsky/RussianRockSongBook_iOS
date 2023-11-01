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
    let onBackClick: () -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    
    @State var currentChord: String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            let artist = cloudSong.artist
            let title = cloudSong.title
            
            let visibleTitleWithArtist = "\(title) (\(artist))"
            
            ZStack {
                VStack {
                    Text(visibleTitleWithArtist)
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
    }
    
    func onChordTapped(_ chord: String) {
        print("chord: \(chord)")
        self.currentChord = chord
    }
    
    func onOpenYandexMusic() {
        print("open yandex music")
    }
    
    func onOpenYoutubeMusuc() {
        print("open youtube music")
    }
    
    func onDownloadFromCloud() {
        print("download from cloud")
    }
    
    func onShowWarning() {
        print("show warning")
    }
    
    func onLike() {
        print("like")
    }
    
    func onDislike() {
        print("dislike")
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
