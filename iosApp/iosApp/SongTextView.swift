//
//  SongTextView.swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct SongTextView: View {
    let theme: Theme
    let song: Song
    let onBackClick: () -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    let onFavoriteToggle: () -> ()
    let onSaveSongText: (String) -> ()
    let onDeleteToTrashConfirmed: () -> ()
    let onShowToast: (String) -> ()
    let onOpenSongAtYandexMusic: (Music) -> ()
    let onOpenSongAtYoutubeMusic: (Music) -> ()
    let onOpenSongAtVkMusic: (Music) -> ()
    let onSendWarning: (Warning) -> ()
    
    let dY: CGFloat = 8.0 * CGFloat(Preferences.loadScrollSpeed())
    
    @State var textHeight: CGFloat = 0.0
    @State var scrollViewHeight: CGFloat = 0.0
    @State var scrollY: CGFloat = 0.0
    @State var minGlobalY: CGFloat = 0.0
    @State var isAutoScroll = false
    @State var isScreenActive = false
    @State var currentChord: String? = nil
    @State var isEditorMode = false
    @State var editorText = ""
    @State var isPresentingDeleteConfirm = false
    
    @State var needShowWarningDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            let title = song.title
            
            ZStack {
                VStack {
                    Text(title)
                        .font(self.theme.fontTitle)
                        .bold()
                        .foregroundColor(self.theme.colorMain)
                        .padding(24)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                    
                    GeometryReader { scrollViewGeometry in
                        ScrollViewReader { sp in
                            ScrollView(.vertical) {
                                ContainerView {
                                    if (self.isEditorMode) {
                                        TheTextEditor(theme: self.theme, text: song.text, width: geometry.size.width, height: self.textHeight, onTextChanged: { self.editorText = $0 })
                                    } else {
                                        TheTextViewer(
                                            theme: self.theme,
                                            text: song.text,
                                            width: geometry.size.width,
                                            onChordTapped: onChordTapped,
                                            onHeightChanged: { height in
                                                if (height > 1) {
                                                    print("updating textHeight: \(height)")
                                                    self.textHeight = height
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                                        performScrollToY(sp: sp)
                                                    })
                                                } else {
                                                    print("not updating textHeight: \(height)")
                                                }
                                            })
                                    }
                                }
                                .id("text")
                                .frame(minHeight: self.textHeight)
                                .background(GeometryReader { scrollViewGeom in
                                    self.theme.colorBg
                                        .preference(
                                            key: FrameKeySongText.self,
                                            // See discussion!
                                            value: scrollViewGeom.frame(in: .global)
                                        )
                                        .onPreferenceChange(FrameKeySongText.self) { frame in
                                            let globalY = -frame.origin.y
                                            if (self.minGlobalY == 0) {
                                                self.minGlobalY = globalY
                                            }
                                            let localY = globalY - self.minGlobalY
                                            if (localY > 0) {
                                                print("updating scrollY: \(localY)")
                                                self.scrollY = localY
                                            }
                                        }
                                })
                                .onAppear(perform: {
                                    print("appear")
                                    self.editorText = song.text
                                    self.scrollY = 0.0
                                    self.isScreenActive = true
                                    sp.scrollTo("text", anchor: .topLeading)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                        autoScroll(sp: sp)
                                    })
                                })
                                .onDisappear(perform: {
                                    self.isAutoScroll = false
                                    self.isScreenActive = false
                                })
                                .onChange(of: ArtistWithTitle(artist: self.song.artist, title: self.song.title), perform: { artistWithTitle in
                                    print("song changed")
                                    self.editorText = song.text
                                    self.isAutoScroll = false
                                    self.scrollY = 0.0
                                    self.isEditorMode = false
                                    sp.scrollTo("text", anchor: .topLeading)
                                })
                                .onChange(of: self.isEditorMode, perform: { isEditorMode in
                                    print("editor mode: \(isEditorMode)")
                                    if #available(iOS 15, *) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                            performScrollToY(sp: sp)
                                        })
                                    } else if isEditorMode {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                            performScrollToY(sp: sp)
                                        })
                                    }
                                })
                            }
                        }
                        .onAppear(perform: {
                            self.scrollViewHeight = scrollViewGeometry.size.height
                            print(self.scrollViewHeight)
                        })
                    }
                    SongTextPanel(
                        W: geometry.size.width,
                        theme: self.theme,
                        isEditorMode: self.isEditorMode,
                        onEdit: onEdit,
                        onSave: onSave,
                        onDeleteToTrash: onDeleteToTrash,
                        onShowWarning: onShowWarning,
                        onUploadToCloud: onUploadToCloud,
                        onOpenYandexMusic: onOpenYandexMusic,
                        onOpenYoutubeMusic: onOpenYoutubeMusuc,
                        onOpenVkMusic: onOpenVkMusuc
                    )
                }
                if let chord = self.currentChord {
                    ChordViewer(theme: self.theme, chord: chord, onDismiss: {
                        self.currentChord = nil
                    })
                }
            }
        }
        .background(self.theme.colorBg)
        .navigationBarItems(leading: Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onBackClick()
            }
        }) {
            Image("ic_back")
                .resizable()
                .frame(width: 32.0, height: 32.0)
        }, trailing: HStack {
            Button(action: {
                if (!self.isEditorMode) {
                    self.isAutoScroll.toggle()
                }
            }) {
                if (self.isAutoScroll) {
                    Image("ic_pause")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                } else {
                    Image("ic_play")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onPrevClick()
                }
            }) {
                Image("ic_left")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onFavoriteToggle()
                }
            }) {
                if (song.favorite) {
                    Image("ic_delete")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                } else {
                    Image("ic_star")
                        .resizable()
                        .frame(width: 32.0, height: 32.0)
                }
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onNextClick()
                }
            }) {
                Image("ic_right")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColor(backgroundColor: self.theme.colorCommon, titleColor: colorBlack)
        .customDialog(isShowing: self.$isPresentingDeleteConfirm, dialogContent: {
            VStack(spacing: 0.0) {
                Text("Вы уверены?")
                    .font(self.theme.fontTitle)
                    .foregroundColor(self.theme.colorBg)
                Spacer()
                    .frame(height: 20.0)
                Text("Песня будет удалена из локальной базы данных")
                    .font(self.theme.fontCommon)
                    .foregroundColor(self.theme.colorBg)
                Spacer()
                Divider()
                    .frame(height: 5.0)
                    .background(self.theme.colorBg)
                Button(action: {
                    self.isPresentingDeleteConfirm = false
                    self.onDeleteToTrashConfirmed()
                }, label: {
                    Text("Ок")
                        .foregroundColor(self.theme.colorBg)
                        .frame(height: 45.0)
                })
                Divider()
                    .frame(height: 5.0)
                    .background(self.theme.colorBg)
                Button(action: {
                    self.isPresentingDeleteConfirm = false
                }, label: {
                    Text("Отмена")
                        .foregroundColor(self.theme.colorBg)
                        .frame(height: 45.0)
                })
            }
            .frame(width: 200.0, height: 270.0)
            .background(self.theme.colorCommon)
        })
        .customDialog(isShowing: self.$needShowWarningDialog, dialogContent: {
            WarningDialog(
                theme: self.theme,
                onDismiss: {
                    self.needShowWarningDialog = false
                }, onSend: {
                    if ($0.isEmpty) {
                        self.onShowToast("Комментарий не должен быть пустым")
                    } else {
                        self.needShowWarningDialog = false
                        let warning = self.song.warningWithComment(comment: $0)
                        self.onSendWarning(warning)
                    }
                }
            )
        })
    }
    
    func autoScroll(sp: ScrollViewProxy) {
        if (self.isAutoScroll) {
            self.scrollY += self.dY
            performScrollToY(sp: sp)
        }
        if (self.isScreenActive) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                autoScroll(sp: sp)
            })
        }
    }
    
    func performScrollToY(sp: ScrollViewProxy) {
        let deltaHeight = self.textHeight - self.scrollViewHeight
        if (deltaHeight > 0 && self.scrollY < deltaHeight) {
            sp.scrollTo("text", anchor: UnitPoint(x: 0.0, y: self.scrollY / deltaHeight))
        }
    }
    
    func onChordTapped(_ chord: String) {
        print("chord: \(chord)")
        self.currentChord = chord
    }
    
    func onEdit() {
        self.isAutoScroll = false
        self.isEditorMode = true
    }
    
    func onSave() {
        self.isAutoScroll = false
        self.isEditorMode = false
        self.onSaveSongText(self.editorText)
    }
    
    func onDeleteToTrash() {
        self.isPresentingDeleteConfirm = true
    }
    
    func onShowWarning() {
        print("show warning")
        self.needShowWarningDialog = true
    }
    
    func onUploadToCloud() {
        print("upload to cloud")
        let textWasChanged = song.textWasChanged
        if (!textWasChanged) {
            self.onShowToast("Нельзя залить в облако: данный вариант аккордов поставляется вместе с приложением либо был сохранен из облака")
        } else {
            CloudRepository.shared.addCloudSongAsync(
                cloudSong: song.asCloudSong(),
                onSuccess: {
                    self.onShowToast("Успешно добавлено в облако")
                },
                onServerMessage: {
                    self.onShowToast($0)
                }, onError: {
                    $0.printStackTrace()
                    self.onShowToast("Ошибка в приложении")
                })
        }
    }
    
    func onOpenYandexMusic() {
        print("open yandex music")
        self.onOpenSongAtYandexMusic(self.song)
    }
    
    func onOpenYoutubeMusuc() {
        print("open youtube music")
        self.onOpenSongAtYoutubeMusic(self.song)
    }
    
    func onOpenVkMusuc() {
        print("open vk music")
        self.onOpenSongAtVkMusic(self.song)
    }
}

