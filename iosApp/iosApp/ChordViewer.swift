//
//  ChordViewer.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 13.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI


struct ChordViewer: View {
    let chord: String
    let onDismiss: () -> ()
    
    var actualKey = ""
    var actualSuffix = ""
    
    let guitar = Instrument.guitar
    
    init(chord: String, onDismiss: @escaping () -> Void) {
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
                } else {
                    self.actualSuffix = suffix
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if !actualKey.isEmpty && !actualSuffix.isEmpty {
                let position = guitar.findChordPositions(key: actualKey, suffix: actualSuffix)[0]
                FretboardView(position: position)
                    .frame(width: 320, height: 320)
            } else {
                Spacer()
            }
            Button(action: {
                onDismiss()
            }, label: {
                Text("Close")
                    .foregroundColor(Theme.colorBg)
                    .frame(width: 320, height: 80)
                    .background(Theme.colorMain)
            })
        }
            .frame(width: 320, height: 400, alignment: .center)
            .background(Theme.colorMain)
    }
}
