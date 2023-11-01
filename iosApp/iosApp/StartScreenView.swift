//
//  StartScreen.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 01.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct StartScreenView: View {
    let onUpdateDone: () -> ()
    
    @State var progress = 0.0
    
    var body: some View {
        ZStack {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Theme.colorMain))
                .scaleEffect(x: 1, y: 4, anchor: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.colorBg)
        .onAppear(perform: {
            let songRepo = ContentView.songRepo
            let concurrentQueue = DispatchQueue(label: "fill_db_queue", attributes: .concurrent)
            concurrentQueue.asyncAfter(deadline: .now() + 0.2) {
                if Version.appWasUpdated() {
                    JsonLoaderKt.fillDbFromJSON(songRepo: songRepo, onProgressChanged: { done, total in
                        DispatchQueue.main.async {
                            self.progress = Double(truncating: done) / Double(truncating: total)
                        }
                    })
                    Version.confirmAppUpdate()
                }
                DispatchQueue.main.async {
                    onUpdateDone()
                }
            }
        })
    }
}
