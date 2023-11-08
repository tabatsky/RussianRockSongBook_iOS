//
//  ChordViewer.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 13.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI


struct ChordViewer: View {
    let theme: Theme
    let chord: String
    let onDismiss: () -> ()
    
    var actualKey = ""
    var actualSuffix = ""
    
    let guitar = Instrument.guitar
    
    init(theme: Theme, chord: String, onDismiss: @escaping () -> Void) {
        self.theme = theme
        self.chord = chord
        self.onDismiss = onDismiss
        
        for index in guitar.keys.indices {
            let key = guitar.keys[index]
            if chord.starts(with: key) {
                self.actualKey = key
                let suffix = chord.replacingOccurrences(of: key, with: "")
                if suffix.isEmpty {
                    self.actualSuffix = "major"
                } else if suffix == "m" {
                    self.actualSuffix = "minor"
                } else if guitar.suffixes.contains(suffix) {
                    self.actualSuffix = suffix
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(self.chord)
                .foregroundColor(self.theme.colorBg)
                .frame(width: 320, height: 80)
                .background(self.theme.colorCommon)
            if !self.actualKey.isEmpty && !self.actualSuffix.isEmpty {
                let position = guitar.findChordPositions(key: self.actualKey, suffix: self.actualSuffix)[0]
                FretboardView(position: position)
                    .frame(width: 320, height: 320)
            } else {
                Spacer()
            }
            Button(action: {
                onDismiss()
            }, label: {
                Text("Закрыть")
                    .foregroundColor(self.theme.colorBg)
                    .frame(width: 320, height: 80)
                    .background(self.theme.colorCommon)
            })
        }
            .frame(width: 320, height: 480, alignment: .center)
            .background(self.theme.colorMain)
    }
}
