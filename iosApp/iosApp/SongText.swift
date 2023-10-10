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
struct SongText {
    var attributedText: AttributedString
    
    init(text: String) {
        self.attributedText = AttributedString(text)
        let wordList = WordScanner(text: text).getWordList()
        wordList.forEach { word in
            var actualWord = word.text
            ChordsKt.chordMappings.forEach { key, value in
                actualWord = actualWord.replacingOccurrences(of: key as! String, with: value as! String)
            }
            if ChordsKt.baseChords.contains(actualWord) {
                let start = attributedText.characters.index(attributedText.startIndex, offsetBy: Int(word.startIndex))
                let end = attributedText.characters.index(attributedText.startIndex, offsetBy: Int(word.endIndex))
                self.attributedText[start..<end].foregroundColor = Theme.colorBg
                self.attributedText[start..<end].backgroundColor = Theme.colorMain
            }
        }
    }
}
