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
    let onLoadSuccess: ([CloudSong]) -> ()
    let onCloudSongClick: (Int) -> ()
    let onOrderBySelected: (OrderBy) -> ()
    
    let currentCloudSongList: [CloudSong]?
    let currentCloudSongIndex: Int
    
    let orderBy: OrderBy
    
    @State var currentSearchState: SearchState = .loading
    
    @State var searchFor: String = ""
    
    @State var scrollPosition: Int = 0
    @State var initialScrollDone: Bool = false
    @State var scrollViewFrame: CGRect = CGRect()
    
    init(cloudSongList: [CloudSong]?, cloudSongIndex: Int, orderBy: OrderBy, onLoadSuccess: @escaping ([CloudSong]) -> (), onBackClick: @escaping () -> (), onCloudSongClick: @escaping (Int) -> (), onOrderBySelected: @escaping (OrderBy) -> ()) {
        self.currentCloudSongList = cloudSongList
        self.currentCloudSongIndex = cloudSongIndex
        self.orderBy = orderBy
        self.onLoadSuccess = onLoadSuccess
        self.onBackClick = onBackClick
        self.onCloudSongClick = onCloudSongClick
        self.onOrderBySelected = onOrderBySelected
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack {
                        TextField("", text: $searchFor)
                            .foregroundColor(Theme.colorMain)
                            .frame(height: 56.0)
                            .background(Color.black)
                            .padding(8)
                            .background(Theme.colorCommon)
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
                            Text(orderBy.orderByRus)
                        }
                            .foregroundColor(Theme.colorMain)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36.0)
                            .background(Theme.colorCommon)
                    }
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            searchSongs(searchFor: searchFor, orderBy: OrderBy.byIdDesc)
                        }
                    }) {
                        Image("ic_cloud_search_white")
                            .resizable()
                            .colorMultiply(Theme.colorMain)
                            .padding(8)
                            .background(Theme.colorCommon)
                            .frame(width: 120.0, height: 120.0)
                    }
                }
                if (self.currentSearchState == .loading) {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Theme.colorMain))
                            .scaleEffect(5.0)
                        Spacer()
                    }
                    Spacer()
                } else if (self.currentSearchState == .loadSuccess) {
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
                                            .foregroundColor(Theme.colorMain)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(artist)
                                            .foregroundColor(Theme.colorMain)
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
                                                     onCloudSongClick(index)
                                                 }
                                        )
                                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                            }
                            .onAppear(perform: {
                                if (self.currentCloudSongList != nil) {
                                    sp.scrollTo(self.currentCloudSongList![self.currentCloudSongIndex], anchor: .top)
                                }
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
                            //print("\(self.scrollPosition), \(position)")
                            //onScroll(position)
                        })
                    }
                }
            }
            .onAppear(perform: {
                if (self.currentCloudSongList == nil) {
                    searchSongs(searchFor: "", orderBy: self.orderBy)
                } else {
                    self.currentSearchState = .loadSuccess
                }
            })
            .onChange(of: self.currentCloudSongList, perform: { cloudSongList in
                if (cloudSongList == nil) {
                    searchSongs(searchFor: "", orderBy: self.orderBy)
                } else {
                    self.currentSearchState = .loadSuccess
                }
            })
            .onChange(of: self.orderBy, perform: { orderBy in
                searchSongs(searchFor: self.searchFor, orderBy: orderBy)
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
    
    func searchSongs(searchFor: String, orderBy: OrderBy) {
        self.currentSearchState = SearchState.loading
        CloudRepository.shared.searchSongsAsync(
            searchFor: searchFor,
            orderBy: orderBy,
            onSuccess: { data in
                self.onLoadSuccess(data)
            },onError: { t in
                t.printStackTrace()
                self.currentSearchState = SearchState.loadError
            }
        )
    }
    
    func selectOrderBy(orderBy: OrderBy) {
        onOrderBySelected(orderBy)
    }
}

enum SearchState {
    case loading
    case loadSuccess
    case loadError
}