struct SongTextPanel: View {
    let W: CGFloat
    let theme: Theme
    let isEditorMode: Bool
    let onEdit: () -> ()
    let onSave: () -> ()
    let onDeleteToTrash: () -> ()
    let onShowWarning: () -> ()
    let onUploadToCloud: () -> ()
    let onOpenYandexMusic: () -> ()
    let onOpenYoutubeMusic: () -> ()
    let onOpenVkMusic: () -> ()
    
    var body: some View {
        let A = W / 7
        
        HStack(spacing: A / 5) {
            if (Preferences.loadListenToMusicVariant().isYandex()) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onOpenYandexMusic()
                    }
                }) {
                    Image("ic_yandex")
                        .resizable()
                        .padding(A / 6)
                        .background(self.theme.colorCommon)
                }
            }
            if (Preferences.loadListenToMusicVariant().isVk()) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onOpenVkMusic()
                    }
                }) {
                    Image("ic_vk")
                        .resizable()
                        .padding(A / 6)
                        .background(self.theme.colorCommon)
                }
            }
            if (Preferences.loadListenToMusicVariant().isYoutube()) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onOpenYoutubeMusic()
                    }
                }) {
                    Image("ic_youtube")
                        .resizable()
                        .padding(A / 6)
                        .background(self.theme.colorCommon)
                }
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onUploadToCloud()
                }
            }) {
                Image("ic_upload")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onShowWarning()
                }
            }) {
                Image("ic_warning")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onDeleteToTrash()
                }
            }) {
                Image("ic_trash")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            if (self.isEditorMode) {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onSave()
                    }
                }) {
                    Image("ic_save")
                        .resizable()
                        .padding(A / 6)
                        .background(self.theme.colorCommon)
                        .frame(width: A, height: A)
                }
            } else {
                Button(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        onEdit()
                    }
                }) {
                    Image("ic_edit")
                        .resizable()
                        .padding(A / 6)
                        .background(self.theme.colorCommon)
                        .frame(width: A, height: A)
                }
            }
        }
        .frame(width: W, height: A)
    }
}

struct ArtistWithTitle: Equatable {
    let artist: String
    let title: String
}

struct FrameKeySongText: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}


