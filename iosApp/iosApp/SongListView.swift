//
//  SongListView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct SongListView: View {
    let artist: String
    let songIndex: Int
    let onSongClick: (Int) -> ()
    let onDrawerClick: () -> ()
    
    @State var scrollPosition: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { sp in
                ScrollView(.vertical) {
                    let columns = [
                        GridItem(.flexible())
                    ]
                    let currentSongList = ContentView.songRepo.getSongsByArtist(artist: self.artist)
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(0..<currentSongList.count, id: \.self) { index in
                            let song = currentSongList[index]
                            let title = song.title
                            Text(title)
                                .id(song)
                                .foregroundColor(Theme.colorMain)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.colorBg)
                                .highPriorityGesture(
                                     TapGesture()
                                         .onEnded { _ in
                                             onSongClick(index)
                                         }
                                )
                                .onAppear(perform: {
                                    if (index < self.scrollPosition) {
                                        self.scrollPosition = index
                                    }
                                    print("appear: \(self.scrollPosition)")
                                })
                                .onDisappear(perform: {
                                    if (index >= self.scrollPosition) {
                                        self.scrollPosition = index + 1
                                    }
                                    print("disappear: \(self.scrollPosition)")
                                })
                            Rectangle()
                                .fill(Theme.colorCommon)
                                .frame(height: 3)
                                .edgesIgnoringSafeArea(.horizontal)
                        }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    }
                    .onAppear(perform: {
                        sp.scrollTo(currentSongList[songIndex], anchor: .top)
                    })
                    Spacer()
                }
                .background(Theme.colorBg)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDrawerClick()
                            }
                        }) {
                            Image("ic_drawer")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                        }
                        Text(self.artist)
                            .bold()
                    }
                })
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
            }
        }
    }
}
