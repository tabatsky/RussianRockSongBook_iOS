//
//  Version.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 01.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation

struct Preferences {
    static let appVersion = 22
    
    static func appWasUpdated() -> Bool {
        let preferences = UserDefaults.standard
        let savedAppVersion = preferences.integer(forKey: "app_version")
        return appVersion > savedAppVersion
        
    }
    
    static func confirmAppUpdate() {
        let preferences = UserDefaults.standard
        preferences.set(appVersion, forKey: "app_version")
        didSave(preferences: preferences)
    }
    
    static func loadThemeVariant() -> ThemeVariant {
        let preferences = UserDefaults.standard
        let themeVariantValue = preferences.integer(forKey: "theme_variant")
        return ThemeVariant(rawValue: themeVariantValue)!
    }
    
    static func saveThemeVariant(themeVariant: ThemeVariant) {
        let preferences = UserDefaults.standard
        preferences.set(themeVariant.rawValue, forKey: "theme_variant")
        didSave(preferences: preferences)
    }
    
    static func loadFontScaleVariant() -> FontScaleVariant {
        let preferences = UserDefaults.standard
        let fontScaleVariantValue = preferences.integer(forKey: "font_scale_variant")
        return FontScaleVariant(rawValue: fontScaleVariantValue)!
    }
    
    static func saveFontScaleVariant(fontScaleVariant: FontScaleVariant) {
        let preferences = UserDefaults.standard
        preferences.set(fontScaleVariant.rawValue, forKey: "font_scale_variant")
        didSave(preferences: preferences)
    }
    
    static func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave {
            print("Preferences could not be saved!")
        }
    }
}
