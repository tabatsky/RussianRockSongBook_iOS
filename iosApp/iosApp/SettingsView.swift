//
//  SettingsView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 07.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    let theme: Theme
    let onBackClick: () -> ()
    let onReloadSettings: () -> ()
    
    @State var themeVariant = Preferences.loadThemeVariant()
    @State var fontScaleVariant = Preferences.loadFontScaleVariant()
    
    var body: some View {
        VStack {
            Menu {
                Button(ThemeVariant.dark.themeName()) {
                    self.themeVariant = ThemeVariant.dark
                }
                Button(ThemeVariant.light.themeName()) {
                    self.themeVariant = ThemeVariant.light
                }
            } label: {
                Text(self.themeVariant.themeName())
            }
                .foregroundColor(colorBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 36.0)
                .background(self.theme.colorCommon)
            Menu {
                Button(FontScaleVariant.xs.fontScaleName()) {
                    self.fontScaleVariant = FontScaleVariant.xs
                }
                Button(FontScaleVariant.s.fontScaleName()) {
                    self.fontScaleVariant = FontScaleVariant.s
                }
                Button(FontScaleVariant.m.fontScaleName()) {
                    self.fontScaleVariant = FontScaleVariant.m
                }
                Button(FontScaleVariant.l.fontScaleName()) {
                    self.fontScaleVariant = FontScaleVariant.l
                }
                Button(FontScaleVariant.xl.fontScaleName()) {
                    self.fontScaleVariant = FontScaleVariant.xl
                }
            } label: {
                Text(self.fontScaleVariant.fontScaleName())
            }
                .foregroundColor(colorBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 36.0)
                .background(self.theme.colorCommon)
            Spacer()
            Button(action: {
                Preferences.saveThemeVariant(themeVariant: self.themeVariant)
                Preferences.saveFontScaleVariant(fontScaleVariant: self.fontScaleVariant)
                self.onReloadSettings()
            }, label: {
                Text("Сохранить")
                    .foregroundColor(colorBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45.0)
            })
            .background(self.theme.colorCommon)
        }
        .padding(10.0)
        .background(self.theme.colorBg)
        .navigationBarItems(leading:
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onBackClick()
                    }
                }) {
                    Image("ic_back")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }, trailing: Spacer())
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: self.theme.colorCommon, titleColor: colorBlack)
    }
}
