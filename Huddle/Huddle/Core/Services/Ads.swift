import AppTrackingTransparency
@preconcurrency import GoogleMobileAds
import StoreKit
import SwiftUI
import UIKit
@preconcurrency import UserMessagingPlatform

/// Ad unit ids. Only the App Store version shows real ads; Xcode and TestFlight copies show
/// Google's test ads, so testing never touches the real ones (tapping your own real ads can get
/// an AdMob account suspended). Pattern from Sudoku Harian.
enum AdIDs {
    /// TODO(owner): put Huddle's real AdMob units here (and the real app id as
    /// GADApplicationIdentifier in project.yml). While nil, every copy uses Google's test ads.
    static let live: (banner: String, interstitial: String)? = nil
    static let test = (banner: "ca-app-pub-3940256099942544/2934735716",
                       interstitial: "ca-app-pub-3940256099942544/4411468910")

    /// True only for a copy downloaded from the App Store. Unknown counts as not.
    static func isAppStoreCopy() async -> Bool {
        #if DEBUG
        return false
        #else
        guard case .verified(let t)? = try? await AppTransaction.shared else { return false }
        return t.environment == .production
        #endif
    }
}

/// AdMob: asks for consent where the law requires it, then the tracking prompt, then serves
/// a banner on the hub and a full-screen ad after every 2nd finished game — never during a round,
/// and nothing at all after the Remove Ads purchase.
@MainActor
final class Ads: NSObject, ObservableObject {
    /// Consent is settled and the SDK is running.
    @Published private(set) var ready = false
    /// The player is somewhere (such as the EU) where they must be able to change their consent later.
    @Published private(set) var privacyChoicesRequired = false
    weak var store: Store?
    /// Which ad units to use; decided once at start.
    private(set) var ids = AdIDs.test

    /// A full-screen ad after every this many finished games.
    private let gamesPerAd = 2
    private var gamesSinceAd = 0
    private var interstitial: InterstitialAd?
    private var afterAd: (() -> Void)?
    private var started = false

    private var adsRemoved: Bool { store?.adsRemoved ?? false }

    func start() async {
        guard !started else { return }
        started = true
        if let live = AdIDs.live, await AdIDs.isAppStoreCopy() { ids = live }
        // 1. Consent form (shown only in regions that require it, such as the EU and UK).
        try? await ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters())
        if let root = UIApplication.shared.topViewController {
            try? await ConsentForm.loadAndPresentIfRequired(from: root)
        }
        privacyChoicesRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        guard ConsentInformation.shared.canRequestAds else { return }
        // 2. Apple's tracking prompt. Ads still work if the player says no.
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            _ = await ATTrackingManager.requestTrackingAuthorization()
        }
        // 3. Start the SDK.
        _ = await MobileAds.shared.start()
        ready = true
        loadInterstitial()
    }

    /// Reopens Google's consent form so the player can change their choice.
    func showPrivacyChoices() async {
        guard let root = UIApplication.shared.topViewController else { return }
        try? await ConsentForm.presentPrivacyOptionsForm(from: root)
    }

    /// Call when the players leave a game's result screen. Sometimes shows a full-screen ad
    /// first; `then` runs when it closes (or straight away when there's no ad).
    func afterGame(then: @escaping () -> Void) {
        guard !adsRemoved, ready else { return then() }
        gamesSinceAd += 1
        guard gamesSinceAd >= gamesPerAd, let ad = interstitial,
              let root = UIApplication.shared.topViewController else { return then() }
        gamesSinceAd = 0
        afterAd = then
        interstitial = nil
        ad.present(from: root)
    }

    private func loadInterstitial() {
        guard ready, !adsRemoved, interstitial == nil else { return }
        let unit = ids.interstitial
        Task {
            guard let ad = try? await InterstitialAd.load(with: unit, request: Request()) else { return }
            ad.fullScreenContentDelegate = self
            interstitial = ad
        }
    }

    private func finishAd() {
        let then = afterAd
        afterAd = nil
        then?()
        loadInterstitial()
    }
}

extension Ads: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in self.finishAd() }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in self.finishAd() }
    }
}

/// The banner at the bottom of the hub. Never shown inside a game.
struct AdBanner: View {
    @EnvironmentObject var ads: Ads
    @EnvironmentObject var store: Store

    var body: some View {
        if ads.ready && !store.adsRemoved {
            GeometryReader { geo in
                let size = largeAnchoredAdaptiveBanner(width: geo.size.width)
                BannerContainer(size: size, unitID: ads.ids.banner).frame(height: size.size.height)
            }
            .frame(height: largeAnchoredAdaptiveBanner(width: min(UIScreen.main.bounds.width, Layout.maxWidth)).size.height)
        }
    }
}

private struct BannerContainer: UIViewRepresentable {
    let size: AdSize
    let unitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: size)
        banner.adUnitID = unitID
        banner.rootViewController = UIApplication.shared.topViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ banner: BannerView, context: Context) {}
}

extension UIApplication {
    /// The view controller on top, for presenting ads and consent forms.
    var topViewController: UIViewController? {
        let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        var top = (scene?.windows.first { $0.isKeyWindow } ?? scene?.windows.first)?.rootViewController
        while let next = top?.presentedViewController { top = next }
        return top
    }
}
