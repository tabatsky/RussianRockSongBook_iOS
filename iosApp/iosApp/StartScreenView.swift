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
    let theme: Theme
    let onUpdateDone: () -> ()
    
    @State var progress = 0.0
    @State var progressStr = "0 из 0"
    
    var body: some View {
        VStack(spacing: 0) {
            Text("ПОДОЖДИТЕ…")
                .foregroundColor(theme.colorMain)
                .font(theme.fontTitle)
            Spacer()
                .frame(height: 30.0)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: self.theme.colorMain))
                .scaleEffect(x: 1, y: 4, anchor: .center)
                .padding([.leading, .trailing], 40.0)
            Spacer()
                .frame(height: 10.0)
            Text(self.progressStr)
                .foregroundColor(theme.colorMain)
                .font(theme.fontTitle)
            Spacer()
                .frame(height: 20.0)
            Text("Построение базы данных")
                .foregroundColor(theme.colorMain)
                .font(theme.fontCommon)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(self.theme.colorBg)
        .onAppear(perform: {
            let songRepo = ContentView.songRepo
            Task.detached {
                //try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                if Preferences.appWasUpdated() {
                    JsonLoaderKt.fillDbFromJSON(songRepo: songRepo, onProgressChanged: { done, total in
                        Task.detached { @MainActor in
                            self.progress = Double(truncating: done) / Double(truncating: total)
                            self.progressStr = "\(done) из \(total)"
                            print("\(done) of \(total)")
                        }
                    })
                    Preferences.confirmAppUpdate()
                }
                Task.detached { @MainActor in
                    onUpdateDone()
                }
            }
        })
    }
}
