import SwiftUI

@Observable class LocaleManager {
    var language: String = "en"

    func string(_ key: String) -> String {
        let strings = language == "id" ? indonesianStrings : englishStrings
        return strings[key] ?? key
    }

    private let englishStrings: [String: String] = [
        // Hub
        "hub.title": "HUDDLE",
        "hub.subtitle": "PARTY GAMES",
        "hub.plays_left": "plays left today",
        "hub.coming_soon": "Coming Soon",

        // Games
        "game.impostor": "Impostor",
        "game.wordbomb": "Word Bomb",
        "game.whoami": "Who Am I?",
        "game.mostlikelyto": "Most Likely To",
        "game.roulette": "Roulette",

        // Player Setup
        "setup.players": "Players",
        "setup.start": "START GAME",
        "setup.player_n": "Player",

        // Common
        "common.next_player": "NEXT PLAYER",
        "common.play_again": "PLAY AGAIN",
        "common.exit": "EXIT",
        "common.continue": "CONTINUE",
        "common.im_ready": "I'M READY",
        "common.hand_phone_to": "Hand the phone to",
        "common.dont_show": "Don't show this to anyone!",

        // Impostor
        "impostor.your_word": "YOUR WORD",
        "impostor.show_word": "SHOW MY WORD",
        "impostor.discussion": "DISCUSSION TIME!",
        "impostor.discuss_desc": "Discuss your words without saying them directly.\nWhen ready, start voting.",
        "impostor.start_voting": "START VOTING",
        "impostor.voting": "VOTING",
        "impostor.select_eliminated": "Select the eliminated player",
        "impostor.tap_most_voted": "Tap the player who got the most votes",
        "impostor.is_a": "is a",
        "impostor.game_continues": "Game continues! There's still an impostor among you.",
        "impostor.players_remaining": "players remaining",
        "impostor.see_results": "SEE RESULTS",
        "impostor.continue_discussion": "CONTINUE DISCUSSION",
        "impostor.civilians_win": "CIVILIANS WIN!",
        "impostor.impostor_wins": "IMPOSTOR WINS!",
        "impostor.mr_white_wins": "MR. WHITE WINS!",
        "impostor.eliminated": "Eliminated",
        "impostor.turn": "Turn",
        "impostor.mr_white_eliminated": "MR. WHITE ELIMINATED!",
        "impostor.guess_word": "Guess the civilian word to win!",
        "impostor.guess_placeholder": "Type your guess...",
        "impostor.guess_now": "GUESS NOW",
        "impostor.word_pair": "WORD PAIR",
        "impostor.civilian_word": "Civilian",
        "impostor.impostor_word": "Impostor",
        "impostor.no_word": "You have NO word.",
        "impostor.no_word_desc": "Listen carefully and blend in.\nIf eliminated, you can guess the word to win!",
        "impostor.joker_win": "You WIN if you get eliminated first!",
        "impostor.joker_banner": "JOKER WINS!",
        "impostor.joker_eliminated": "Got eliminated first!",
        "impostor.joker_continues": "Game continues! Others still need to find the Impostor.",

        // Impostor Setup
        "impostor.setup.roles": "Roles",
        "impostor.setup.scoring": "Scoring",
        "impostor.setup.civilian": "Civilian",
        "impostor.setup.impostor": "Impostor",
        "impostor.setup.joker": "Joker",
        "impostor.setup.mr_white": "Mr. White",
        "impostor.setup.total_players": "Total Players",
        "impostor.setup.min_players": "Minimum 3 players",
        "impostor.setup.civilian_desc": "Gets the civilian word. Find the impostor!",
        "impostor.setup.impostor_desc": "Gets a different word. Don't get caught!",
        "impostor.setup.joker_desc": "Gets civilian word. Goal: get eliminated first!",
        "impostor.setup.mr_white_desc": "Gets no word. If caught, guess to win!",

        // Word Bomb
        "wordbomb.type_word": "Type a word containing",
        "wordbomb.submit": "SUBMIT",
        "wordbomb.difficulty": "Difficulty",
        "wordbomb.easy": "Easy",
        "wordbomb.medium": "Medium",
        "wordbomb.hard": "Hard",
        "wordbomb.lives": "Lives",
        "wordbomb.boom": "BOOM!",
        "wordbomb.eliminated": "ELIMINATED!",
        "wordbomb.lives_left": "lives left",
        "wordbomb.winner": "WINNER!",
        "wordbomb.last_standing": "Last one standing!",
        "wordbomb.total_words": "Total Words",
        "wordbomb.longest_word": "Longest Word",
        "wordbomb.must_contain": "Word must contain",
        "wordbomb.already_used": "Word already used!",
        "wordbomb.too_short": "Minimum 3 characters!",

        // Who Am I
        "whoami.category": "Category",
        "whoami.mixed": "Mixed",
        "whoami.timer": "Timer",
        "whoami.rounds": "Rounds per player",
        "whoami.start": "START",
        "whoami.correct": "CORRECT",
        "whoami.skip": "SKIP",
        "whoami.time_up": "Time's up!",
        "whoami.correct_count": "correct",
        "whoami.skipped_count": "skipped",

        // Most Likely To
        "mlt.rounds": "Rounds",
        "mlt.transparency": "Show who voted",
        "mlt.start_voting": "START VOTING",
        "mlt.next_question": "NEXT QUESTION",
        "mlt.titles": "titles",
        "mlt.round_history": "Round History",

        // Roulette
        "roulette.add_item": "Add item...",
        "roulette.add": "ADD",
        "roulette.spin": "SPIN!",
        "roulette.spin_again": "SPIN AGAIN",
        "roulette.edit": "EDIT",
        "roulette.presets": "Presets",
        "roulette.history": "History",
        "roulette.clear_history": "Clear History",
        "roulette.min_items": "Add at least 2 items",

        // Settings
        "settings.title": "Settings",
        "settings.language": "Language",
        "settings.subscription": "Subscription",
        "settings.about": "About",
        "settings.free_plan": "Free Plan",
        "settings.pro": "Huddle Pro",
        "settings.unlimited": "Unlimited plays",
        "settings.upgrade": "UPGRADE",
        "settings.version": "Version",
        "settings.games": "Games",
        "settings.languages": "Languages",
        "settings.done": "Done",
    ]

