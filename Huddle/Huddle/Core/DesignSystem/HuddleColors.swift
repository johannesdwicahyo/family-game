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

enum HuddleColors {
    static let background = Color(hex: "#0d0d1a")
    static let cardBackground = Color(hex: "#12121f")
    static let cardBorder = Color(hex: "#1e1e30")
    static let impostor = Color(hex: "#FF6B6B")
    static let wordBomb = Color(hex: "#4D96FF")
    static let whoAmI = Color(hex: "#6BCB77")
    static let mostLikelyTo = Color(hex: "#FFD93D")
    static let roulette = Color(hex: "#9B59B6")
    static let textPrimary = Color(hex: "#F0F0F0")
    static let textSecondary = Color(hex: "#888888")
    static let textMuted = Color(hex: "#555555")
}
