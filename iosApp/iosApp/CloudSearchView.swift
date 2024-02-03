//
//  CloudSearchView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 11.09.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct CloudSearchView: View {
  
    let theme: Theme
    let cloudState: CloudState
    let cloudCallbacks: CloudCallbacks
    
    @State var currentSearchState: SearchState = .loading
    
    @State var searchFor: String = ""
    
    @State var scrollPosition: Int = 0
    @State var initialScrollDone: Bool = false
    @State var scrollViewFrame: CGRect = CGRect()
    
    init(theme: Theme, cloudState: CloudState, cloudCallbacks: CloudCallbacks) {
        self.theme = theme
        self.cloudState = cloudState
        self.cloudCallbacks = cloudCallbacks
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack {
                        TextField("", text: $searchFor)
                            .foregroundColor(self.theme.colorMain)
                            .frame(height: 56.0)
                            .background(Color.black)
                            .padding(8)
                            .background(self.theme.colorCommon)
                        Menu {
                            Button(OrderBy.byIdDesc.orderByRus) {
                                selectOrderBy(orderBy: OrderBy.byIdDesc)
                            }
                            Button(OrderBy.byTitle.orderByRus) {
                                selectOrderBy(orderBy: OrderBy.byTitle)
                            }
                            Button(OrderBy.byArtist.orderByRus) {
                                selectOrderBy(orderBy: OrderBy.byArtist)
                            }
                        } label: {
                            Text(self.cloudState.currentCloudOrderBy.orderByRus)
                        }
                            .foregroundColor(self.theme.colorMain)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36.0)
                            .background(self.theme.colorCommon)
                    }
                    Button(action: {
                        Task.detached { @MainActor in
                            searchSongs(searchFor: searchFor, orderBy: OrderBy.byIdDesc)
                        }
                    }) {
                        Image("ic_cloud_search_white")
                            .resizable()
                            .colorMultiply(self.theme.colorMain)
                            .padding(8)
                            .background(self.theme.colorCommon)
                            .padding([.top, .bottom, .trailing], 2)
                            .frame(width: 120.0, height: 120.0)
                    }
                }
                if (self.currentSearchState == .loading) {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: self.theme.colorMain))
                            .scaleEffect(5.0)
                        Spacer()
                    }
                    Spacer()
                } else if (self.currentSearchState == .emptyList) {
                    Text("Список пуст")
                        .foregroundColor(self.theme.colorMain)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if (self.currentSearchState == .loadSuccess) {
                    ScrollViewReader { sp in
                        ScrollView(.vertical) {
                            let columns = [
                                GridItem(.flexible())
                            ]
                            let currentList = self.cloudState.currentCloudSongList!
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach(0..<currentList.count, id: \.self) { index in
                                    let cloudSong = currentList[index]
                                    let title = cloudSong.visibleTitle
                                    let artist = cloudSong.artist
                                    let likeCount = Int(cloudSong.likeCount) + (self.cloudState.allLikes[cloudSong] ?? 0)
                                    let dislikeCount = Int(cloudSong.dislikeCount) + (self.cloudState.allDislikes[cloudSong] ?? 0)
                                    let visibleTitleWithRaiting = "\(title) 👍\(likeCount) 👎\(dislikeCount)"
                                    VStack {
                                        Text(visibleTitleWithRaiting)
                                            .font(self.theme.fontCommon)
                                            .foregroundColor(self.theme.colorMain)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(artist)
                                            .font(self.theme.fontCommon)
                                            .foregroundColor(self.theme.colorMain)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Rectangle()
                                            .fill(self.theme.colorCommon)
                                            .frame(height: 3)
                                            .edgesIgnoringSafeArea(.horizontal)
                                    }
                                        .id(cloudSong)
                                        .foregroundColor(self.theme.colorMain)
                                        .background(GeometryReader { itemGeom in
                                            self.theme.colorBg
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
                                        .background(self.theme.colorBg)
                                        .highPriorityGesture(
                                             TapGesture()
                                                 .onEnded { _ in
                                                     self.cloudCallbacks.onCloudSongClick(index)
                                                 }
                                        )
                                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                            }
                            .onAppear(perform: {
                                if (self.cloudState.currentCloudSongList != nil && !self.cloudState.currentCloudSongList!.isEmpty) {
                                    sp.scrollTo(self.cloudState.currentCloudSongList![self.cloudState.currentCloudSongIndex], anchor: .top)
                                }
                                Task.detached {
                                    try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                    await MainActor.run {
                                        self.initialScrollDone = true
                                    }
                                }
                            })
                            Spacer()
                        }
                        .background(GeometryReader { scrollViewGeom in
                            self.theme.colorBg
                                .preference(
                                    key: FrameKey.self,
                                    // See discussion!
                                    value: scrollViewGeom.frame(in: .global)
                                )
                                .onPreferenceChange(FrameKey.self) { frame in
                                    self.scrollViewFrame = frame
                                }
                        })
                        .onAppear(perform: {
                            self.searchFor = self.cloudState.searchForBackup
                        })
                        .onChange(of: self.scrollPosition, perform: { position in
                            //print("\(self.scrollPosition), \(position)")
                            //onScroll(position)
                        })
                    }
                }
            }
            .onAppear(perform: {
                if (self.cloudState.currentCloudSongList == nil) {
                    searchSongs(searchFor: "", orderBy: self.cloudState.currentCloudOrderBy)
                } else if (self.cloudState.currentCloudSongList!.isEmpty) {
                    self.currentSearchState = .emptyList
                } else {
                    self.currentSearchState = .loadSuccess
                }
            })
            .onChange(of: self.cloudState.currentCloudOrderBy, perform: { orderBy in
                searchSongs(searchFor: self.searchFor, orderBy: orderBy)
            })
        }
        .onDisappear {
            self.cloudCallbacks.onBackupSearchFor(self.searchFor)
        }
        .background(self.theme.colorBg)
        .navigationBarItems(leading:
                Button(action: {
                    Task.detached { @MainActor in
                        self.cloudCallbacks.onBackClick()
                    }
                }) {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }, trailing: Spacer())
        .navigationTitle(ContentView.ARTIST_CLOUD_SONGS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: self.theme.colorCommon, titleColor: colorBlack)
    }
    
    func searchSongs(searchFor: String, orderBy: OrderBy) {
        self.currentSearchState = SearchState.loading
        CloudRepository.shared.searchSongsAsync(
            searchFor: searchFor,
            orderBy: orderBy,
            onSuccess: { data in
                self.cloudCallbacks.onLoadSuccess(data)
                if (data.isEmpty) {
                   self.currentSearchState = .emptyList
               } else {
                   self.currentSearchState = .loadSuccess
               }
            },onError: { t in
                t.printStackTrace()
                self.currentSearchState = SearchState.loadError
            }
        )
    }
    
    func selectOrderBy(orderBy: OrderBy) {
        self.cloudCallbacks.onBackupSearchFor(self.searchFor)
        self.cloudCallbacks.onOrderBySelected(orderBy)
    }
}

enum SearchState {
    case loading
    case loadSuccess
    case loadError
    case emptyList
}

