//
//  Version.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 01.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation

struct Preferences {
    static let appVersion = 35
    
    static func appWasUpdated() -> Bool {
        let preferences = UserDefaults.standard
        let savedAppVersion = preferences.integer(forKey: "app_version")
        print("version became: \(appVersion); was: \(savedAppVersion)")
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
    
    static func loadListenToMusicVariant() -> ListenToMusicVariant {
        let preferences = UserDefaults.standard
        let fontScaleVariantValue = preferences.integer(forKey: "listen_to_music_variant")
        return ListenToMusicVariant(rawValue: fontScaleVariantValue)!
    }
    
    static func saveListenToMusicVariant(listenToMusicVariant: ListenToMusicVariant) {
        let preferences = UserDefaults.standard
        preferences.set(listenToMusicVariant.rawValue, forKey: "listen_to_music_variant")
        didSave(preferences: preferences)
    }
    
    static func loadScrollSpeed() -> Float {
        let preferences = UserDefaults.standard
        let scrollSpeed = preferences.float(forKey: "scroll_speed")
        return scrollSpeed > 0 ? scrollSpeed : 1.0
    }
    
    static func saveScrollSpeed(scrollSpeed: Float) {
        let preferences = UserDefaults.standard
        preferences.set(scrollSpeed, forKey: "scroll_speed")
        didSave(preferences: preferences)
    }
    
    static func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave {
            print("Preferences could not be saved!")
        }
    }
}

enum ListenToMusicVariant: Int {
    case yandexAndYoutube = 0
    case yandexAndVk = 1
    case youtubeAndVk = 2
    
    func listenToMusicName() -> String {
        switch (self) {
        case .yandexAndYoutube:
            return "Яндекс и Youtube"
        case .yandexAndVk:
            return "Яндекс и VK"
        case .youtubeAndVk:
            return "VK и Youtube"
        }
    }
    
    func isYandex() -> Bool {
        return self == .yandexAndVk || self == .yandexAndYoutube
    }
    
    func isYoutube() -> Bool {
        return self == .youtubeAndVk || self == .yandexAndYoutube
    }
    
    func isVk() -> Bool {
        return self == .yandexAndVk || self == .youtubeAndVk
    }
}
