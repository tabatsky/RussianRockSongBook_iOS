//
//  Drawer.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct NavigationDrawer: View {
    private let width = UIScreen.main.bounds.width - 100
    private let height = UIScreen.main.bounds.height
    let theme: Theme
    let isOpen: Bool
    let onArtistClick: (String) -> ()
    let onDismiss: () -> ()

    var body: some View {
        HStack {
            DrawerContent(theme: self.theme, onArtistClick: onArtistClick, onDismiss: onDismiss)
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
    let onArtistClick: (String) -> ()
    let onDismiss: () -> ()

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    let columns = [
                        GridItem(.flexible())
                    ]
                    let artists = ContentView.songRepo.getArtists()
                    HStack {
                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                        ForEach(0..<artists.count, id: \.self) { index in
                            let artist = artists[index]
                            let isBold = ContentView.predefinedList.contains(artist)
                            Text(artist)
                                .font(self.theme.fontCommon.weight(isBold ? .bold : .regular))
                                .foregroundColor(self.theme.colorBg)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(self.theme.colorMain)
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            onArtistClick(artist)
                                        }
                                )
                            Rectangle()
                                .fill(self.theme.colorCommon)
                                .frame(height: 3)
                                .edgesIgnoringSafeArea(.horizontal)
                        }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    }
                    Spacer()
                }
                .background(self.theme.colorMain)
            }
        }
    }
}

