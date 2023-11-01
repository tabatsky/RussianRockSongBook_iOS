//
//  Version.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 01.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation

struct Version {
    static let appVersion = 21
    
    static func appWasUpdated() -> Bool {
        let preferences = UserDefaults.standard
        if preferences.string(forKey: "app_version") != nil{
            let savedAppVersion = preferences.integer(forKey: "app_version")
            return appVersion > savedAppVersion
        } else {
            return true
        }
    }
    
    static func confirmAppUpdate() {
        let preferences = UserDefaults.standard
        preferences.set(appVersion, forKey: "app_version")
        didSave(preferences: preferences)
    }
    
    static func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave {
            print("Preferences could not be saved!")
        }
    }
}
