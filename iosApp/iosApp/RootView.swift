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
                    default: EmptyView()
                    }
                }
            )
            NavigationDrawer(theme: self.appState.theme,
                             artists: self.appState.artists,
                             isOpen: self.appState.localState.isDrawerOpen,
                             onPerformAction: self.performAction)
        }
    }

    func performAction(_ action: AppUIAction) {
        self.appStateMachine.performAction(changeState: { self.appState = $0 },
                                               appState: self.appState,
                                               action: action)
    }

    func showToast(_ text: String) {

    }
}
