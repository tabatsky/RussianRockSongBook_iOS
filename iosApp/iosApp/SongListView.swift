//
//  SongListView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct SongListView: View {
    let songListComponent: SongListComponent?
    let theme: Theme
    let localState: LocalState
    let onPerformAction: (AppUIAction) -> ()
    
    @State var scrollPosition: Int = -1
    @State var initialScrollDone: Bool = false
    @State var scrollViewFrame: CGRect = CGRect()
    

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { sp in
                ScrollView(.vertical) {
                    let columns = [
                        GridItem(.flexible())
                    ]
                    ContainerView {
                        if (!localState.currentSongList.isEmpty) {
                            LazyVGrid(columns: columns, spacing: 0) {
                                ForEach(0 ..< localState.currentSongList.count, id: \.self) { index in
                                    let song = localState.currentSongList[index]
                                    let title = song.title
                                    Text(title)
                                        .id(song)
                                        .font(self.theme.fontCommon)
                                        .foregroundColor(self.theme.colorMain)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
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
                                                    self.onPerformAction(SongClick(songIndex: Int32(index)))
                                                    self.songListComponent?.onSongClicked(position: Int32(index))
                                                }
                                        )
                                    Rectangle()
                                        .fill(self.theme.colorCommon)
                                        .frame(height: 3)
                                        .edgesIgnoringSafeArea(.horizontal)
                                }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                            }
                        } else {
                            Text("Список пуст")
                                .foregroundColor(self.theme.colorMain)
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        }
                    }
                    .onAppear(perform: {
                        self.scrollPosition = Int(localState.currentSongIndex)
                        if (!localState.currentSongList.isEmpty) {
                            sp.scrollTo(localState.currentSongList[Int(localState.currentSongIndex)], anchor: .top)
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
                .onChange(of: self.scrollPosition, perform: { [scrollPosition] position in
                    //print("\(self.scrollPosition), \(position)")
                    if (scrollPosition >= 0) {
                        self.onPerformAction(LocalScroll(songIndex: Int32(position)))
                    }
                })
                .navigationBarItems(leading:
                        Button(action: {
                            Task.detached { @MainActor in
                                self.onPerformAction(DrawerClick())
                            }
                        }) {
                            Image("ic_drawer")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                                .accessibilityLabel("drawerButton")
                        }, trailing: Spacer())
                .navigationTitle(
                    Text(self.localState.currentArtist)
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {
                    Task.detached { @MainActor in
                        openSettings()
                    }
                }) {
                    Image("ic_settings")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                })
                .navigationBarColorAndFontSize(
                    backgroundColor: self.theme.colorCommon,
                    titleColor: colorBlack,
                    fontSize: self.theme.fontSizeNavTitle
                )
            }
        }
    }
    
    func openSettings() {
        self.onPerformAction(OpenSettings())
        self.songListComponent?.onSettingsClicked()
    }
}

struct VisibleKey: PreferenceKey {
     static var defaultValue: Bool = false
     static func reduce(value: inout Bool, nextValue: () -> Bool) { }
}

struct FrameKey: PreferenceKey {
  static var defaultValue: CGRect = .zero

  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}
