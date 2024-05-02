//
//  swift
//  iosApp
//
//  Created by Evgeny Tabatsky on 26.08.2023.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI
import shared

struct SongTextView: View {
    let songTextComponent: SongTextComponent?
    let theme: Theme
    let song: Song
    let onPerformAction: (AppUIAction) -> ()
    
    let dY: CGFloat = 8.0 * CGFloat(Preferences.loadScrollSpeed())
    
    @State var isAutoScroll = false
    @State var currentChord: String? = nil
    @State var isEditorMode = false
    @State var editorText = ""
    @State var isPresentingDeleteConfirm = false
    
    @State var needShowWarningDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            let title = song.title
            
            ZStack {
                if (geometry.size.width < geometry.size.height) {
                    VStack {
                        Text(title)
                            .font(self.theme.fontTitle)
                            .bold()
                            .foregroundColor(self.theme.colorMain)
                            .padding(24)
                            .frame(maxWidth: geometry.size.width, alignment: .leading)
                        SongTextBody(
                            geometry: geometry,
                            theme: self.theme,
                            song: self.song,
                            dY: self.dY,
                            isEditorMode: self.isEditorMode,
                            setEditorMode: { self.isEditorMode = $0 },
                            isAutoScroll: self.isAutoScroll,
                            setAutoScroll: { self.isAutoScroll = $0 },
                            setEditorText: { self.editorText = $0 },
                            onChordTapped: self.onChordTapped
                        )
                        HorizontalSongTextPanel(
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
                } else {
                    HStack {
                        VStack {
                            Text(title)
                                .font(self.theme.fontTitle)
                                .bold()
                                .foregroundColor(self.theme.colorMain)
                                .padding(24)
                                .frame(maxWidth: geometry.size.width, alignment: .leading)
                            SongTextBody(
                                geometry: geometry,
                                theme: self.theme,
                                song: self.song,
                                dY: self.dY,
                                isEditorMode: self.isEditorMode,
                                setEditorMode: { self.isEditorMode = $0 },
                                isAutoScroll: self.isAutoScroll,
                                setAutoScroll: { self.isAutoScroll = $0 },
                                setEditorText: { self.editorText = $0 },
                                onChordTapped: self.onChordTapped
                            )
                        }
                        VerticalSongTextPanel(
                            H: geometry.size.height,
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
            Task.detached { @MainActor in
                self.onPerformAction(BackClick())
                self.songTextComponent?.onBackPressed()
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
                Task.detached { @MainActor in
                    self.onPerformAction(LocalPrevClick())
                }
            }) {
                Image("ic_left")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
            Button(action: {
                Task.detached { @MainActor in
                    self.onPerformAction(FavoriteToggle(emptyListCallback: {
                        self.songTextComponent?.onBackPressed()
                    }))
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
                Task.detached { @MainActor in
                    self.onPerformAction(LocalNextClick())
                }
            }) {
                Image("ic_right")
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarColorAndFontSize(
            backgroundColor: self.theme.colorCommon,
            titleColor: colorBlack,
            fontSize: self.theme.fontSizeNavTitle
        )
        .customDialog(isShowing: self.$isPresentingDeleteConfirm, dialogContent: {
            VStack(spacing: 0.0) {
                VStack {
                    Spacer()
                    Text("Вы уверены?")
                        .font(self.theme.fontTitle)
                        .foregroundColor(self.theme.colorBg)
                    Spacer()
                        .frame(height: 20.0)
                    Text("Песня будет удалена из локальной базы данных")
                        .font(self.theme.fontCommon)
                        .foregroundColor(self.theme.colorBg)
                    Spacer()
                    Spacer()
                }
                .frame(width: 200.0, height: 170.0)
                .background(self.theme.colorMain)
                Button(action: {
                    self.isPresentingDeleteConfirm = false
                    self.onPerformAction(ConfirmDeleteToTrash(emptyListCallback: {
                        self.songTextComponent?.onBackPressed()
                    }))
                }, label: {
                    Text("Ок")
                        .foregroundColor(self.theme.colorMain)
                        .frame(height: 45.0)
                })
                Divider()
                    .frame(height: 5.0)
                    .background(self.theme.colorMain)
                Button(action: {
                    self.isPresentingDeleteConfirm = false
                }, label: {
                    Text("Отмена")
                        .foregroundColor(self.theme.colorMain)
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
                        self.onPerformAction(ShowToast(text: "Комментарий не должен быть пустым"))
                    } else {
                        self.needShowWarningDialog = false
                        let warning = self.song.warningWithComment(comment: $0)
                        self.onPerformAction(SendWarning(warning: warning))
                    }
                }
            )
        })
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
        self.onPerformAction(SaveSongText(newText: self.editorText))
    }
    
    func onDeleteToTrash() {
        self.isPresentingDeleteConfirm = true
    }
    
    func onShowWarning() {
        print("show warning")
        self.needShowWarningDialog = true
    }
    
    func onUploadToCloud() {
        self.onPerformAction(UploadCurrentToCloud())
    }
    
    func onOpenYandexMusic() {
        print("open yandex music")
        self.onPerformAction(OpenSongAtYandexMusic(music: self.song))
    }
    
    func onOpenYoutubeMusuc() {
        print("open youtube music")
        self.onPerformAction(OpenSongAtYoutubeMusic(music: self.song))
    }
    
    func onOpenVkMusuc() {
        print("open vk music")
        self.onPerformAction(OpenSongAtVkMusic(music: self.song))
    }
    
}

struct SongTextBody: View {
    let geometry: GeometryProxy
    let theme: Theme
    let song: Song
    let dY: CGFloat
    
    let isEditorMode: Bool
    let setEditorMode: (Bool) -> ()
    let isAutoScroll: Bool
    let setAutoScroll: (Bool) -> ()
    let setEditorText: (String) -> ()
    
    let onChordTapped: (String) -> ()
    
    @Environment(\.scenePhase) private var scenePhase
    
    @State var scrollY: CGFloat = 0.0
    @State var isScreenActive = false
    @State var scrollViewHeight: CGFloat = 0.0
    @State var isAutoScrollState = false
    @State var textHeight = 0.0
    @State var minGlobalY = 0.0
    
    var body: some View {
        GeometryReader { scrollViewGeometry in
            ScrollViewReader { sp in
                ScrollView(.vertical) {
                    ContainerView {
                        if (isEditorMode) {
                            TheTextEditor(theme: theme, text: song.text, width: geometry.size.width, height: textHeight, onTextChanged: setEditorText)
                        } else {
                            TheTextViewer(
                                theme: theme,
                                text: song.text,
                                width: geometry.size.width,
                                onChordTapped: onChordTapped,
                                onHeightChanged: { height in
                                    if (height > 1) {
                                        print("updating textHeight: \(height)")
                                        self.textHeight = height
                                        Task.detached {
                                            try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                            await MainActor.run {
                                                performScrollToY(sp)
                                            }
                                        }
                                    } else {
                                        print("not updating textHeight: \(height)")
                                    }
                                })
                        }
                    }
                    .id("text")
                    .frame(minHeight: textHeight)
                    .background(GeometryReader { scrollViewGeom in
                        theme.colorBg
                            .preference(
                                key: FrameKeySongText.self,
                                // See discussion!
                                value: scrollViewGeom.frame(in: .global)
                            )
                            .onPreferenceChange(FrameKeySongText.self) { frame in
                                let globalY = -frame.origin.y
                                if (minGlobalY == 0.0 && textHeight > 0.0 && globalY < 0.0) {
                                    self.minGlobalY = globalY
                                }
                                let localY = globalY - minGlobalY
                                let absDeltaY = abs(scrollY - localY)
                                let deltaHeight = self.textHeight - self.scrollViewHeight
                                let coeff = self.textHeight / deltaHeight
                                if (absDeltaY / coeff > 30 * dY || absDeltaY > 0.2 * self.scrollViewHeight || !self.isAutoScrollState) {
                                    print("updating localY: \(localY); absDeltaY: \(absDeltaY); coeff: \(coeff)")
                                    self.scrollY = localY
                                }
                            }
                    })
                    .onAppear {
                        print("appear")
                        setEditorText(song.text)
                        self.scrollY = 0.0
                        self.isScreenActive = true
                        sp.scrollTo("text", anchor: .topLeading)
                        Task.detached {
                            try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                            await MainActor.run {
                                autoScroll(sp)
                            }
                        }
                    }
                    .onDisappear(perform: {
                        print("disappear")
                        self.isScreenActive = false
                    })
                    .onChange(of: ArtistWithTitle(artist: song.artist, title: song.title), perform: { artistWithTitle in
                        print("song changed")
                        setEditorText(song.text)
                        setAutoScroll(false)
                        self.scrollY = 0.0
                        setEditorMode(false)
                        sp.scrollTo("text", anchor: .topLeading)
                    })
                    .onChange(of: self.isAutoScroll, perform: { autoScroll in
                        print("auto scroll: \(autoScroll)")
                        isAutoScrollState = autoScroll
                    })
                    .onChange(of: isEditorMode, perform: { isEditorMode in
                        print("editor mode: \(isEditorMode)")
                        if #available(iOS 15, *) {
                            Task.detached {
                                try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                await MainActor.run {
                                    performScrollToY(sp)
                                }
                            }
                        } else if isEditorMode {
                            Task.detached {
                                try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                await MainActor.run {
                                    performScrollToY(sp)
                                }
                            }
                        }
                    })
                    .onChange(of: scenePhase) { phase in
                        if (phase == .active) {
                            print("active")
                            self.isScreenActive = true
                            Task.detached {
                                try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                                await MainActor.run {
                                    autoScroll(sp)
                                }
                            }
                        } else {
                            print("inactive")
                            self.isScreenActive = false
                        }
                    }
                }
            }
            .onAppear {
                if (scrollViewGeometry.size.height > 0.0) {
                    self.scrollViewHeight = scrollViewGeometry.size.height
                    print("scroll view height: \(scrollViewGeometry.size.height)")
                }
            }
        }
    }
    
    func autoScroll(_ sp: ScrollViewProxy) {
        if (self.isAutoScrollState) {
            self.scrollY += self.dY
            self.performScrollToY(sp)
        }
        if (self.isScreenActive) {
            Task.detached {
                try await Task.sleep(nanoseconds: 200 * 1000 * 1000)
                await MainActor.run {
                    autoScroll(sp)
                }
            }
        }
    }
    
    func performScrollToY(_ sp: ScrollViewProxy) {
        let deltaHeight = self.textHeight - self.scrollViewHeight
        if (deltaHeight > 0) {
            if (self.scrollY < deltaHeight) {
                sp.scrollTo("text", anchor: UnitPoint(x: 0.0, y: self.scrollY / deltaHeight))
            } else {
                self.scrollY = deltaHeight
            }
        }
    }
}

struct HorizontalSongTextPanel: View {
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
                    Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
                Task.detached { @MainActor in
                    onUploadToCloud()
                }
            }) {
                Image("ic_upload")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            Button(action: {
                Task.detached { @MainActor in
                    onShowWarning()
                }
            }) {
                Image("ic_warning")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            Button(action: {
                Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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

struct VerticalSongTextPanel: View {
    let H: CGFloat
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
        let A = H / 7
        
        VStack(spacing: A / 5) {
            if (Preferences.loadListenToMusicVariant().isYandex()) {
                Button(action: {
                    Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
                Task.detached { @MainActor in
                    onUploadToCloud()
                }
            }) {
                Image("ic_upload")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            Button(action: {
                Task.detached { @MainActor in
                    onShowWarning()
                }
            }) {
                Image("ic_warning")
                    .resizable()
                    .padding(A / 6)
                    .background(self.theme.colorCommon)
            }
            Button(action: {
                Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
                    Task.detached { @MainActor in
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
        .frame(width: A, height: H)
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


