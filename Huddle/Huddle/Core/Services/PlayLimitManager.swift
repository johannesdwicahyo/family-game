import Foundation

@Observable class PlayLimitManager {
    private let defaults = UserDefaults.standard
    private let playsKey = "huddle_plays_today"
    private let dateKey = "huddle_plays_date"
    private let maxFreePlays = 3

    var playsToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: playsKey)
    }

    var remainingPlays: Int {
        max(0, maxFreePlays - playsToday)
    }

    func canPlay(isProUser: Bool) -> Bool {
        isProUser || playsToday < maxFreePlays
    }

    func recordPlay() {
        resetIfNewDay()
        defaults.set(playsToday + 1, forKey: playsKey)
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let stored = defaults.object(forKey: dateKey) as? Date ?? .distantPast
        let storedDay = Calendar.current.startOfDay(for: stored)
        if today > storedDay {
            defaults.set(0, forKey: playsKey)
            defaults.set(today, forKey: dateKey)
        }
    }
}
