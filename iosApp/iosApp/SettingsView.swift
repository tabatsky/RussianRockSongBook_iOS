//
//  SettingsView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 07.11.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct SettingsView: View {
    let settingsComponent: SettingsComponent?
    let theme: Theme
    let onPerformAction: (AppUIAction) -> ()
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    @State var themeVariant = Preferences.loadThemeVariant()
    @State var fontScaleVariant = Preferences.loadFontScaleVariant()
    @State var listenToMusicVariant = Preferences.loadListenToMusicVariant()
    @State var scrollSpeed = Preferences.loadScrollSpeed()
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                HStack(spacing: 0) {
                    Text("Тема:")
                        .foregroundColor(self.theme.colorMain)
                        .font(self.theme.fontCommon)
                        .frame(width: (geometry.size.width - 20) / 2, alignment: .leading)
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
                        .frame(width: (geometry.size.width - 20) / 2)
                        .frame(height: 36.0)
                        .background(self.theme.colorCommon)
                }
                HStack(spacing: 0) {
                    Text("Размер шрифта:")
                        .foregroundColor(self.theme.colorMain)
                        .font(self.theme.fontCommon)
                        .frame(width: (geometry.size.width - 20) / 2, alignment: .leading)
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
                }
                HStack(spacing: 0) {
                    Text("Слушать музыку:")
                        .foregroundColor(self.theme.colorMain)
                        .font(self.theme.fontCommon)
                        .frame(width: (geometry.size.width - 20) / 2, alignment: .leading)
                    Menu {
                        Button(ListenToMusicVariant.yandexAndYoutube.listenToMusicName()) {
                            self.listenToMusicVariant = ListenToMusicVariant.yandexAndYoutube
                        }
                        Button(ListenToMusicVariant.yandexAndVk.listenToMusicName()) {
                            self.listenToMusicVariant = ListenToMusicVariant.yandexAndVk
                        }
                        Button(ListenToMusicVariant.youtubeAndVk.listenToMusicName()) {
                            self.listenToMusicVariant = ListenToMusicVariant.youtubeAndVk
                        }
                    } label: {
                        Text(self.listenToMusicVariant.listenToMusicName())
                    }
                    .foregroundColor(colorBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36.0)
                    .background(self.theme.colorCommon)
                }
                HStack(spacing: 0) {
                    Text("Скорость прокрутки (x):")
                        .foregroundColor(self.theme.colorMain)
                        .font(self.theme.fontCommon)
                        .frame(width: (geometry.size.width - 20) / 2, alignment: .leading)
                    TextField("", value: self.$scrollSpeed, formatter: formatter)
                        .foregroundColor(self.theme.colorBg)
                        .font(self.theme.fontCommon)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36.0)
                        .background(self.theme.colorMain)
                }
                Spacer()
                Button(action: {
                    self.saveSettings()
                }, label: {
                    Text("Применить")
                        .foregroundColor(colorBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45.0)
                })
                .background(self.theme.colorCommon)
            }
            .padding(10.0)
        }
        .background(self.theme.colorBg)
        .navigationBarItems(leading:
                Button(action: {
                    Task.detached { @MainActor in
                        self.onPerformAction(BackClick())
                        self.settingsComponent?.onBackPressed()
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
    
    private func saveSettings() {
        Preferences.saveThemeVariant(themeVariant: self.themeVariant)
        Preferences.saveFontScaleVariant(fontScaleVariant: self.fontScaleVariant)
        Preferences.saveListenToMusicVariant(listenToMusicVariant: self.listenToMusicVariant)
        Preferences.saveScrollSpeed(scrollSpeed: self.scrollSpeed)
        self.onPerformAction(ReloadSettings(
            themeVariant: self.themeVariant,
            fontScaleVariant: self.fontScaleVariant
        ))
    }
 }
