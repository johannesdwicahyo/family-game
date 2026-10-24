import SwiftUI

@MainActor @Observable final class RouletteGame {
    enum Phase: Equatable {
        case edit, spinning, result
    }

    var phase: Phase = .edit
    var title: String = ""
    var items: [String] = []
    var isSpinning: Bool = false
    var currentAngle: Double = 0
    var targetAngle: Double = 0
    var spinStartDate: Date?
    var winnerIndex: Int?
    var winnerText: String?
    var history: [(text: String, date: Date)] = []

    /// Ready-made wheels, in the app's language. "Our players" uses the names typed in any game.
    static var presets: [(name: String, items: [String])] {
        let players = (UserDefaults.standard.stringArray(forKey: PlayerNamesEditor.key) ?? [])
            .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        var list: [(name: String, items: [String])] = []
        if players.count >= 2 { list.append((L("Our players", "Para pemain"), players)) }
        list += [
            (L("Who goes first?", "Siapa duluan?"), L("Youngest,Oldest,Tallest,Birthday soonest,Last to arrive,Closest to the phone", "Paling muda,Paling tua,Paling tinggi,Ulang tahun terdekat,Datang paling akhir,Paling dekat HP").components(separatedBy: ",")),
            (L("Fun dares", "Tantangan seru"), L("Sing a chorus,Dance for 10 seconds,Animal impression,Tell a joke,Compliment everyone,Talk like a robot,Strike a superhero pose,Do your best evil laugh", "Nyanyi reff lagu,Joget 10 detik,Tiru suara hewan,Ceritakan lelucon,Puji semua pemain,Bicara seperti robot,Pose superhero,Tawa jahat terbaik").components(separatedBy: ",")),
            (L("What's for dinner?", "Makan apa?"), L("Fried rice,Pizza,Noodles,Burgers,Sushi,Satay,Soup,Tacos", "Nasi goreng,Bakso,Sate,Mie ayam,Martabak,Gado-gado,Soto,Pecel lele").components(separatedBy: ",")),
            (L("Numbers 1–10", "Angka 1–10"), (1...10).map { String($0) }),
            (L("Yes or no", "Ya atau tidak"), L("Yes,No,Yes,No,Maybe,Ask again", "Ya,Tidak,Ya,Tidak,Mungkin,Putar lagi").components(separatedBy: ",")),
        ]
        return list
    }

    static let segmentColors: [Color] = [
        // Light, sunny segments that carry dark text.
        Color(hex: "#FF9E8F"), Color(hex: "#8FD4FF"), Color(hex: "#FFD866"),
        Color(hex: "#9EDBA8"), Color(hex: "#FFB98A"), Color(hex: "#D3A6F0"),
        Color(hex: "#86E0E6"), Color(hex: "#FFA3C8"), Color(hex: "#C9E79A"),
        Color(hex: "#FFE38F"), Color(hex: "#A7C4FF"), Color(hex: "#C4B5FD"),
    ]

    private let defaultsKeyItems = "roulette_items"
    private let defaultsKeyTitle = "roulette_title"

    init() {
        loadFromDefaults()
        if items.isEmpty, let preset = Self.presets.first(where: { $0.items.count > 2 }) {
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

        Feedback.success()
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
