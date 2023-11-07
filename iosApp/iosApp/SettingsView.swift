//
//  SettingsView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 07.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    let onBackClick: () -> ()
    
    var body: some View {
        VStack {
            Text("some settings here")
                .foregroundColor(Theme.colorMain)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.colorBg)
        .navigationBarItems(leading:
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onBackClick()
                    }
                }) {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }, trailing: Spacer())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
    }
}
