import SwiftUI
import shared
import SwiftUI_SimpleToast

struct RootView: View {
    let root: RootComponent

    private let toastOptions = SimpleToastOptions(
        hideAfter: 2
    )

    private var appStateMachine: AppStateMachine {
        AppStateMachine(showToast: showToast)
   }

    @State var appState: AppState = AppState()
    
    @State var needShowToast = false
    @State var toastText = ""

    var body: some View {
        ZStack {
            StackView(
                stackValue: StateValue(root.stack),
                getTitle: {
                    switch $0 {
                    case is RootComponentChild.SongListChild: return "SongList"
                    case is RootComponentChild.SongTextChild: return "SongText"
                    default: return ""
                    }
                },
                onBack: root.onBackClicked,
                childContent: {
                    switch $0 {
                    case let child as RootComponentChild.SongListChild: SongListView(
                        songListComponent: child.component,
                        theme: self.appState.theme,
                        localState: self.appState.localState,
                        onPerformAction: self.performAction
                    )                                                                                   
                    case let child as RootComponentChild.SongTextChild: SongTextView(
                        songTextComponent: child.component,
                        theme: self.appState.theme,
                        song: self.appState.localState.currentSong!,
                        onPerformAction: self.performAction
                    ).navigationBarBackButtonHidden(true)
                    case let child as RootComponentChild.CloudSearchChild: CloudSearchView(
                        cloudSearchComponent: child.component,
                        theme: self.appState.theme,
                        cloudState: self.appState.cloudState,
                        onPerformAction: self.performAction
                    ).navigationBarBackButtonHidden(true)
                    default: EmptyView()
                    }
                }
            )
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
                self.appState.localState.isDrawerOpen.toggle()
            }
        }
//        .onReceive(self.orientationChanged) { _ in
//            forceReload()
//        }
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

    func showToast(_ text: String) {
        self.toastText = text
        withAnimation {
            self.needShowToast.toggle()
        }
    }
}
