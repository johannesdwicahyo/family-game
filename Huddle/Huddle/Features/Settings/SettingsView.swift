import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Language
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Language", systemImage: "globe")
                            .font(HuddleFont.heading(16))
                            .foregroundColor(HuddleColors.textPrimary)

                        VStack(spacing: 8) {
                            languageButton("English", code: "en", flag: "🇺🇸")
                            languageButton("Bahasa Indonesia", code: "id", flag: "🇮🇩")
                        }
                    }
                    .padding(16)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Subscription
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Subscription", systemImage: "crown.fill")
                            .font(HuddleFont.heading(16))
                            .foregroundColor(HuddleColors.mostLikelyTo)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(appState.isProUser ? "Huddle Pro" : "Free Plan")
                                    .font(HuddleFont.body())
                                    .foregroundColor(HuddleColors.textPrimary)
                                Text(appState.isProUser ? "Unlimited plays" : "\(appState.playLimit.remainingPlays) plays left today")
                                    .font(HuddleFont.caption())
                                    .foregroundColor(HuddleColors.textSecondary)
                            }
                            Spacer()
                            if !appState.isProUser {
                                Text("UPGRADE")
                                    .font(HuddleFont.caption(10))
                                    .tracking(2)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(HuddleColors.mostLikelyTo)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(16)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // About
                    VStack(alignment: .leading, spacing: 12) {
                        Label("About", systemImage: "info.circle")
                            .font(HuddleFont.heading(16))
                            .foregroundColor(HuddleColors.textPrimary)

                        VStack(spacing: 8) {
                            aboutRow("Version", value: "1.0.0")
                            aboutRow("Games", value: "5")
                            aboutRow("Languages", value: "2")
                        }
                    }
                    .padding(16)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(20)
            }
            .background(HuddleColors.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(HuddleColors.impostor)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func languageButton(_ name: String, code: String, flag: String) -> some View {
        Button {
            appState.selectedLanguage = code
            HapticManager.tap()
        } label: {
            HStack {
                Text(flag)
                    .font(.system(size: 24))
                Text(name)
                    .font(HuddleFont.body())
                    .foregroundColor(HuddleColors.textPrimary)
                Spacer()
                if appState.selectedLanguage == code {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(HuddleColors.whoAmI)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(appState.selectedLanguage == code ? HuddleColors.whoAmI.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(appState.selectedLanguage == code ? HuddleColors.whoAmI.opacity(0.3) : HuddleColors.cardBorder, lineWidth: 1)
            )
        }
    }

    private func aboutRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(HuddleFont.body())
                .foregroundColor(HuddleColors.textSecondary)
            Spacer()
            Text(value)
                .font(HuddleFont.body())
                .foregroundColor(HuddleColors.textPrimary)
        }
    }
}
