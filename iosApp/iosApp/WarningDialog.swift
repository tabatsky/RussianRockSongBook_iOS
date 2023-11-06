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
        VStack {
            TheTextEditor(
                text: self.comment,
                width: 190.0,
                height: 180.0,
                onTextChanged: {
                    self.comment = $0
                })
            .background(Theme.colorBg)
            .padding(5.0)
            Spacer()
            Button(action: {
                self.onSend(comment)
            }, label: {
                Text("Отправить")
                    .foregroundColor(Theme.colorBg)
            })
            .padding(10.0)
            Button(action: {
                self.onDismiss()
            }, label: {
                Text("Отмена")
                    .foregroundColor(Theme.colorBg)
            })
            .padding(10.0)
        }
        .frame(width: 200.0, height: 290.0)
        .background(Theme.colorCommon)
    }
}
