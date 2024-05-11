//
//  PanelButton.swift
//  iosApp
//
//  Created by User on 11.05.2024.
//  Copyright © 2024 orgName. All rights reserved.
//

import SwiftUI

struct PanelButton: View {
    let theme: Theme
    let imgName: String
    let buttonSize: CGFloat
    let onClick: () -> ()
    
    var body: some View {
        Button(action: {
            Task.detached { @MainActor in
                self.onClick()
            }
        }) {
            Image(self.imgName)
                .resizable()
                .padding(self.buttonSize / 6)
                .background(self.theme.colorCommon)
                .frame(width: self.buttonSize, height: self.buttonSize)
        }
    }
}
