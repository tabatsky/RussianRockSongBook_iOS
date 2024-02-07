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
                invertTextColor: true,
                text: self.comment,
                width: 180.0,
                height: 180.0,
                onTextChanged: {
                    self.comment = $0
                })
            .background(self.theme.colorCommon)
            .padding(10.0)
            .background(self.theme.colorMain)
            Button(action: {
                self.onSend(comment)
            }, label: {
                Text("Отправить")
                    .foregroundColor(self.theme.colorMain)
                    .frame(width: 200.0, height: 45.0)
                    .background(self.theme.colorCommon)
            })
            Divider()
                .frame(height: 5.0)
                .background(self.theme.colorMain)
            Button(action: {
                self.onDismiss()
            }, label: {
                Text("Отмена")
                    .foregroundColor(self.theme.colorMain)
                    .frame(width: 200.0, height: 45.0)
                    .background(self.theme.colorCommon)
            })
            Divider()
                .frame(height: 5.0)
                .background(self.theme.colorMain)
        }
        .frame(width: 200.0, height: 300.0)
        .background(self.theme.colorMain)
    }
}
