//
//  TheTextEditor.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 16.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct TheTextEditor: View {
    let text: String
    let width: CGFloat
    let height: CGFloat
    let onTextChanged: (String) -> ()
    
    @State var editorText = ""
    @State var desiredHeight: CGFloat = 0.0
    @State var desiredWidth: CGFloat = 0.0
    
    init(text: String, width: CGFloat, height: CGFloat, onTextChanged: @escaping (String) -> ()) {
        self.text = text
        self.width = width
        self.height = height
        self.onTextChanged = onTextChanged
        
        if #unavailable(iOS 16) {
            UITextView.appearance().backgroundColor = .clear
        }
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            TextEditor(text: self.$editorText)
                .frame(width: self.width, height: self.height)
                .scrollDisabled(true)
                .scrollContentBackground(.hidden)
                .font(Theme.fontText)
                .foregroundColor(Theme.colorMain)
                .onAppear(perform: {
                    self.editorText = self.text
                })
                .onChange(of: self.text, perform: { txt in
                    self.editorText = txt
                })
                .onChange(of: self.editorText, perform: { txt in
                    self.onTextChanged(txt)
                })
        } else {
            TextViewForEditor(text: self.$editorText, desiredHeight: self.$desiredHeight, desiredWidth: self.$desiredWidth, onTextChanged: onTextChanged)
                .foregroundColor(Theme.colorMain)
                .onAppear(perform: {
                    self.editorText = self.text
                    self.desiredWidth = self.width
                    self.desiredHeight = self.height
                })
                .onChange(of: self.text, perform: { txt in
                    self.editorText = txt
                    self.desiredWidth = self.width
                    self.desiredHeight = self.height
                })
                .onChange(of: self.editorText, perform: { txt in
                    self.onTextChanged(txt)
                })
        }
    }
}

struct TextViewForEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var desiredHeight: CGFloat
    @Binding var desiredWidth: CGFloat
    
    let onTextChanged: (String) -> ()
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.owner = self
        return coordinator
    }
    
    func makeUIView(context: Context) -> UITextView {
        let myTextView = UITextView()
        
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
        
        uiView.isEditable = true
        uiView.isSelectable = true
        uiView.isUserInteractionEnabled = true
        uiView.isScrollEnabled = false
        
        uiView.text = text
        
        uiView.font = UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular)
        uiView.backgroundColor = UIColor(Theme.colorBg)
        uiView.textColor = UIColor(Theme.colorMain)
        
        uiView.invalidateIntrinsicContentSize()
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        var owner: TextViewForEditor! = nil
        
        override init() {
            super.init()
            print("coordinator init")
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if let text = textView.text {
                print("did change")
                owner.onTextChanged(text)
            }
        }
    }
}
