import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HubView()
            // Rebuild every screen when the language changes, so all text switches at once.
            .id(appState.selectedLanguage)
            .environment(\.locale, Locale(identifier: appState.selectedLanguage))
            .background(HuddleColors.background.ignoresSafeArea())
    }
}
