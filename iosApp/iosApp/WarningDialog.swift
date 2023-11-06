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
    
    var body: some View {
        VStack {
            Text("Some content here")
            Spacer()
            Button(action: {
                self.onDismiss()
            }, label: {
                Text("Dismiss")
            })
        }
        .frame(width: 200.0, height: 200.0)
        .background(Theme.colorCommon)
    }
}
