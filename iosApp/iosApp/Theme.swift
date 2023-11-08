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

protocol Theme {
    var colorMain: Color { get }
    var colorBg: Color { get }
    var colorCommon: Color { get }
    var fontTitle: Font { get }
    var fontText: Font { get }
    var fontCommon: Font { get }
}

struct DarkTheme: Theme {
    let colorMain = colorLightYellow
    let colorBg = colorBlack
    let colorCommon = colorDarkYellow
    let fontTitle = Font.system(size: 32)
    let fontText = Font.system(size: 16, design: .monospaced)
    let fontCommon = Font.system(size: 16)
}

struct LightTheme: Theme {
    let colorMain = colorBlack
    let colorBg = colorLightYellow
    let colorCommon = colorDarkYellow
    let fontTitle = Font.system(size: 32)
    let fontText = Font.system(size: 16, design: .monospaced)
    let fontCommon = Font.system(size: 16)
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

enum ThemeVariant: Int {
    case dark = 0
    case light = 1
    
    func themeName() -> String {
        if (self == .dark) {
            return "Темная"
        } else {
            return "Светлая"
        }
    }
    
    func theme() -> Theme {
        if (self == .dark) {
            return DarkTheme()
        } else {
            return LightTheme()
        }
    }
}

enum FontScaleVariant: Int {
    case xs = -2
    case s = -1
    case m = 0
    case l = 1
    case xl = 2
    
    func fontScaleName() -> String {
        switch(self) {
        case .xs:
            return "Очень мелкий"
        case .s:
            return "Мелкий"
        case .m:
            return "Обычный"
        case .l:
            return "Крупный"
        case .xl:
            return "Очень крупный"
        }
    }
}
