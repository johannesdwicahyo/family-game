import SwiftUI

struct GameDefinition: Identifiable, Sendable {
    let id: String
    let names: (en: String, id: String)
    let blurbs: (en: String, id: String)
    let accentColor: Color
    let playerRange: ClosedRange<Int>
    /// Painted card illustration in the asset catalog, when there is one yet.
    let art: String?
    /// Stand-in until the card has art.
    let symbol: String

    var name: String { L(names.en, names.id) }
    var description: String { L(blurbs.en, blurbs.id) }

    static func find(_ id: String) -> GameDefinition { allGames.first { $0.id == id }! }

    static let allGames: [GameDefinition] = [
        GameDefinition(id: "impostor", names: ("Impostor", "Impostor"),
                       blurbs: ("Find who got a different word", "Cari siapa yang katanya beda"),
                       accentColor: HuddleColors.impostor, playerRange: 3...12, art: "Card-impostor", symbol: "theatermasks.fill"),
        GameDefinition(id: "spy", names: ("Spy Location", "Mata-Mata"),
                       blurbs: ("Everyone knows the place except the spy", "Semua tahu tempatnya, kecuali si mata-mata"),
                       accentColor: HuddleColors.spy, playerRange: 3...12, art: "Card-spy", symbol: "magnifyingglass"),
        GameDefinition(id: "wordbomb", names: ("Word Bomb", "Bom Kata"),
                       blurbs: ("Type a word before the bomb blows", "Ketik kata sebelum bomnya meledak"),
                       accentColor: HuddleColors.wordBomb, playerRange: 2...8, art: "Card-wordbomb", symbol: "flame.fill"),
        GameDefinition(id: "mostlikelyto", names: ("Most Likely To", "Siapa Paling…"),
                       blurbs: ("Vote who fits the question best", "Pilih siapa yang paling cocok"),
                       accentColor: HuddleColors.mostLikelyTo, playerRange: 3...12, art: "Card-mostlikelyto", symbol: "crown.fill"),
        GameDefinition(id: "whoami", names: ("Who Am I?", "Siapa Aku?"),
                       blurbs: ("Phone on your forehead, guess who you are", "HP di dahi, tebak kamu siapa"),
                       accentColor: HuddleColors.whoAmI, playerRange: 2...12, art: "Card-whoami", symbol: "person.fill.questionmark"),
        GameDefinition(id: "emoji", names: ("Emoji Riddles", "Tebak Emoji"),
                       blurbs: ("Shout the answer the emoji spell out", "Teriakkan jawaban dari emojinya"),
                       accentColor: HuddleColors.emoji, playerRange: 2...12, art: "Card-emoji", symbol: "face.smiling.inverse"),
        GameDefinition(id: "twolies", names: ("Two Lies", "Dua Bohong"),
                       blurbs: ("Two lies, one truth: spot the truth", "Dua bohong, satu jujur: tebak yang jujur"),
                       accentColor: HuddleColors.twoLies, playerRange: 3...10, art: "Card-twolies", symbol: "hand.raised.fingers.spread.fill"),
        GameDefinition(id: "wordchain", names: ("Word Chain", "Sambung Kata"),
                       blurbs: ("Start your word with the last letters", "Mulai katamu dari huruf terakhir"),
                       accentColor: HuddleColors.wordChain, playerRange: 2...8, art: "Card-wordchain", symbol: "link"),
        GameDefinition(id: "roulette", names: ("Spin the Wheel", "Roda Putar"),
                       blurbs: ("A custom wheel for dares and decisions", "Roda pilihan untuk tantangan & keputusan"),
                       accentColor: HuddleColors.roulette, playerRange: 1...99, art: "Card-roulette", symbol: "circle.circle.fill"),
    ]
}
