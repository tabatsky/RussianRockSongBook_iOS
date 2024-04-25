//
//  Drawer.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct NavigationDrawer: View {
    private let width = UIScreen.main.bounds.width - 100
    private let height = UIScreen.main.bounds.height
    let rootComponent: RootComponent?
    let theme: Theme
    let artists: [String]
    let isOpen: Bool
    let onPerformAction: (AppUIAction) -> ()

    var body: some View {
        HStack {
            DrawerContent(
                theme: self.theme,
                artists: self.artists,
                onArtistClick: { artist in
                    let callback = {
                        if (artist == AppStateMachine.ARTIST_CLOUD_SONGS) {
                            self.rootComponent?.onCloudSearchClicked()
                        }
                    }
                    self.onPerformAction(SelectArtist(artist: artist, callback: callback))
                },
                onDismiss: { self.onPerformAction(DrawerClick()) }
            )
                .frame(width: self.width)
                .background(self.theme.colorMain)
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.default)
            Spacer()
        }
        .navigationBarColor(backgroundColor: self.theme.colorCommon, titleColor: colorBlack)
    }
}

struct DrawerContent: View {
    let theme: Theme
    let artists: [String]
    let onArtistClick: (String) -> ()
    let onDismiss: () -> ()
    
    @State var expandedGroup = ""

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    let columns = [
                        GridItem(.flexible())
                    ]
                    HStack {
                        Button(action: {
                            Task.detached { @MainActor in
                                onDismiss()
                            }
                        }) {
                            Image("ic_drawer")
                                .resizable()
                                .frame(width: 32.0, height: 32.0)
                        }
                        Text("Меню")
                            .bold()
                            .foregroundColor(colorBlack)
                    }
                        .padding(16)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                        .background(self.theme.colorCommon)
                    LazyVGrid(columns: columns, spacing: 0) {
                        let predefinedWithGroups = self.artists.predefinedArtistsWithGroups()
                        ForEach(0..<predefinedWithGroups.count, id: \.self) { index in
                            let artistOrGroup = predefinedWithGroups[index]
                            let isPredefined = AppStateMachine.predefinedList.contains(artistOrGroup)
                            if (isPredefined) {
                                ArtistItem(artist: artistOrGroup, theme: self.theme, onArtistClick: onArtistClick)
                            } else {
                                let expandedList = self.expandedGroup == artistOrGroup
                                ? self.artists.filter { !AppStateMachine.predefinedList.contains($0) && $0.uppercased().starts(with: artistOrGroup) }
                                    : []
                                ArtistGroupItem(
                                    artistGroup: artistOrGroup,
                                    expandedList: expandedList,
                                    theme: self.theme,
                                    onGroupClick: {
                                        expandGroup(group: artistOrGroup)
                                    },
                                    onArtistClick: onArtistClick
                                )
                            }
                            
                        }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    }
                    Spacer()
                }
                .background(self.theme.colorMain)
            }
        }
    }
    
    func expandGroup(group: String) {
        self.expandedGroup = group
    }
}

struct ArtistItem: View {
    let artist: String
    let theme: Theme
    let onArtistClick: (String) -> ()
    
    var body: some View {
        let isBold = AppStateMachine.predefinedList.contains(artist)
        Text(self.artist)
            .font(self.theme.fontCommon.weight(isBold ? .bold : .regular))
            .foregroundColor(self.theme.colorBg)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(self.theme.colorMain)
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        self.onArtistClick(artist)
                    }
            )
        Rectangle()
            .fill(self.theme.colorCommon)
            .frame(height: 3)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct ArtistGroupItem: View {
    let artistGroup: String
    let expandedList: [String]
    let theme: Theme
    let onGroupClick: () -> ()
    let onArtistClick: (String) -> ()
    
    var body: some View {
        Text(self.artistGroup)
            .foregroundColor(self.theme.colorBg)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(self.theme.colorMain)
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        self.onGroupClick()
                    }
            )
        Rectangle()
            .fill(self.theme.colorCommon)
            .frame(height: 3)
            .edgesIgnoringSafeArea(.horizontal)
        ForEach(expandedList, id: \.self) { artist in
            ArtistItem(
                artist: artist,
                theme: self.theme,
                onArtistClick: self.onArtistClick
            )
        }
    }
}

extension [String] {
    func artistGroups() -> [String] {
        return self.filter {
            !AppStateMachine.predefinedList.contains($0)
        }.map {
            $0.artistGroup()
        }.unique().sorted()
    }
    
    func predefinedArtistsWithGroups() -> [String] {
        return AppStateMachine.predefinedList + self.artistGroups()
    }
}

extension String {
    func artistGroup() -> String {
        return self.prefix(1).uppercased()
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

