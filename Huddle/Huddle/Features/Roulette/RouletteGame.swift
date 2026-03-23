import SwiftUI

@Observable class RouletteGame {
    enum Phase: Equatable {
        case edit, spinning, result
    }

    var phase: Phase = .edit
    var title: String = "Roulette"
    var items: [String] = []
    var isSpinning: Bool = false
    var currentAngle: Double = 0
    var targetAngle: Double = 0
    var spinStartDate: Date?
    var winnerIndex: Int?
    var winnerText: String?
    var history: [(text: String, date: Date)] = []

    static let presets: [(name: String, items: [String])] = [
        ("Truth or Dare", ["Truth", "Dare", "Truth", "Dare", "Double Dare", "Free Pass"]),
        ("Punishments", ["10 Push-ups", "Dance 30s", "Impersonate someone", "Sing a song", "Eat something spicy", "Call someone", "Post IG story", "Hold laugh 1 min"]),
        ("Numbers 1-10", (1...10).map { String($0) }),
        ("Food Choices", ["Nasi Goreng", "Bakso", "Sate", "Pizza", "Sushi", "Mie Ayam", "Martabak", "Gado-gado"]),
    ]

    static let segmentColors: [Color] = [
        Color(hex: "#FF6B6B"), Color(hex: "#6BCB77"), Color(hex: "#FFD93D"),
        Color(hex: "#4D96FF"), Color(hex: "#FF8C00"), Color(hex: "#00D4FF"),
        Color(hex: "#FF69B4"), Color(hex: "#7B68EE"), Color(hex: "#00FA9A"),
        Color(hex: "#FFD700"), Color(hex: "#FF6347"), Color(hex: "#40E0D0"),
    ]

    private let defaultsKeyItems = "roulette_items"
    private let defaultsKeyTitle = "roulette_title"

    init() {
        loadFromDefaults()
        if items.isEmpty {
            let preset = Self.presets[0]
            title = preset.name
            items = preset.items
        }
    }

    func addItem(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(trimmed)
        saveToDefaults()
    }

    func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        saveToDefaults()
    }

    func loadPreset(_ preset: (name: String, items: [String])) {
        title = preset.name
        items = preset.items
        saveToDefaults()
    }

    func spin() {
        guard items.count >= 2 else { return }

        // Pre-determine the winner
        let count = items.count
        let sliceAngle = 360.0 / Double(count)
        let winIdx = Int.random(in: 0..<count)

        // Calculate the angle that places this segment at the TOP pointer
        // Pointer is at top (270° in standard math). Segment 0 starts at the right (0°).
        // The wheel rotates clockwise with positive angles.
        // To land segment winIdx at top: the middle of that segment needs to be at 270°
        let segmentMidAngle = Double(winIdx) * sliceAngle + sliceAngle / 2
        // We need to rotate so that segmentMidAngle ends up at 270° (top)
        // finalAngle mod 360 should equal (270 - segmentMidAngle) mod 360
        let landingAngle = (270.0 - segmentMidAngle).truncatingRemainder(dividingBy: 360)
        let normalizedLanding = landingAngle < 0 ? landingAngle + 360 : landingAngle

        let fullRotations = Double(Int.random(in: 5...8)) * 360
        targetAngle = currentAngle + fullRotations + normalizedLanding - currentAngle.truncatingRemainder(dividingBy: 360)
        // Add small random offset within the segment so it doesn't always land dead center
        targetAngle += Double.random(in: -sliceAngle * 0.3 ... sliceAngle * 0.3)

        winnerIndex = winIdx
        winnerText = items[winIdx]

        isSpinning = true
        phase = .spinning
        spinStartDate = Date()
    }

    func finishSpin() {
        isSpinning = false
        currentAngle = targetAngle
        phase = .result

        if let text = winnerText {
            history.insert((text: text, date: Date()), at: 0)
            if history.count > 10 {
                history = Array(history.prefix(10))
            }
        }

        HapticManager.success()
    }

    func reset() {
        winnerIndex = nil
        winnerText = nil
        phase = .edit
    }

    func saveToDefaults() {
        UserDefaults.standard.set(items, forKey: defaultsKeyItems)
        UserDefaults.standard.set(title, forKey: defaultsKeyTitle)
    }

    func loadFromDefaults() {
        if let saved = UserDefaults.standard.stringArray(forKey: defaultsKeyItems) {
            items = saved
        }
        if let saved = UserDefaults.standard.string(forKey: defaultsKeyTitle) {
            title = saved
        }
    }
}
