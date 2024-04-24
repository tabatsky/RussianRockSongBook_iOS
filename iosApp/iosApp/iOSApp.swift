import SwiftUI
import shared

@main
struct iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            RootView(root: appDelegate.root)
        }
    }
    
//    var body: some Scene {
//		WindowGroup {
//			ContentView()
//		}
//	}
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let root: RootComponent = DefaultRootComponent(
        componentContext: DefaultComponentContext(lifecycle: ApplicationLifecycle())
    )
}
