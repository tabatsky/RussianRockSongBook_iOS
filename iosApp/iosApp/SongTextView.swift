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

    var body: some View {
        GeometryReader { geometry in
            let title = song.title
            
            VStack {
                Text(title)
                    .bold()
                    .padding(24)
                    .frame(maxWidth: geometry.size.width, alignment: .leading)
                
                ScrollView(.vertical) {
                    let text = song.text
                    Text(text)
                        .padding(8)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                }
            }
        }
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
}
