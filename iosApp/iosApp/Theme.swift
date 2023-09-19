//
//  Theme.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 21.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

let colorLightYellow = Color(hex: 0xFFFFBB)
let colorBlack = Color(hex: 0x000000)
let colorDarkYellow = Color(hex: 0x777755)

struct Theme {
    static let colorMain = colorLightYellow
    static let colorBg = colorBlack
    static let colorCommon = colorDarkYellow
    static let fontTitle = Font.system(size: 32)
    static let fontText = Font.system(size: 16, design: .monospaced)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

