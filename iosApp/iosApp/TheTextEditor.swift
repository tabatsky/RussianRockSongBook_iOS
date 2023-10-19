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
    let onTextChanged: (String) -> ()
    
    @State var editorText = ""
    
    var body: some View {
        if #available(iOS 16, *) {
            TextEditor(text: self.$editorText)
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
            TextEditor(text: self.$editorText)
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
        }
    }
}
