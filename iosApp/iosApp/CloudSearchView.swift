//
//  CloudSearchView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 11.09.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct CloudSeaachView: View {
    let onBackClick: () -> ()
    
    @State var currentSearchState = SearchState.loading
    @State var currentCloudSongList: [CloudSong]? = nil
    
    @State var scrollPosition: Int = 0
    @State var initialScrollDone: Bool = false
    @State var scrollViewFrame: CGRect = CGRect()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if (self.currentSearchState == SearchState.loading) {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.colorMain))
                            .scaleEffect(5.0)
                        Spacer()
                    }
                    Spacer()
                } else if (self.currentSearchState == SearchState.loadSuccess) {
                    ScrollViewReader { sp in
                        ScrollView(.vertical) {
                            let columns = [
                                GridItem(.flexible())
                            ]
                            let currentList = self.currentCloudSongList!
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach(0..<currentList.count, id: \.self) { index in
                                    let cloudSong = currentList[index]
                                    let title = cloudSong.title
                                    let artist = cloudSong.artist
                                    VStack {
                                        Text(title)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(artist)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Rectangle()
                                            .fill(Theme.colorCommon)
                                            .frame(height: 3)
                                            .edgesIgnoringSafeArea(.horizontal)
                                    }
                                        .id(cloudSong)
                                        .foregroundColor(Theme.colorMain)
                                        .background(GeometryReader { itemGeom in
                                            Theme.colorBg
                                                .preference(
                                                    key: VisibleKey.self,
                                                    // See discussion!
                                                    value: self.scrollViewFrame.intersects(itemGeom.frame(in: .global))
                                                )
                                                .onPreferenceChange(VisibleKey.self) { isVisible in
                                                    if (self.initialScrollDone) {
                                                        if (isVisible) {
                                                            if (index < self.scrollPosition) {
                                                                self.scrollPosition = index
                                                            }
                                                        } else {
                                                            if (index >= self.scrollPosition && index < self.scrollPosition + 6) {
                                                                self.scrollPosition = index + 1
                                                            }
                                                        }
                                                    }
                                                }
                                        })
                                        .background(Theme.colorBg)
                                        .highPriorityGesture(
                                             TapGesture()
                                                 .onEnded { _ in
                                                     //onSongClick(index)
                                                 }
                                        )
                                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                            }
                            .onAppear(perform: {
                                //sp.scrollTo(currentSongList[songIndex], anchor: .top)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                    self.initialScrollDone = true
                                })
                            })
                            Spacer()
                        }
                        .background(GeometryReader { scrollViewGeom in
                            Theme.colorBg
                                .preference(
                                    key: FrameKey.self,
                                    // See discussion!
                                    value: scrollViewGeom.frame(in: .global)
                                )
                                .onPreferenceChange(FrameKey.self) { frame in
                                    self.scrollViewFrame = frame
                                }
                        })
                        .onChange(of: self.scrollPosition, perform: { position in
                            print("\(self.scrollPosition), \(position)")
                            //onScroll(position)
                        })
                    }
                }
            }
            .onAppear(perform: {
                CloudRepository.shared.test(onSuccess: { data in
                    print(data.count)
                    self.currentCloudSongList = data
                    self.currentSearchState = SearchState.loadSuccess
                },onError: { t in
                    t.printStackTrace()
                    self.currentSearchState = SearchState.loadError
                })
            })
        }
        .background(Theme.colorBg)
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onBackClick()
                    }
                }) {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }
                Text(ContentView.ARTIST_CLOUD_SONGS)
                    .bold()
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
    }
}

enum SearchState {
    case loading
    case loadSuccess
    case loadError
}

