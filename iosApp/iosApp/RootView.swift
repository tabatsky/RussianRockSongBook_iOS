import SwiftUI
import shared
import SwiftUI_SimpleToast

struct RootView: View {
    let root: RootComponent
    
    init(root: RootComponent) {
        self.root = root
        let _ = AppStateMachine.songRepo
        _appState = StateValue(root.appState)
        let newState = AppState.companion.doNewInstance(
            themeVariant: Preferences.loadThemeVariant(),
            fontScaleVariant: Preferences.loadFontScaleVariant()
        )
        root.updateState(newState: newState)
    }

    private let toastOptions = SimpleToastOptions(
        hideAfter: 2
    )

    private var appStateMachine: AppStateMachine {
        AppStateMachine(showToast: showToast)
   }
    
    @StateValue
    var appState: AppState
    
    @State var needShowToast = false
    @State var toastText = ""

    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    @State var isReady = true
    
    var body: some View {
        ZStack {
            if (!self.isReady) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: self.appState.theme.colorMain))
                            .scaleEffect(5.0)
                        Spacer()
                    }
                    Spacer()
                }
                .background(self.appState.theme.colorBg)
            } else {
                StackView(
                    stackValue: StateValue(root.stack),
                    getTitle: { _ in
                        return ""
                    },
                    onBack: root.onBackClicked,
                    childContent: {
                        switch $0 {
                        case let child as RootComponentChild.StartChild: StartScreenView(
                            startComponent: child.component,
                            theme: self.appState.theme,
                            onPerformAction: self.performAction
                        )
                        case let child as RootComponentChild.SongListChild: SongListView(
                            songListComponent: child.component,
                            theme: self.appState.theme,
                            localState: self.appState.localState,
                            onPerformAction: self.performAction
                        ).navigationBarBackButtonHidden(true)
                        case let child as RootComponentChild.SongTextChild: SongTextView(
                            songTextComponent: child.component,
                            theme: self.appState.theme,
                            song: self.appState.localState.currentSong!,
                            position: Int(self.appState.localState.currentSongIndex),
                            songCount: Int(self.appState.localState.currentCount),
                            onPerformAction: self.performAction
                        ).navigationBarBackButtonHidden(true)
                        case let child as RootComponentChild.CloudSearchChild: CloudSearchView(
                            cloudSearchComponent: child.component,
                            theme: self.appState.theme,
                            cloudState: self.appState.cloudState,
                            onPerformAction: self.performAction
                        ).navigationBarBackButtonHidden(true)
                        case let child as RootComponentChild.CloudSongTextChild: CloudSongTextView(
                            cloudSongTextComponent: child.component,
                            theme: self.appState.theme,
                            cloudState: self.appState.cloudState,
                            onPerformAction: self.performAction
                        ).navigationBarBackButtonHidden(true)
                        case let child as RootComponentChild.SettingsChild: SettingsView(
                            settingsComponent: child.component,
                            theme: self.appState.theme,
                            onPerformAction: self.performAction,
                            forceReload: self.forceReload
                        ).navigationBarBackButtonHidden(true)
                        default: EmptyView()
                        }
                    }
                )
            }
            NavigationDrawer(
                rootComponent: root,
                theme: self.appState.theme,
                artists: self.appState.artists,
                isOpen: self.appState.localState.isDrawerOpen,
                onPerformAction: self.performAction)
        }
        .background(self.appState.theme.colorCommon)
        .onTapGesture {
            if self.appState.localState.isDrawerOpen {
                self.performAction(DrawerClick())
            }
        }
        .onReceive(self.orientationChanged) { _ in
            forceReload()
        }
        .simpleToast(isPresented: $needShowToast, options: toastOptions) {
            Label(self.toastText, systemImage: "exclamationmark.triangle")
               .padding()
               .background(self.appState.theme.colorMain.opacity(0.8))
               .foregroundColor(self.appState.theme.colorBg)
               .cornerRadius(10)
               .padding(.top)
        }
    }

    func performAction(_ action: AppUIAction) {
        self.appStateMachine.performAction(changeState: { root.updateState(newState: $0) },
                                               appState: self.appState,
                                               action: action)
    }

    func forceReload() {
        self.isReady = false
        Task.detached {
            try await Task.sleep(nanoseconds: 50 * 100 * 100)
            Task.detached { @MainActor in
                self.isReady = true
            }
        }
    }
    
    func showToast(_ text: String) {
        self.toastText = text
        withAnimation {
            self.needShowToast.toggle()
        }
    }
}
