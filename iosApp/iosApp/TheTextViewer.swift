//
//  TheTextViewer.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 15.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct TheTextViewer: View {
    let theme: Theme
    let text: String
    let width: CGFloat
    let onChordTapped: (String) -> ()
    let onHeightChanged: (CGFloat) -> ()
    
    var body: some View {
        ContainerView {
            if #available(iOS 15, *) {
                let text = AttributedSongTextBuilder( theme: self.theme, text: self.text).attributedText
                Text(text)
                    .padding(8)
            } else {
                OldAttributedSongText(
                    theme: self.theme, 
                    text: self.text,
                    width: self.width,
                    onHeightChanged: { self.onHeightChanged($0) },
                    onChordTapped: onChordTapped
                )
            }
        }
        .font(self.theme.fontText)
        .foregroundColor(self.theme.colorMain)
        .frame(width: self.width, alignment: .leading)
        .background(
            GeometryReader { textGeometry in
                Color.clear
                    .onAppear(perform: {
                        self.onHeightChanged(textGeometry.size.height)
                    })
                    .onChange(of: self.text, perform: { text in
                        self.onHeightChanged(textGeometry.size.height)
                    })
            }
        )
        .onOpenURL(perform: {
            let chord = $0.absoluteString.replacingOccurrences(of: "jatx://", with: "")
            onChordTapped(chord)
        })
    }
}
