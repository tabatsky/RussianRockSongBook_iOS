//
//  OldAttributedSongText.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 11.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import Foundation
import shared

struct OldAttributedSongText: View {
    let myAttributedString = NSMutableAttributedString(string: "")
    
    init(text: String) {
        let wordList = WordScanner(text: text).getWordList()
        var position = 0
        wordList.forEach { word in
            if (position < word.startIndex) {
                let start = text.unicodeScalars.index(text.startIndex, offsetBy: position)
                let end = text.unicodeScalars.index(text.startIndex, offsetBy: Int(word.startIndex))
                let txt = String(text[start..<end])
                let a: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(Theme.colorMain), .backgroundColor: UIColor(Theme.colorBg)]
                let s = NSAttributedString(string: txt, attributes: a)
                self.myAttributedString.append(s)
            }
            var actualWord = word.text
            ChordsKt.chordMappings.forEach { key, value in
                actualWord = actualWord.replacingOccurrences(of: key as! String, with: value as! String)
            }
            let url =  ChordsKt.baseChords.contains(actualWord) ? {
                URL(string: "jatx://\(actualWord)")
            } : nil
            let a: [NSAttributedString.Key: Any]
            if (url == nil) {
                a = [.foregroundColor: UIColor(Theme.colorBg), .backgroundColor: UIColor(Theme.colorMain)]
            } else {
                a = [.foregroundColor: UIColor(Theme.colorBg), .backgroundColor: UIColor(Theme.colorMain), .link: url!]
            }
            let s = NSAttributedString(string: word.text, attributes: a)
            self.myAttributedString.append(s)
            position = Int(word.endIndex)
        }
        if (position < text.unicodeScalars.count) {
            let start = text.unicodeScalars.index(text.startIndex, offsetBy: position)
            let txt = String(text[start...])
            let a: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(Theme.colorMain), .backgroundColor: UIColor(Theme.colorBg)]
            let s = NSAttributedString(string: txt, attributes: a)
            self.myAttributedString.append(s)
        }
    }
    
    var body: some View {
        UIKLabel {
            $0.attributedText = self.myAttributedString
            $0.lineBreakMode = .byWordWrapping
            $0.numberOfLines = 0
            $0.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        }
    }
}

struct UIKLabel: UIViewRepresentable {

    typealias TheUIView = UILabel
    fileprivate var configuration = { (view: TheUIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> TheUIView { TheUIView() }
    func updateUIView(_ uiView: TheUIView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}
