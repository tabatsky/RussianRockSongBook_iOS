//
//  NavigationBar.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 21.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    
    var backgroundColor: UIColor?
    var titleColor: UIColor?
    
    init(backgroundColor: UIColor?, titleColor: UIColor?, fontSize: CGFloat) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [
            .foregroundColor: titleColor ?? .white,
            .font: UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)]
        coloredAppearance.largeTitleTextAttributes = [
            .foregroundColor: titleColor ?? .white,
            .font: UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold)]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
    
    func navigationBarColorAndFontSize(backgroundColor: Color, titleColor: Color, fontSize: CGFloat) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: UIColor(backgroundColor), titleColor: UIColor(titleColor), fontSize: fontSize))
    }
    
}
