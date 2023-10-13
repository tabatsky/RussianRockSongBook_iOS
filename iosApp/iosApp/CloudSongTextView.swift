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
    
    var body: some View {
        GeometryReader { geometry in
            let artist = cloudSong.artist
            let title = cloudSong.title
            
            let visibleTitleWithArtist = "\(title) (\(artist))"
            
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
                            ContainerView {
                                if #available(iOS 15, *) {
                                    let text = AttributedSongTextMaker(text: cloudSong.text).attributedText
                                    Text(text)
                                } else {
                                    OldAttributedSongText(
                                        text: cloudSong.text,
                                        width: geometry.size.width,
                                        onHeightChanged: { print($0) },
                                        onChordTapped: onChordTapped
                                    )
                                }
                            }
                                .id("text")
                                .font(Theme.fontText)
                                .foregroundColor(Theme.colorMain)
                                .padding(8)
                                .frame(maxWidth: geometry.size.width, alignment: .leading)
                                .onOpenURL(perform: {
                                    let chord = $0.absoluteString.replacingOccurrences(of: "jatx://", with: "")
                                    onChordTapped(chord)
                                })
                        }
                    }
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
    }
}

