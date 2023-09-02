//
//  SongTextView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct SongTextView: View {
    let song: Song
    let onBackClick: () -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    let onFavoriteToggle: () -> ()
    
    static let dY: CGFloat = 20.0
    
    @State var textHeight: CGFloat = 0.0
    @State var scrollY: CGFloat = 0.0
    @State var isAutoScroll = true
    @State var isScreenActive = true

    var body: some View {
        GeometryReader { geometry in
            let title = song.title
            
            VStack {
                Text(title)
                    .bold()
                    .foregroundColor(Theme.colorMain)
                    .padding(24)
                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                
                ScrollViewReader { sp in
                    ScrollView(.vertical) {
                        let text = song.text
                        Text(text)
                            .id("text")
                            .foregroundColor(Theme.colorMain)
                            .padding(8)
                            .frame(maxWidth: geometry.size.width, alignment: .leading)
                            .background(
                                GeometryReader { textGeometry in
                                    Color.clear
                                        .onAppear(perform: {
                                            self.textHeight = textGeometry.size.height
                                        })
                                        .onChange(of: self.song, perform: { song in
                                            self.textHeight = textGeometry.size.height
                                        })
                                }
                            )
                            .onAppear(perform: {
                                self.scrollY = 0.0
                                self.isAutoScroll = true
                                self.isScreenActive = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                    autoScroll(sp: sp)
                                })
                            })
                            .onDisappear(perform: {
                                self.isAutoScroll = false
                                self.isScreenActive = false
                            })
                            .onChange(of: self.song, perform: { song in
                                self.scrollY = 0.0
                            })
                    }
                }
            }
        }
        .background(Theme.colorBg)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onBackClick()
                    }
                }) {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onPrevClick()
                    }
                }) {
                    Image("ic_left")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onFavoriteToggle()
                    }
                }) {
                    if (song.favorite) {
                        Image("ic_delete")
                            .resizable()
                            .frame(width: 32.0, height: 32.0)
                    } else {
                        Image("ic_star")
                            .resizable()
                            .frame(width: 32.0, height: 32.0)
                    }
                }
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onNextClick()
                    }
                }) {
                    Image("ic_right")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
    }
    
    func autoScroll(sp: ScrollViewProxy) {
        if (self.isAutoScroll) {
            self.scrollY += Self.dY
            sp.scrollTo("text", anchor: UnitPoint(x: 0.0, y: self.scrollY / self.textHeight))
        }
        if (self.isScreenActive) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                autoScroll(sp: sp)
            })
        }
    }
}
