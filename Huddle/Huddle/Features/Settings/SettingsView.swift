import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @EnvironmentObject private var store: Store
    @EnvironmentObject private var ads: Ads
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Prefs.sound) private var sound = true
    @AppStorage(Prefs.haptics) private var haptics = true

    private var version: String {
        let info = Bundle.main.infoDictionary
        return "\(info?["CFBundleShortVersionString"] as? String ?? "1.0") (\(info?["CFBundleVersion"] as? String ?? "1"))"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    section(L("Language", "Bahasa"), icon: "globe") {
                        languageButton("English", code: "en")
                        languageButton("Bahasa Indonesia", code: "id")
                    }

                    section(L("Sound & vibration", "Suara & getar"), icon: "speaker.wave.2.fill") {
                        Toggle(L("Sound effects", "Efek suara"), isOn: $sound)
                        Toggle(L("Vibration", "Getar"), isOn: $haptics)
                        Text(L("Sounds stay quiet when your phone is on silent.", "Suara tidak berbunyi saat HP dalam mode senyap."))
                            .font(HuddleFont.caption(12))
                            .foregroundColor(HuddleColors.textMuted)
                    }
                    .tint(HuddleColors.whoAmI)

                    section(L("Ads", "Iklan"), icon: "sparkles") {
                        if store.adsRemoved {
                            Label(L("Ads are off. Thank you for your support!", "Iklan sudah dimatikan. Terima kasih atas dukunganmu!"),
                                  systemImage: "checkmark.seal.fill")
                                .font(HuddleFont.body(15))
                                .foregroundColor(HuddleColors.whoAmI)
                        } else {
                            Text(L("There's a banner on the home screen and sometimes a short ad between games. Never during a round.",
                                   "Ada spanduk iklan di beranda dan sesekali iklan singkat di antara permainan. Tidak pernah saat sedang main."))
                                .font(HuddleFont.caption(13))
                                .foregroundColor(HuddleColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            GlowButton(title: removeAdsTitle, color: HuddleColors.mostLikelyTo) {
                                Task { await store.buy() }
                            }
                            .disabled(store.busy)
                        }
                        HStack(spacing: 16) {
                            Button(L("Restore purchase", "Pulihkan pembelian")) { Task { await store.restore() } }
                                .disabled(store.busy)
                            if ads.privacyChoicesRequired {
                                Button(L("Privacy choices", "Pilihan privasi")) { Task { await ads.showPrivacyChoices() } }
                            }
                        }
                        .font(HuddleFont.body(15))
                        .foregroundColor(HuddleColors.textPrimary)
                        if let message = store.message {
                            Text(message).font(HuddleFont.caption(12)).foregroundColor(HuddleColors.textMuted)
                        }
                    }

                    section(L("About", "Tentang"), icon: "info.circle") {
                        aboutRow(L("Version", "Versi"), value: version)
                        aboutRow(L("Games", "Permainan"), value: "\(GameDefinition.allGames.count)")
                        Link(L("Help & support", "Bantuan"), destination: URL(string: "https://jadewall.wokku.app/huddle")!)
                        Link(L("Privacy policy", "Kebijakan privasi"), destination: URL(string: "https://jadewall.wokku.app/huddle/privacy")!)
                    }
                    .tint(HuddleColors.wordBomb)
                }
                .padding(20)
                .readableColumn()
            }
            .background(HuddleColors.background.ignoresSafeArea())
            .navigationTitle(L("Settings", "Pengaturan"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("Done", "Selesai")) { dismiss() }
                        .foregroundColor(HuddleColors.impostor)
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var removeAdsTitle: String {
        let base = L("REMOVE ADS", "HAPUS IKLAN")
        if let p = store.product { return "\(base) · \(p.displayPrice)" }
        return base
    }

    private func section<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(HuddleFont.heading(16))
                .foregroundColor(HuddleColors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content()
                .foregroundColor(HuddleColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(HuddleColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func languageButton(_ name: String, code: String) -> some View {
        let selected = appState.selectedLanguage == code
        return Button {
            Feedback.tap()
            appState.selectedLanguage = code
        } label: {
            HStack {
                Text(name)
                    .font(HuddleFont.body())
                    .foregroundColor(HuddleColors.textPrimary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(HuddleColors.whoAmI)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(selected ? HuddleColors.whoAmI.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? HuddleColors.whoAmI.opacity(0.3) : HuddleColors.cardBorder, lineWidth: 1)
            )
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
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
