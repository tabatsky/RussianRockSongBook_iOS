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
    let cloudSearchComponent: CloudSearchComponent?
    let theme: Theme
    let cloudState: CloudState
    let onPerformAction: (AppUIAction) -> ()
    
    @State var searchFor: String = ""
    
    @State var scrollPosition: Int = -1
    @State var initialScrollDone: Bool = false
    @State var scrollViewFrame: CGRect = CGRect()
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    VStack {
                        TextField("", text: $searchFor)
                            .foregroundColor(self.theme.colorBg)
                            .frame(height: 56.0)
                            .background(self.theme.colorMain)
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
                            cloudSearchClick()
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
                .frame(width: geometry.size.width, height: 120.0)

                ScrollViewReader { sp in
                    ScrollView(.vertical) {
                        ContainerView {
                            if (self.cloudState.currentSearchState == SearchState.loading) {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: self.theme.colorMain))
                                            .scaleEffect(5.0)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height - 120.0)
                            } else if (self.cloudState.currentSearchState == SearchState.emptyList) {
                                Text("Список пуст")
                                    .foregroundColor(self.theme.colorMain)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            } else if (self.cloudState.currentSearchState == SearchState.loadError) {
                                Text("Возникла ошибка")
                                    .foregroundColor(self.theme.colorMain)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            } else if (self.cloudState.currentSearchState == SearchState.loadSuccess) {
                                let columns = [
                                    GridItem(.flexible())
                                ]
                                let currentList = self.cloudState.currentCloudSongList ?? [CloudSong]()
                                LazyVGrid(columns: columns, spacing: 0) {
                                    ForEach(0 ..< currentList.count, id: \.self) { index in
                                        let cloudSong = currentList[index]
                                        let title = cloudSong.visibleTitle
                                        let artist = cloudSong.artist
                                        let likeCount = Int(cloudSong.likeCount) + Int(self.cloudState.allLikes[cloudSong] ?? 0)
                                        let dislikeCount = Int(cloudSong.dislikeCount) + Int(self.cloudState.allDislikes[cloudSong] ?? 0)
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
                                                        Task.detached {
                                                            try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                                            await MainActor.run {
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
                                                    }
                                                }
                                        })
                                        .background(self.theme.colorBg)
                                        .highPriorityGesture(
                                            TapGesture()
                                                .onEnded { _ in
                                                    self.onPerformAction(CloudSongClick(index: Int32(index)))
                                                    self.cloudSearchComponent?.onCloudSongClicked(position: Int32(index))
                                                }
                                        )
                                    }
                                }
                                .onAppear(perform: {
                                    print("\(self.cloudState.currentCloudSongIndex) \(self.scrollPosition)")
                                    if (self.cloudState.currentCloudSongList != nil && self.cloudState.currentCloudSongList!.count > self.cloudState.currentCloudSongIndex) {
                                        self.scrollPosition = Int(self.cloudState.currentCloudSongIndex)
                                        sp.scrollTo(self.cloudState.currentCloudSongList![Int(self.cloudState.currentCloudSongIndex)], anchor: .top)
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
                        }
                    }
                    .accessibilityLabel("cloudSongListScrollView")
                    .background(GeometryReader { scrollViewGeom in
                        self.theme.colorBg
                            .preference(
                                key: FrameKey.self,
                                // See discussion!
                                value: scrollViewGeom.frame(in: .global)
                            )
                            .onPreferenceChange(FrameKey.self) { frame in
                                Task.detached {
                                    try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                    await MainActor.run {
                                        self.scrollViewFrame = frame
                                    }
                                }
                            }
                    })
                    .onAppear(perform: {
                        self.searchFor = self.cloudState.searchForBackup
                    })
                    .onChange(of: self.scrollPosition, perform: { [scrollPosition] position in
                        print("\(scrollPosition), \(position)")
                        if (scrollPosition >= 0) {
                            self.onPerformAction(CloudScroll(index: Int32(position)))
                        }
                    })
                }
            }
            .onAppear(perform: {
                if (self.cloudState.currentCloudSongList == nil) {
                    self.onPerformAction(CloudSearch(searchFor: "", orderBy: self.cloudState.currentCloudOrderBy))
                }
            })
            .onChange(of: self.cloudState.currentCloudOrderBy, perform: { orderBy in
                self.onPerformAction(CloudSearch(searchFor: self.searchFor, orderBy: orderBy))
            })
        }
        .onDisappear {
            self.onPerformAction(BackupSearchFor(searchFor: self.searchFor))
        }
        .background(self.theme.colorBg)
        .navigationBarItems(leading:
                Button(action: {
                    Task.detached { @MainActor in
                        self.onPerformAction(BackClick())
                        self.cloudSearchComponent?.onBackPressed()
                    }
                }) {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }, trailing: Spacer())
        .navigationTitle(AppStateMachine.ARTIST_CLOUD_SONGS)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColorAndFontSize(
            backgroundColor: self.theme.colorCommon,
            titleColor: colorBlack,
            fontSize: self.theme.fontSizeNavTitle
        )
    }
    
    
    func cloudSearchClick() {
        self.onPerformAction(BackupSearchFor(searchFor: self.searchFor))
        self.onPerformAction(CloudSearch(searchFor: self.searchFor, orderBy: self.cloudState.currentCloudOrderBy))
    }
    
    func selectOrderBy(orderBy: OrderBy) {
        self.onPerformAction(BackupSearchFor(searchFor: self.searchFor))
        self.onPerformAction(SelectOrderBy(orderBy: orderBy))
    }
}
