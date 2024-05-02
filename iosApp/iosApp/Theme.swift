//
//  Theme.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 21.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

let colorLightYellow = Color(hex: 0xFFFFBB)
let colorBlack = Color(hex: 0x000000)
let colorDarkYellow = Color(hex: 0x777755)

protocol Theme {
    var colorMain: Color { get }
    var colorBg: Color { get }
    var colorCommon: Color { get }
    var fontTitle: Font { get }
    var fontSizeNavTitle: CGFloat { get }
    var fontText: Font { get }
    var fontCommon: Font { get }
}

struct DarkTheme: Theme {
    let fontScale: CGFloat
    let colorMain = colorLightYellow
    let colorBg = colorBlack
    let colorCommon = colorDarkYellow
    var fontTitle: Font {
        Font.system(size: 32 * fontScale)
    }
    var fontSizeNavTitle: CGFloat {
        20 * fontScale
    }
    var fontText: Font {
        Font.system(size: 20 * fontScale, design: .monospaced)
    }
    var fontCommon: Font {
        Font.system(size: 20 * fontScale)
    }
}

struct LightTheme: Theme {
    let fontScale: CGFloat
    let colorMain = colorBlack
    let colorBg = colorLightYellow
    let colorCommon = colorDarkYellow
    var fontTitle: Font {
        Font.system(size: 32 * fontScale)
    }
    var fontSizeNavTitle: CGFloat {
        20 * fontScale
    }
    var fontText: Font {
        Font.system(size: 20 * fontScale, design: .monospaced)
    }
    var fontCommon: Font {
        Font.system(size: 20 * fontScale)
    }
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

extension ThemeVariant {
    func themeName() -> String {
        if (self == .dark) {
            return "Темная"
        } else {
            return "Светлая"
        }
    }
    
    func theme(fontScale: CGFloat) -> Theme {
        if (self == .dark) {
            return DarkTheme(fontScale: fontScale)
        } else {
            return LightTheme(fontScale: fontScale)
        }
    }
}

extension FontScaleVariant {
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
        default:
            return ""
        }
    }
    
    func fontScale() -> CGFloat {
        switch(self) {
        case .xs:
            return 0.5
        case .s:
            return 0.75
        case .m:
            return 1.0
        case .l:
            return 1.5
        case .xl:
            return 2.0
        default:
            return 1.0
        }
    }
}
