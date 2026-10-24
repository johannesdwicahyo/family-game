import StoreKit

/// The one in-app purchase: Remove Ads (non-consumable, StoreKit 2). Pattern from Sudoku Harian.
@MainActor
final class Store: ObservableObject {
    /// Must match the product created in App Store Connect (and StoreKit/Huddle.storekit for testing).
    static let removeAdsID = "com.johannesdwicahyo.Huddle.removeads"
    private static let cacheKey = "adsRemoved"

    @Published private(set) var product: Product?
    /// Cached so ads don't flash on launch; confirmed against the App Store on every start.
    @Published private(set) var adsRemoved = UserDefaults.standard.bool(forKey: Store.cacheKey) {
        didSet { UserDefaults.standard.set(adsRemoved, forKey: Self.cacheKey) }
    }
    @Published private(set) var busy = false
    @Published var message: String?

    private var updates: Task<Void, Never>?

    init() {
        // Purchases finished elsewhere (another device, Ask to Buy, refunds) arrive here.
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let t) = result { await t.finish() }
                await self?.refresh()
            }
        }
        Task {
            await loadProduct()
            await refresh()
        }
    }

    deinit { updates?.cancel() }

    func loadProduct() async {
        product = try? await Product.products(for: [Self.removeAdsID]).first
    }

    /// Checks what this Apple ID owns.
    func refresh() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Self.removeAdsID, t.revocationDate == nil { owned = true }
        }
        adsRemoved = owned
    }

    func buy() async {
        if product == nil { await loadProduct() }
        guard let product else {
            message = L("The App Store isn't available right now. Please try again later.",
                        "App Store sedang tidak tersedia. Coba lagi nanti.")
            return
        }
        busy = true
        defer { busy = false }
        do {
            switch try await product.purchase() {
            case .success(.verified(let t)):
                await t.finish()
                await refresh()
            case .success(.unverified):
                message = L("The purchase couldn't be verified.", "Pembelian tidak dapat diverifikasi.")
            case .pending:
                message = L("Waiting for approval. Ads go away once it's approved.",
                            "Menunggu persetujuan. Iklan hilang setelah disetujui.")
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            message = error.localizedDescription
        }
    }

    /// For a new phone or a reinstall: asks the App Store for past purchases.
    func restore() async {
        busy = true
        defer { busy = false }
        try? await AppStore.sync()
        await refresh()
        message = adsRemoved
            ? L("Purchase restored. Ads are off.", "Pembelian dipulihkan. Iklan dimatikan.")
            : L("No purchase found for this Apple ID.", "Tidak ada pembelian untuk Apple ID ini.")
    }
}
