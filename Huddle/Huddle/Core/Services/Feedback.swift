import AVFoundation
import UIKit

/// Keys for the player's settings, stored in UserDefaults (views read them with @AppStorage).
enum Prefs {
    static let sound = "sound"
    static let haptics = "haptics"

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [sound: true, haptics: true])
    }
}

/// Sound effects and vibration, each switchable in Settings (pattern from Sudoku Harian).
/// Sounds come from scripts/make_sounds.py.
@MainActor
enum Feedback {
    enum Sound: String, CaseIterable {
        case start, tick, reveal, win, correct, wrong, boom
    }

    private static let players: [Sound: AVAudioPlayer] = {
        // Ambient: mixes with the player's music and stays quiet when the phone is on silent.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        var out: [Sound: AVAudioPlayer] = [:]
        for s in Sound.allCases {
            guard let url = Bundle.main.url(forResource: s.rawValue, withExtension: "wav"),
                  let p = try? AVAudioPlayer(contentsOf: url) else { continue }
            p.prepareToPlay()
            out[s] = p
        }
        return out
    }()

    private static var soundOn: Bool { UserDefaults.standard.bool(forKey: Prefs.sound) }
    private static var hapticsOn: Bool { UserDefaults.standard.bool(forKey: Prefs.haptics) }

    static func play(_ s: Sound) {
        guard soundOn, let p = players[s] else { return }
        p.currentTime = 0
        p.play()
    }

    static func tap() {
        guard hapticsOn else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        play(.correct)
        guard hapticsOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        play(.wrong)
        guard hapticsOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func win() {
        play(.win)
        guard hapticsOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func explosion() {
        play(.boom)
        guard hapticsOn else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            generator.impactOccurred(intensity: 1.0)
            try? await Task.sleep(for: .milliseconds(100))
            generator.impactOccurred(intensity: 0.7)
        }
    }
}
