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
    let theme: Theme
    let attributedText = NSMutableAttributedString(string: "")
    let width: CGFloat
    let onHeightChanged: (CGFloat) -> ()
    let onChordTapped: (String) -> ()
    @State var textState: NSAttributedString = NSAttributedString(string: "")
    @State var textWidth = CGFloat(0.0)
    @State var textHeight = CGFloat(0.0)
    
    init(theme: Theme, text: String, width: CGFloat, onHeightChanged: @escaping (CGFloat) -> (), onChordTapped: @escaping (String) -> ()) {
        self.theme = theme
        self.width = width
        self.onHeightChanged = onHeightChanged
        self.onChordTapped = onChordTapped
        let wordList = WordScanner(text: text).getWordList()
        var position = 0
        let chordMappings = AllChords.instance.chordMappings
        let allChords = AllChords.instance.allChords
        wordList.forEach { word in
            if (position < word.startIndex) {
                let start = text.unicodeScalars.index(text.startIndex, offsetBy: position)
                let end = text.unicodeScalars.index(text.startIndex, offsetBy: Int(word.startIndex))
                let txt = String(text[start..<end])
                let a: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(theme.colorMain), .backgroundColor: UIColor(theme.colorBg)]
                let s = NSAttributedString(string: txt, attributes: a)
                self.attributedText.append(s)
            }
            var actualWord = word.text
            chordMappings.forEach { key, value in
                actualWord = actualWord.replacingOccurrences(of: key, with: value)
            }
            let chord =  allChords.contains(actualWord) ? actualWord : nil
            let a: [NSAttributedString.Key: Any]
            if (chord == nil) {
                a = [.foregroundColor: UIColor(theme.colorMain), .backgroundColor: UIColor(theme.colorBg)]
            } else {
                a = [.foregroundColor: UIColor(theme.colorBg), .backgroundColor: UIColor(theme.colorMain), NSAttributedString.Key(rawValue: "chord"): chord!]
            }
            let s = NSAttributedString(string: word.text, attributes: a)
            self.attributedText.append(s)
            position = Int(word.endIndex)
        }
        if (position < text.unicodeScalars.count) {
            let start = text.unicodeScalars.index(text.startIndex, offsetBy: position)
            let txt = String(text[start...])
            let a: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(theme.colorMain), .backgroundColor: UIColor(theme.colorBg)]
            let s = NSAttributedString(string: txt, attributes: a)
            self.attributedText.append(s)
        }
    }
    
    var body: some View {
        TextView(attributedText: self.$textState, desiredHeight: self.$textHeight, desiredWidth: self.$textWidth, theme: self.theme, onChordTapped: onChordTapped)
            .frame(width: max(self.textWidth, 1), height: max(self.textHeight, 1))
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
    let theme: Theme
    let onChordTapped: (String) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UITextView {
        let myTextView = CustomTextView()
        
        let tapGr = UITapGestureRecognizer(target: myTextView, action: nil)
        tapGr.delegate = myTextView
        myTextView.addGestureRecognizer(tapGr)
        
        myTextView.onChordTapped = onChordTapped
        
        myTextView.delegate = context.coordinator
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.frame = CGRect(x: 8, y: 0, width: self.desiredWidth - 16, height: self.desiredHeight)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.contentInset = .zero
        uiView.textContainerInset = .zero
        uiView.textContainer.lineFragmentPadding = 0
        uiView.textContainer.lineBreakMode = .byCharWrapping
        
        uiView.isEditable = false
        uiView.isSelectable = false
        uiView.isUserInteractionEnabled = true
        uiView.isScrollEnabled = false
        
        
        uiView.attributedText = attributedText
        
        uiView.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        uiView.backgroundColor = UIColor(self.theme.colorBg)
        
        uiView.invalidateIntrinsicContentSize()
        
        Task.detached { @MainActor in
            self.desiredHeight = uiView.intrinsicContentSize.height
        }
        
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
        
        if gesture.numberOfTapsRequired != 1 {
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
        let width = super.intrinsicContentSize.width// + self.textContainerInset.right + self.textContainerInset.left
        let height = super.intrinsicContentSize.height + self.textContainerInset.top + self.textContainerInset.bottom + 1000
        
        
        return CGSize(width: width, height: height)
    }
    
    
}