    private let indonesianStrings: [String: String] = [
        // Hub
        "hub.title": "HUDDLE",
        "hub.subtitle": "PERMAINAN PESTA",
        "hub.plays_left": "sisa main hari ini",
        "hub.coming_soon": "Segera Hadir",

        // Games
        "game.impostor": "Impostor",
        "game.wordbomb": "Bom Kata",
        "game.whoami": "Siapa Aku?",
        "game.mostlikelyto": "Siapa Yang Paling",
        "game.roulette": "Roulette",

        // Player Setup
        "setup.players": "Pemain",
        "setup.start": "MULAI GAME",
        "setup.player_n": "Pemain",

        // Common
        "common.next_player": "PEMAIN BERIKUTNYA",
        "common.play_again": "MAIN LAGI",
        "common.exit": "KELUAR",
        "common.continue": "LANJUT",
        "common.im_ready": "AKU SIAP",
        "common.hand_phone_to": "Serahkan HP ke",
        "common.dont_show": "Jangan tunjukkan ke siapapun!",

        // Impostor
        "impostor.your_word": "KATAMU",
        "impostor.show_word": "LIHAT KATAKU",
        "impostor.discussion": "WAKTU DISKUSI!",
        "impostor.discuss_desc": "Diskusikan kata kalian tanpa menyebutkannya langsung.\nSetelah selesai, mulai voting.",
        "impostor.start_voting": "MULAI VOTING",
        "impostor.voting": "VOTING",
        "impostor.select_eliminated": "Pilih pemain yang tereliminasi",
        "impostor.tap_most_voted": "Tap pemain yang paling banyak di-vote",
        "impostor.is_a": "adalah",
        "impostor.game_continues": "Game berlanjut! Masih ada impostor di antara kalian.",
        "impostor.players_remaining": "pemain tersisa",
        "impostor.see_results": "LIHAT HASIL",
        "impostor.continue_discussion": "LANJUT DISKUSI",
        "impostor.civilians_win": "WARGA MENANG!",
        "impostor.impostor_wins": "IMPOSTOR MENANG!",
        "impostor.mr_white_wins": "MR. WHITE MENANG!",
        "impostor.eliminated": "Tereliminasi",
        "impostor.turn": "Giliran",
        "impostor.mr_white_eliminated": "MR. WHITE DIELIMINASI!",
        "impostor.guess_word": "Tebak kata warga untuk menang!",
        "impostor.guess_placeholder": "Ketik tebakanmu...",
        "impostor.guess_now": "TEBAK SEKARANG",
        "impostor.word_pair": "PASANGAN KATA",
        "impostor.civilian_word": "Warga",
        "impostor.impostor_word": "Impostor",
        "impostor.no_word": "Kamu tidak dapat kata.",
        "impostor.no_word_desc": "Ikuti diskusi dan coba tebak!\nKalau dieliminasi, tebak kata warga untuk menang!",
        "impostor.joker_win": "Kamu MENANG kalau dieliminasi pertama!",
        "impostor.joker_banner": "JOKER MENANG!",
        "impostor.joker_eliminated": "Berhasil dieliminasi pertama!",
        "impostor.joker_continues": "Game berlanjut! Pemain lain masih harus cari Impostor.",

        // Impostor Setup
        "impostor.setup.roles": "Peran",
        "impostor.setup.scoring": "Penilaian",
        "impostor.setup.civilian": "Warga",
        "impostor.setup.impostor": "Impostor",
        "impostor.setup.joker": "Joker",
        "impostor.setup.mr_white": "Mr. White",
        "impostor.setup.total_players": "Total Pemain",
        "impostor.setup.min_players": "Minimal 3 pemain",
        "impostor.setup.civilian_desc": "Dapat kata warga. Temukan impostornya!",
        "impostor.setup.impostor_desc": "Katamu berbeda! Coba tidak ketahuan.",
        "impostor.setup.joker_desc": "Katamu sama warga. Goal: dieliminasi pertama!",
        "impostor.setup.mr_white_desc": "Tidak dapat kata. Kalau tertangkap, tebak untuk menang!",

        // Word Bomb
        "wordbomb.type_word": "Ketik kata yang mengandung",
        "wordbomb.submit": "KIRIM",
        "wordbomb.difficulty": "Tingkat Kesulitan",
        "wordbomb.easy": "Mudah",
        "wordbomb.medium": "Sedang",
        "wordbomb.hard": "Sulit",
        "wordbomb.lives": "Nyawa",
        "wordbomb.boom": "BOOM!",
        "wordbomb.eliminated": "TERELIMINASI!",
        "wordbomb.lives_left": "nyawa tersisa",
        "wordbomb.winner": "PEMENANG!",
        "wordbomb.last_standing": "Pemain terakhir yang bertahan!",
        "wordbomb.total_words": "Total Kata",
        "wordbomb.longest_word": "Kata Terpanjang",
        "wordbomb.must_contain": "Kata harus mengandung",
        "wordbomb.already_used": "Kata sudah dipakai!",
        "wordbomb.too_short": "Minimal 3 huruf!",

        // Who Am I
        "whoami.category": "Kategori",
        "whoami.mixed": "Campur",
        "whoami.timer": "Waktu",
        "whoami.rounds": "Ronde per pemain",
        "whoami.start": "MULAI",
        "whoami.correct": "BENAR",
        "whoami.skip": "LEWATI",
        "whoami.time_up": "Waktu habis!",
        "whoami.correct_count": "benar",
        "whoami.skipped_count": "dilewati",

        // Most Likely To
        "mlt.rounds": "Ronde",
        "mlt.transparency": "Tampilkan siapa yang vote",
        "mlt.start_voting": "MULAI VOTING",
        "mlt.next_question": "PERTANYAAN BERIKUTNYA",
        "mlt.titles": "gelar",
        "mlt.round_history": "Riwayat Ronde",

        // Roulette
        "roulette.add_item": "Tambah item...",
        "roulette.add": "TAMBAH",
        "roulette.spin": "PUTAR!",
        "roulette.spin_again": "PUTAR LAGI",
        "roulette.edit": "EDIT",
        "roulette.presets": "Preset",
        "roulette.history": "Riwayat",
        "roulette.clear_history": "Hapus Riwayat",
        "roulette.min_items": "Tambah minimal 2 item",

        // Settings
        "settings.title": "Pengaturan",
        "settings.language": "Bahasa",
        "settings.subscription": "Langganan",
        "settings.about": "Tentang",
        "settings.free_plan": "Paket Gratis",
        "settings.pro": "Huddle Pro",
        "settings.unlimited": "Main tanpa batas",
        "settings.upgrade": "UPGRADE",
        "settings.version": "Versi",
        "settings.games": "Permainan",
        "settings.languages": "Bahasa",
        "settings.done": "Selesai",
    ]
}
