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
            Spacer()
            Text("Отправить уведомление")
                .foregroundColor(colorBlack)
                .padding([.leading], 20.0)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            TheTextEditor(
                theme: self.theme,
                invertTextColor: true,
                text: self.comment,
                width: 250.0,
                height: 180.0,
                onTextChanged: {
                    self.comment = $0
                })
            .background(self.theme.colorMain)
            .padding(10.0)
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.onSend(comment)
                }, label: {
                    Text("Отправить")
                        .foregroundColor(colorBlack)
                })
                Spacer()
                    .frame(width: 20.0)
                Button(action: {
                    self.onDismiss()
                }, label: {
                    Text("Отмена")
                        .foregroundColor(colorBlack)
                })
                Spacer()
                    .frame(width: 20.0)
            }
            .frame(height: 45.0)
            Spacer()
        }
        .frame(width: 270.0, height: 300.0)
        .background(self.theme.colorCommon)
    }
}
