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
    let song: Song
    let onBackClick: () -> ()
    let onPrevClick: () -> ()
    let onNextClick: () -> ()
    let onFavoriteToggle: () -> ()
    let onSaveSongText: (String) -> ()
    let onDeleteToTrashConfirmed: () -> ()
    
    static let dY: CGFloat = 8.0
    
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
    
    var body: some View {
        GeometryReader { geometry in
            let title = song.title
            
            ZStack {
                VStack {
                    Text(title)
                        .font(Theme.fontTitle)
                        .bold()
                        .foregroundColor(Theme.colorMain)
                        .padding(24)
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                    
                    GeometryReader { scrollViewGeometry in
                        ScrollViewReader { sp in
                            ScrollView(.vertical) {
                                ContainerView {
                                    if (self.isEditorMode) {
                                        TheTextEditor(text: song.text, width: geometry.size.width, height: self.textHeight, onTextChanged: { self.editorText = $0 })
                                    } else {
                                        TheTextViewer(
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
                                    Theme.colorBg
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
                        isEditorMode: self.isEditorMode,
                        onEdit: onEdit,
                        onSave: onSave,
                        onDeleteToTrash: onDeleteToTrash,
                        onShowWarning: onShowWarning,
                        onUploadToCloud: onUploadToCloud,
                        onOpenYandexMusic: onOpenYandexMusic,
                        onOpenYoutubeMusic: onOpenYoutubeMusuc
                    )
                }
                if let chord = self.currentChord {
                    ChordViewer(chord: chord, onDismiss: {
                        self.currentChord = nil
                    })
                }
            }
        }
        .background(Theme.colorBg)
        .navigationBarItems(leading:
                                Button(action: {
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
        .navigationBarColor(backgroundColor: Theme.colorCommon, titleColor: colorBlack)
        .actionSheet(isPresented: self.$isPresentingDeleteConfirm) {
            ActionSheet(
                title: Text("Вы уверены?"),
                message: Text("Песня будет удалена из локальной базы данных"),
                buttons: [
                    .default(Text("Ок")) {
                        self.isPresentingDeleteConfirm = false
                        self.onDeleteToTrashConfirmed()
                    },
                    
                    .cancel(Text("Отмена")) {
                        self.isPresentingDeleteConfirm = false
                    }
                ]
            )
        }
    }
    
    func autoScroll(sp: ScrollViewProxy) {
        if (self.isAutoScroll) {
            self.scrollY += Self.dY
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
        onSaveSongText(self.editorText)
    }
    
    func onDeleteToTrash() {
        self.isPresentingDeleteConfirm = true
    }
    
    func onShowWarning() {
        print("show warning")
    }
    
    func onUploadToCloud() {
        print("upload to cloud")
    }
    
    func onOpenYandexMusic() {
        print("open yandex music")
    }
    
    func onOpenYoutubeMusuc() {
        print("open youtube music")
    }
}

struct SongTextPanel: View {
    let W: CGFloat
    let isEditorMode: Bool
    let onEdit: () -> ()
    let onSave: () -> ()
    let onDeleteToTrash: () -> ()
    let onShowWarning: () -> ()
    let onUploadToCloud: () -> ()
    let onOpenYandexMusic: () -> ()
    let onOpenYoutubeMusic: () -> ()
    
    var body: some View {
        let A = W / 7
        
        HStack(spacing: A / 5) {
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onOpenYandexMusic()
                }
            }) {
                Image("ic_yandex")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onOpenYoutubeMusic()
                }
            }) {
                Image("ic_youtube")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onUploadToCloud()
                }
            }) {
                Image("ic_upload")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onShowWarning()
                }
            }) {
                Image("ic_warning")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onDeleteToTrash()
                }
            }) {
                Image("ic_trash")
                    .resizable()
                    .padding(A / 6)
                    .background(Theme.colorCommon)
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
                        .background(Theme.colorCommon)
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
                        .background(Theme.colorCommon)
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


