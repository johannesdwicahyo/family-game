import SwiftUI

@main
struct HuddleApp: App {
    @State private var appState = AppState()
    @StateObject private var store = Store()
    @StateObject private var ads = Ads()

    init() {
        Prefs.registerDefaults()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environmentObject(store)
                .environmentObject(ads)
                .onAppear { ads.store = store }
                .task {
                    if DebugScreen.current == nil { await ads.start() }
                }
        }
    }
}
