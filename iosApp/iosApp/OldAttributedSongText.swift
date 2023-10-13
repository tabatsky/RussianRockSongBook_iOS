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
    let width: CGFloat
    let onHeightChanged: (CGFloat) -> ()
    @State var textState: NSAttributedString = NSAttributedString(string: "")
    @State var textWidth = CGFloat(0.0)
    @State var textHeight = CGFloat(0.0)
    
    init(text: String, width: CGFloat, onHeightChanged: @escaping (CGFloat) -> ()) {
        self.width = width
        self.onHeightChanged = onHeightChanged
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
            let url =  ChordsKt.baseChords.contains(actualWord) ? "https://tabatsky.ru/\(actualWord)" : nil
            let a: [NSAttributedString.Key: Any]
            if (url == nil) {
                a = [.foregroundColor: UIColor(Theme.colorMain), .backgroundColor: UIColor(Theme.colorBg)]
            } else {
                a = [.foregroundColor: UIColor(Theme.colorBg), .backgroundColor: UIColor(Theme.colorMain), NSAttributedString.Key(rawValue: "chord"): url!]
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
        TextView(attributedText: self.$textState, desiredHeight: self.$textHeight, desiredWidth: self.$textWidth)
            .frame(width: max(self.textWidth, 100), height: max(self.textHeight, 100))
            .onAppear {
                self.textState = self.attributedText
                self.textWidth = self.width
            }
            .onChange(of: self.attributedText, perform: { attributedText in
                self.textState = attributedText
                self.textWidth = self.width
            })
            .onChange(of: self.textHeight, perform: { height in
                self.onHeightChanged(height)
            })
    }
}


struct TextView: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var desiredHeight: CGFloat
    @Binding var desiredWidth: CGFloat
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UITextView {
        let myTextView = CustomTextView()
        
        myTextView.delegate = context.coordinator
        myTextView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        myTextView.contentInset = .zero
        myTextView.textContainer.lineFragmentPadding = 0
        myTextView.textContainer.lineBreakMode = .byCharWrapping
        
        
        
        //myTextView.delegate = context.coordinator
        
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.frame = CGRect(x: 0, y: 0, width: self.desiredWidth, height: self.desiredHeight)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.setContentHuggingPriority(.required, for: .vertical)
        uiView.contentInset = .zero
        //uiView.textContainerInset = .zero
        uiView.textContainer.lineFragmentPadding = 0
        uiView.textContainer.lineBreakMode = .byCharWrapping
        
        uiView.isEditable = false
        uiView.isSelectable = false
        uiView.isUserInteractionEnabled = true
        uiView.isScrollEnabled = false
        
        
        uiView.attributedText = attributedText
        
        uiView.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        uiView.backgroundColor = UIColor(Theme.colorBg)
        
        uiView.invalidateIntrinsicContentSize()
        
        DispatchQueue.main.async {
            self.desiredHeight = uiView.intrinsicContentSize.height
        }
        
        let tapGr = UITapGestureRecognizer(target: uiView, action: nil)
        tapGr.delegate = uiView as! CustomTextView
        uiView.addGestureRecognizer(tapGr)
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        override init() {
            super.init()
            print("coordinator init")
        }
        
        func textViewDidChange(_ textView: UITextView) {
            print("did change")
        }
    }
}


class CustomTextView: UITextView, UIGestureRecognizerDelegate {

    var onChordTapped: (String) -> () = { print("chord: \($0)") }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UITapGestureRecognizer else {
            return true
        }

        let location = gesture.location(in: self)

        guard let closest = closestPosition(to: location), let startPosition = position(from: closest, offset: -1), let endPosition = position(from: closest, offset: 1) else {
            return false
        }
        
        guard let textRange = textRange(from: startPosition, to: endPosition) else {
            return false
        }

        let startOffset = offset(from: beginningOfDocument, to: textRange.start)
        let endOffset = offset(from: beginningOfDocument, to: textRange.end)
        let range = NSRange(location: startOffset, length: endOffset - startOffset)

        guard range.location != NSNotFound, range.length != 0 else {
            return false
        }
        
        guard let chordAttribute = attributedText.attributedSubstring(from: range).attribute(NSAttributedString.Key(rawValue: "chord"), at: 0, effectiveRange: nil) else {
            return false
        }

        guard let chord = chordAttribute as? String else {
            return false
        }

        onChordTapped(chord)

        return true
    }
    
    override var intrinsicContentSize: CGSize {
        var newTextViewFrame = self.frame
        newTextViewFrame.size.width = super.intrinsicContentSize.width// + self.textContainerInset.right + self.textContainerInset.left
        newTextViewFrame.size.height = super.intrinsicContentSize.height + self.textContainerInset.top + self.textContainerInset.bottom + 100
        //self.frame = newTextViewFrame
        //print(newTextViewFrame)
        
        return newTextViewFrame.size
    }
    
    
}
