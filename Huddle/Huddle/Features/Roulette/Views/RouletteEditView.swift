import SwiftUI

struct RouletteEditView: View {
    let game: RouletteGame
    @State private var newItemText = ""
    @State private var showPresets = false

    var body: some View {
        VStack(spacing: 12) {
            // Presets button
            Button(action: { showPresets.toggle() }) {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                    Text("PRESETS")
                        .font(HuddleFont.caption(11))
                        .tracking(1)
                }
                .foregroundColor(HuddleColors.roulette)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(HuddleColors.roulette.opacity(0.12))
                .clipShape(Capsule())
            }

            if showPresets {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(RouletteGame.presets.indices, id: \.self) { i in
                            let preset = RouletteGame.presets[i]
                            Button(action: {
                                game.loadPreset(preset)
                                showPresets = false
                            }) {
                                Text(preset.name)
                                    .font(HuddleFont.caption(11))
                                    .foregroundColor(HuddleColors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(HuddleColors.cardBackground)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(HuddleColors.roulette.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Add item row
            HStack(spacing: 8) {
                TextField("Add item...", text: $newItemText)
                    .font(HuddleFont.body(14))
                    .foregroundColor(HuddleColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(HuddleColors.cardBorder, lineWidth: 1)
                    )
                    .onSubmit {
                        addItem()
                    }

                Button(action: addItem) {
                    Text("ADD")
                        .font(HuddleFont.caption(11))
                        .tracking(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(HuddleColors.roulette)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)

            // Item list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(game.items.indices, id: \.self) { i in
                        let color = RouletteGame.segmentColors[i % RouletteGame.segmentColors.count]
                        HStack(spacing: 4) {
                            Circle()
                                .fill(color)
                                .frame(width: 8, height: 8)
                            Text(game.items[i])
                                .font(HuddleFont.caption(11))
                                .foregroundColor(HuddleColors.textPrimary)
                                .lineLimit(1)
                            Button(action: { game.removeItem(at: i) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(HuddleColors.textMuted)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(HuddleColors.cardBackground)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }

            // Item count + Spin button
            HStack {
                Text("\(game.items.count) items")
                    .font(HuddleFont.caption(11))
                    .foregroundColor(HuddleColors.textMuted)
                Spacer()
            }
            .padding(.horizontal, 16)

            GlowButton(title: "SPIN!", color: HuddleColors.roulette) {
                game.spin()
            }
            .disabled(game.items.count < 2)
            .opacity(game.items.count < 2 ? 0.4 : 1)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .animation(.spring(duration: 0.25), value: showPresets)
    }

    private func addItem() {
        let text = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        game.addItem(text)
        newItemText = ""
    }
}
