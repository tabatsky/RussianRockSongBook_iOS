//
//  ContainerView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 10.10.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct ContainerView<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        content
    }
}
