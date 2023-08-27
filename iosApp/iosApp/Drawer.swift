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
    let isOpen: Bool
    let onArtistClick: (String) -> ()
    let onDismiss: () -> ()

    var body: some View {
        HStack {
            DrawerContent(onArtistClick: onArtistClick, onDismiss: onDismiss)
                .frame(width: self.width)
                .background(Theme.colorMain)
                .offset(x: self.isOpen ? 0 : -self.width)
                .animation(.default)
            Spacer()
        }
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
    }
}

struct DrawerContent: View {
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
                            .foregroundColor(Theme.colorBg)
                    }
                        .padding(16)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                        .background(Theme.colorCommon)
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(0..<artists.count, id: \.self) { index in
                            let artist = artists[index]
                            let isBold = ContentView.predefinedList.contains(artist)
                            Text(artist)
                                .font(Font.headline.weight(isBold ? .bold : .regular))
                                .foregroundColor(Theme.colorBg)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.colorMain)
                                .highPriorityGesture(
                                    TapGesture()
                                        .onEnded { _ in
                                            onArtistClick(artist)
                                        }
                                )
                            Rectangle()
                                .fill(Theme.colorCommon)
                                .frame(height: 3)
                                .edgesIgnoringSafeArea(.horizontal)
                        }.frame(maxWidth: .infinity, maxHeight: geometry.size.height)
                    }
                    Spacer()
                }
                .background(Theme.colorMain)
            }
        }
    }
}

