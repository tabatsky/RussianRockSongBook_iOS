//
//  CustomTextView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 10.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

@available(iOS 15, *)
struct AttributedSongTextBuilder {
    var attributedText: AttributedString
    
    init(text: String) {
        self.attributedText = AttributedString(text)
        let wordList = WordScanner(text: text).getWordList()
        let chordMappings = AllChords.instance.chordMappings
        let allChords = AllChords.instance.allChords
        wordList.forEach { word in
            var actualWord = word.text
            chordMappings.forEach { key, value in
                actualWord = actualWord.replacingOccurrences(of: key, with: value)
            }
            if allChords.contains(actualWord) {
                let start = attributedText.unicodeScalars.index(attributedText.startIndex, offsetBy: Int(word.startIndex))
                let end = attributedText.unicodeScalars.index(attributedText.startIndex, offsetBy: Int(word.endIndex))
                self.attributedText[start..<end].foregroundColor = Theme.colorBg
                self.attributedText[start..<end].backgroundColor = Theme.colorMain
                self.attributedText[start..<end].link = URL(string: "jatx://\(actualWord)")
            }
        }
    }
}
