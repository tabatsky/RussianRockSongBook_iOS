import SwiftUI
import shared
import SwiftUI_SimpleToast

struct ContentView: View {
    private let toastOptions = SimpleToastOptions(
        hideAfter: 2
    )
    
    private var appStateMachine: AppStateMachine {
        AppStateMachine(showToast: showToast)
    }
    
    @State var appState: AppState = AppState()
    
    @State var needShowToast = false
    @State var toastText = ""
    
    @State var orientation = UIDevice.current.orientation

    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    @State var isReady = true
    
	var body: some View {
	    ZStack {
            /// Navigation Bar Title part
            if !self.appState.localState.isDrawerOpen {
                NavigationView {
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
                    } else if (self.appState.currentScreenVariant == .start) {
                        StartScreenView(
                            theme: self.appState.theme,
                            onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .songList) {
                        SongListView(
                            songListComponent: nil,
                            theme: self.appState.theme,
                            localState: self.appState.localState,
                            onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .songText) {
                        SongTextView(
                            songTextComponent: nil,
                            theme: self.appState.theme,
                            song: self.appState.localState.currentSong!,
                            onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .cloudSearch) {
                        CloudSearchView(
                            cloudSearchComponent: nil,
                            theme: self.appState.theme,
                            cloudState: self.appState.cloudState,
                            onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .cloudSongText) {
                        CloudSongTextView(
                            cloudSongTextComponent: nil,
                            theme: self.appState.theme,
                            cloudState: self.appState.cloudState,
                            onPerformAction: self.performAction
                        )
                    } else if (self.appState.currentScreenVariant == .settings) {
                        SettingsView(
                            theme: self.appState.theme,
                            onPerformAction: self.performAction
                        )
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            /// Navigation Drawer part
            NavigationDrawer(
                rootComponent: nil,
                theme: self.appState.theme,
                artists: self.appState.artists,
                isOpen: self.appState.localState.isDrawerOpen,
                onPerformAction: self.performAction)
                 /// Other behaviors
        }
        .background(self.appState.theme.colorCommon)
        .onTapGesture {
            if self.appState.localState.isDrawerOpen {
                self.appState.localState.isDrawerOpen.toggle()
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
        self.appStateMachine.performAction(changeState: { self.appState = $0 },
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

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}

