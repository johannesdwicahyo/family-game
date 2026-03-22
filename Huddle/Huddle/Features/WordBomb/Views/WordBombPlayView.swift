import SwiftUI

struct WordBombPlayView: View {
    @Bindable var game: WordBombGame
    @FocusState private var isInputFocused: Bool
    @State private var showValidFlash = false
    @State private var showErrorShake = false

    private let accent = HuddleColors.wordBomb

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = game.timerStartDate.map { timeline.date.timeIntervalSince($0) } ?? 0
            let progress = min(elapsed / game.timerDuration, 1.0)

            ZStack {
                HuddleColors.background.ignoresSafeArea()

                // Red tension tint as time progresses
                Color.red.opacity(progress > 0.7 ? (progress - 0.7) * 0.15 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: progress)

                // Green flash on valid word
                if showValidFlash {
                    Color.green.opacity(0.15)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                // Red flash on error
                if showErrorShake {
                    Color.red.opacity(0.1)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                ScrollView {
                    VStack(spacing: 16) {
                        // Current player name
                        if let player = game.currentPlayer {
                            VStack(spacing: 4) {
                                Text(player.name)
                                    .font(HuddleFont.display(32))
                                    .foregroundColor(accent)

                                HStack(spacing: 3) {
                                    ForEach(0..<game.livesPerPlayer, id: \.self) { i in
                                        Text(i < (game.lives[player.id] ?? 0) ? "\u{2764}\u{FE0F}" : "\u{1F5A4}")
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                        }

                        // Bomb with shake animation
                        bombView(progress: progress)

                        // Syllable display
                        syllableBox(progress: progress)

                        // Text input
                        inputSection

                        // Player ring
                        playerRing

                        // Used words
                        if !game.usedWords.isEmpty {
                            usedWordsSection
                        }
                    }
                    .padding(20)
                }
            }
            .onChange(of: progress) { _, newValue in
                if newValue >= 1.0 && game.phase == .play {
                    game.bombExploded()
                }
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }

    // MARK: - Bomb

    @ViewBuilder
    private func bombView(progress: Double) -> some View {
        let intensity = min(progress * 1.5, 1.0)
        let shakeAmount = intensity * 14
        let pulseSpeed = max(0.15, 0.8 - intensity * 0.65)

        Text("\u{1F4A3}")
            .font(.system(size: 72))
            .shadow(color: .red.opacity(0.1 + intensity * 0.5), radius: 10 + intensity * 25)
            .rotationEffect(.degrees(
                sin(Date().timeIntervalSinceReferenceDate * (.pi * 2 / pulseSpeed)) * shakeAmount
            ))
            .offset(
                x: sin(Date().timeIntervalSinceReferenceDate * 13.7) * shakeAmount * 0.6,
                y: cos(Date().timeIntervalSinceReferenceDate * 11.3) * shakeAmount * 0.4
            )
    }

    // MARK: - Syllable

    @ViewBuilder
    private func syllableBox(progress: Double) -> some View {
        Text(game.currentSyllable)
            .font(HuddleFont.display(72))
            .tracking(8)
            .foregroundColor(HuddleColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(HuddleColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(accent.opacity(0.3 + progress * 0.4), lineWidth: 2)
            )
            .shadow(color: accent.opacity(0.15 + progress * 0.25), radius: 20 + progress * 20)
    }

    // MARK: - Input

    @ViewBuilder
    private var inputSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                TextField("Type a word...", text: $game.inputText)
                    .font(HuddleFont.heading(20))
                    .tracking(2)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                showErrorShake ? Color.red.opacity(0.6) :
                                showValidFlash ? Color.green.opacity(0.6) :
                                accent.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                    .foregroundColor(HuddleColors.textPrimary)
                    .focused($isInputFocused)
                    .onSubmit {
                        handleSubmit()
                    }
                    .offset(x: showErrorShake ? -6 : 0)

                Button {
                    handleSubmit()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(game.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? HuddleColors.textMuted : accent)
                }
                .disabled(game.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if let error = game.errorMessage {
                Text(error)
                    .font(HuddleFont.caption())
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Player ring

    @ViewBuilder
    private var playerRing: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(game.players) { player in
                    let playerLives = game.lives[player.id] ?? 0
                    let isCurrentPlayer = game.currentPlayer?.id == player.id
                    let isDead = playerLives <= 0

                    VStack(spacing: 2) {
                        Text(player.name)
                            .font(HuddleFont.caption(10))
                            .foregroundColor(isDead ? HuddleColors.textMuted : (isCurrentPlayer ? accent : HuddleColors.textSecondary))
                            .strikethrough(isDead)

                        if !isDead {
                            HStack(spacing: 1) {
                                ForEach(0..<game.livesPerPlayer, id: \.self) { i in
                                    Text(i < playerLives ? "\u{2764}\u{FE0F}" : "\u{1F5A4}")
                                        .font(.system(size: 8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isCurrentPlayer ? accent.opacity(0.15) : HuddleColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isCurrentPlayer ? accent.opacity(0.4) : HuddleColors.cardBorder, lineWidth: 1)
                    )
                    .opacity(isDead ? 0.4 : 1)
                }
            }
        }
    }

    // MARK: - Used words

    @ViewBuilder
    private var usedWordsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("USED WORDS (\(game.usedWords.count))")
                .font(HuddleFont.caption(9))
                .tracking(2)
                .foregroundColor(HuddleColors.textMuted)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(Array(game.usedWords).suffix(5), id: \.self) { word in
                        Text(word.uppercased())
                            .font(HuddleFont.caption(10))
                            .foregroundColor(HuddleColors.textMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(HuddleColors.cardBorder, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func handleSubmit() {
        let previousWordCount = game.totalWordsPlayed
        game.submitWord()
        if game.totalWordsPlayed > previousWordCount {
            // Valid word
            showValidFlash = true
            withAnimation(.easeOut(duration: 0.4)) {
                showValidFlash = false
            }
        } else if game.errorMessage != nil {
            // Invalid word
            withAnimation(.default) {
                showErrorShake = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                showErrorShake = false
            }
        }
        isInputFocused = true
    }
}
