//
//  Chords.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 18.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation

struct AllChords {
    static let instance = AllChords()
    
    var allChords: [String] = []
    var chordMappings: [String:String] = [:]
    
    init() {
        chordMappings["H"] = "A"
        chordMappings["D#"] = "Eb"
        chordMappings["A#"] = "Bb"
        chordMappings["G#"] = "Ab"
        
        let guitar = Instrument.guitar
        guitar.keys.forEach { key in
            guitar.suffixes.forEach { suffix in
                let actualSuffix: String
                if (suffix == "major") {
                    actualSuffix = ""
                } else if (suffix == "minor") {
                    actualSuffix = "m"
                } else {
                    actualSuffix = suffix
                }
                let chord = "\(key)\(actualSuffix)"
                allChords.append(chord)
            }
        }
    }
}
