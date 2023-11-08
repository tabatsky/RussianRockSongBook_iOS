//
//  WarningDialog.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 05.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct WarningDialog: View {
    let theme: Theme
    let onDismiss: () -> ()
    let onSend: (String) -> ()
    
    @State var comment = ""
    
    var body: some View {
        VStack(spacing: 0.0) {
            TheTextEditor(
                theme: self.theme,
                text: self.comment,
                width: 190.0,
                height: 190.0,
                onTextChanged: {
                    self.comment = $0
                })
            .background(self.theme.colorBg)
            .padding(5.0)
            .background(self.theme.colorCommon)
            Divider()
                .frame(height: 5.0)
                .background(self.theme.colorBg)
            Button(action: {
                self.onSend(comment)
            }, label: {
                Text("Отправить")
                    .foregroundColor(self.theme.colorBg)
                    .frame(height: 45.0)
            })
            Divider()
                .frame(height: 5.0)
                .background(self.theme.colorBg)
            Button(action: {
                self.onDismiss()
            }, label: {
                Text("Отмена")
                    .foregroundColor(self.theme.colorBg)
                    .frame(height: 45.0)
            })
        }
        .frame(width: 200.0, height: 300.0)
        .background(self.theme.colorCommon)
    }
}
