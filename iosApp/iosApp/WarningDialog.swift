//
//  WarningDialog.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 05.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct WarningDialog: View {
    let onDismiss: () -> ()
    let onSend: (String) -> ()
    
    @State var comment = ""
    
    var body: some View {
        VStack(spacing: 0.0) {
            TheTextEditor(
                text: self.comment,
                width: 190.0,
                height: 190.0,
                onTextChanged: {
                    self.comment = $0
                })
            .background(Theme.colorBg)
            .padding(5.0)
            .background(Theme.colorCommon)
            Divider()
                .frame(height: 5.0)
                .background(Theme.colorBg)
            Button(action: {
                self.onSend(comment)
            }, label: {
                Text("Отправить")
                    .foregroundColor(Theme.colorBg)
                    .frame(height: 45.0)
            })
            Divider()
                .frame(height: 5.0)
                .background(Theme.colorBg)
            Button(action: {
                self.onDismiss()
            }, label: {
                Text("Отмена")
                    .foregroundColor(Theme.colorBg)
                    .frame(height: 45.0)
            })
        }
        .frame(width: 200.0, height: 300.0)
        .background(Theme.colorCommon)
    }
}
