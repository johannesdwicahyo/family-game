import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

/// Light, cheerful palette (v2). Every accent is at least 4.5:1 against the cream page and
/// white cards, so it works as text and as a button fill with white text (WCAG AA).
enum HuddleColors {
    // Surfaces
    static let background = Color(hex: "#FAF7F2")     // calm off-white page
    static let cardBackground = Color(hex: "#FFFFFF")
    static let cardBorder = Color(hex: "#ECE6DC")
    static let sunny = Color(hex: "#FFF0C2")          // decorative wash, never behind small text alone
    static let gold = Color(hex: "#F5B700")           // sunflower: fills with ink text (8.9:1); text in gold uses mostLikelyTo
    static let shadow = Color(hex: "#1F1A2E").opacity(0.08)

    // Per-game accents
    static let impostor = Color(hex: "#C8302A")
    static let wordBomb = Color(hex: "#1F6FD1")
    static let whoAmI = Color(hex: "#187A42")
    static let mostLikelyTo = Color(hex: "#9A5A00")
    static let roulette = Color(hex: "#8A3FC7")
    static let emoji = Color(hex: "#C2410C")
    static let wordChain = Color(hex: "#0E7F74")
    static let spy = Color(hex: "#5B4BDB")
    static let twoLies = Color(hex: "#C42A7A")

    // Meaning
    static let danger = Color(hex: "#C8302A")
    static let success = Color(hex: "#187A42")
    static let warning = Color(hex: "#9A5A00")

    // Text
    static let textPrimary = Color(hex: "#1F1A2E")
    static let textSecondary = Color(hex: "#5E5470")
    static let textMuted = Color(hex: "#6B6280")
}

extension Color {
    /// The fill to use for a button or chip in this accent: Most Likely To fills sunflower gold.
    var fillTone: Color { self == HuddleColors.mostLikelyTo ? HuddleColors.gold : self }
    /// Text on that fill: ink on gold, white on every other accent (all ≥ 4.5:1).
    var onFill: Color { self == HuddleColors.mostLikelyTo ? HuddleColors.textPrimary : .white }
}

enum Layout {
    /// Content column width on iPad; phones use the full width.
    static let maxWidth: CGFloat = 700
}
