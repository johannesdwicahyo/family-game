import SwiftUI

/// Player count + names, shared by every game's setup screen. Names are remembered once for
/// the whole app, so the table types them a single time per evening.
struct PlayerNamesEditor: View {
    let range: ClosedRange<Int>
    let accent: Color
    @Binding var names: [String]

    static let key = "huddle_player_names"

    static func defaultName(_ i: Int) -> String { L("Player \(i + 1)", "Pemain \(i + 1)") }

    /// Saved names, padded or trimmed to fit the game's range.
    static func load(range: ClosedRange<Int>) -> [String] {
        var n = UserDefaults.standard.stringArray(forKey: key) ?? []
        if n.count < range.lowerBound { n += Array(repeating: "", count: range.lowerBound - n.count) }
        return Array(n.prefix(range.upperBound))
    }

    /// Final names: blanks get "Player N", duplicates get a number. Also remembers them.
    static func finalize(_ names: [String]) -> [String] {
        UserDefaults.standard.set(names, forKey: key)
        var seen: [String: Int] = [:]
        return names.enumerated().map { i, raw in
            var name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty { name = defaultName(i) }
            if let c = seen[name] {
                seen[name] = c + 1
                name = "\(name) \(c + 1)"
            } else {
                seen[name] = 1
            }
            return name
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                SectionLabel(L("PLAYERS", "PEMAIN"))
                Spacer()
                Stepper(value: Binding(get: { names.count }, set: { resize($0) }), in: range) {
                    Text("\(names.count)")
                        .font(HuddleFont.display(24))
                        .foregroundColor(accent)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .fixedSize()
                .accessibilityLabel(L("Number of players", "Jumlah pemain"))
                .accessibilityValue("\(names.count)")
            }
            ForEach(names.indices, id: \.self) { i in
                HStack(spacing: 10) {
                    Text("\(i + 1)")
                        .font(HuddleFont.caption(13))
                        .foregroundColor(HuddleColors.textMuted)
                        .frame(width: 22)
                    TextField(Self.defaultName(i), text: $names[i])
                        .font(HuddleFont.body())
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .padding(12)
                        .background(HuddleColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(HuddleColors.textPrimary)
                }
            }
        }
    }

    private func resize(_ count: Int) {
        Feedback.tap()
        if count > names.count { names += Array(repeating: "", count: count - names.count) }
        else { names = Array(names.prefix(count)) }
    }
}

/// Big art + game name at the top of a setup screen, in the wordmark's style: ink display type,
/// title case, with a short bar of the game's colour.
struct SetupHeader: View {
    let game: GameDefinition

    var body: some View {
        VStack(spacing: 8) {
            GameArt(game: game, size: 120)
            Text(game.name)
                .font(HuddleFont.display(34))
                .tracking(-0.8)
                .foregroundColor(HuddleColors.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Capsule().fill(game.accentColor.fillTone).frame(width: 36, height: 5)
            Text(game.description)
                .font(HuddleFont.body(15))
                .foregroundColor(HuddleColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }
}

/// The painted v3 trophy.
struct TrophyArt: View {
    var size: CGFloat = 100

    var body: some View {
        Image("Trophy").resizable().scaledToFit().frame(width: size, height: size).accessibilityHidden(true)
    }
}

/// A winner's name with a sunflower highlighter stroke behind it.
struct WinnerTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(HuddleFont.display(34))
            .tracking(-0.8)
            .foregroundColor(HuddleColors.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .background(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 3).fill(HuddleColors.gold.opacity(0.6)).frame(height: 14).offset(y: -5)
            }
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(HuddleFont.caption(12))
            .tracking(3)
            .foregroundColor(HuddleColors.textMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A row of choice chips (rounds, difficulty, timer…).
struct ChoiceRow<T: Hashable>: View {
    let title: String
    let options: [T]
    let label: (T) -> String
    let accent: Color
    @Binding var selection: T

    var body: some View {
        VStack(spacing: 8) {
            SectionLabel(title)
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { o in
                    let on = o == selection
                    Button {
                        Feedback.tap()
                        selection = o
                    } label: {
                        Text(label(o))
                            .font(HuddleFont.heading(15))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(on ? accent.onFill : HuddleColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(on ? accent.fillTone : HuddleColors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(on ? accent.fillTone : HuddleColors.cardBorder, lineWidth: 1))
                    }
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
    }
}

/// Simple "how to play" card used on setup screens.
struct RulesCard: View {
    let lines: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(L("HOW TO PLAY", "CARA MAIN"))
            ForEach(Array(lines.enumerated()), id: \.offset) { i, line in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(i + 1)")
                        .font(HuddleFont.heading(13))
                        .foregroundColor(accent)
                        .frame(width: 20, height: 20)
                        .background(accent.opacity(0.15))
                        .clipShape(Circle())
                    Text(line)
                        .font(HuddleFont.body(15))
                        .foregroundColor(HuddleColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(HuddleColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// Final scores list with medals and bars, used by the new games' result screens.
struct ScoreBoard: View {
    let rows: [(name: String, points: Int, detail: String?)]
    let accent: Color

    var body: some View {
        let maxPts = max(1, rows.map(\.points).max() ?? 1)
        VStack(spacing: 10) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rank, row in
                VStack(spacing: 6) {
                    HStack(spacing: 12) {
                        Medal(rank: rank)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(row.name)
                                .font(HuddleFont.heading(17))
                                .foregroundColor(HuddleColors.textPrimary)
                            if let d = row.detail {
                                Text(d).font(HuddleFont.caption(12)).foregroundColor(HuddleColors.textMuted)
                            }
                        }
                        Spacer()
                        Text("\(row.points)")
                            .font(HuddleFont.display(26))
                            .foregroundColor(rank == 0 ? HuddleColors.textPrimary : HuddleColors.textSecondary)
                    }
                    GeometryReader { geo in
                        Capsule()
                            .fill(rank == 0 ? HuddleColors.gold : accent.opacity(0.5))
                            .frame(width: geo.size.width * CGFloat(max(0, row.points)) / CGFloat(maxPts), height: 5)
                    }
                    .frame(height: 5)
                }
                .padding(12)
                .background(HuddleColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .combine)
            }
        }
    }
}

/// Gold, silver, bronze discs (drawn, not emoji), then plain numbers.
struct Medal: View {
    let rank: Int

    var body: some View {
        let colors: [Color] = [HuddleColors.gold, Color(hex: "#D9DEE8"), Color(hex: "#EBAA74")]
        ZStack {
            if rank < 3 {
                Circle().fill(colors[rank]).frame(width: 30, height: 30)
                    .shadow(color: HuddleColors.shadow, radius: 6, x: 0, y: 4)
                Text("\(rank + 1)").font(HuddleFont.heading(15)).foregroundColor(.black.opacity(0.75))
            } else {
                Text("\(rank + 1)").font(HuddleFont.heading(15)).foregroundColor(HuddleColors.textMuted)
            }
        }
        .frame(width: 32)
        .accessibilityLabel(L("Rank \(rank + 1)", "Peringkat \(rank + 1)"))
    }
}
