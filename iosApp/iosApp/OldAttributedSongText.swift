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
    let attributedText = NSMutableAttributedString(string: "")
    @State var textState: NSAttributedString = NSAttributedString(string: "")
    
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
                self.attributedText.append(s)
            }
            var actualWord = word.text
            ChordsKt.chordMappings.forEach { key, value in
                actualWord = actualWord.replacingOccurrences(of: key as! String, with: value as! String)
            }
            let url =  ChordsKt.baseChords.contains(actualWord) ? {
                NSURL(string: "https://tabatsky.ru/\(actualWord)")
            } : nil
            let a: [NSAttributedString.Key: Any]
            if (url == nil) {
                a = [.foregroundColor: UIColor(Theme.colorMain), .backgroundColor: UIColor(Theme.colorBg)]
            } else {
                a = [.foregroundColor: UIColor(Theme.colorBg), .backgroundColor: UIColor(Theme.colorMain), .link: url!]
            }
            let s = NSAttributedString(string: word.text, attributes: a)
            self.attributedText.append(s)
            position = Int(word.endIndex)
        }
        if (position < text.unicodeScalars.count) {
            let start = text.unicodeScalars.index(text.startIndex, offsetBy: position)
            let txt = String(text[start...])
            let a: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(Theme.colorMain), .backgroundColor: UIColor(Theme.colorBg)]
            let s = NSAttributedString(string: txt, attributes: a)
            self.attributedText.append(s)
        }
    }
    
    var body: some View {
        TextView(attributedText: self.$textState)
            .onAppear {
                self.textState = self.attributedText
            }
    }
}


struct TextView: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UITextView {
        let myTextView = CustomTextView()
        
        myTextView.delegate = context.coordinator
        
        myTextView.isEditable = false
        myTextView.isUserInteractionEnabled = true
        myTextView.dataDetectorTypes = []
        myTextView.delaysContentTouches = false
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
        
        
        uiView.isScrollEnabled = false
        
        uiView.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        uiView.backgroundColor = UIColor(Theme.colorBg)
    }
    
    class Coordinator : NSObject, UITextViewDelegate {

        override init() {
            super.init()
            print("coordinator init")
        }
        
        func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
            print("interact 4")
            return true
        }
        
        func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            print("interact 3")
            return true
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction:UITextItemInteraction) -> Bool {
            print("interact 1")
            return true
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
            print("interact 2")
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            print("did change")
        }
    }
}

class CustomTextView: UITextView {

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.hideMenu()
        //do not display the menu
        self.resignFirstResponder()
        return true
    }

}

