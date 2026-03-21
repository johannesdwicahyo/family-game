import SwiftUI

struct PaywallView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🎉")
                .font(.system(size: 64))

            Text("HUDDLE PRO")
                .font(HuddleFont.display(36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [HuddleColors.impostor, HuddleColors.mostLikelyTo, HuddleColors.whoAmI, HuddleColors.wordBomb],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text("You've used your 3 free games today!")
                .font(HuddleFont.body())
                .foregroundColor(HuddleColors.textSecondary)
                .multilineTextAlignment(.center)

            // Feature comparison
            VStack(spacing: 12) {
                featureRow("Unlimited plays", free: "3/day", pro: "Unlimited")
                featureRow("Languages", free: "2", pro: "All")
                featureRow("New games first", free: "—", pro: "✓")
            }
            .padding(16)
            .background(HuddleColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Pricing buttons
            VStack(spacing: 10) {
                pricingButton("Yearly", price: "$19.99/year", badge: "BEST VALUE", highlighted: true)
                pricingButton("Monthly", price: "$3.99/month", badge: "3-day free trial", highlighted: false)
                pricingButton("Weekly", price: "$1.99/week", badge: nil, highlighted: false)
            }

            Spacer()

            Button("Maybe Later") {
                dismiss()
            }
            .font(HuddleFont.caption())
            .foregroundColor(HuddleColors.textMuted)

            Text("Restore Purchases")
                .font(HuddleFont.caption(10))
                .foregroundColor(HuddleColors.textMuted)
                .underline()
                .onTapGesture {
                    // TODO: StoreKit restore
                }

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HuddleColors.background)
    }

    private func featureRow(_ feature: String, free: String, pro: String) -> some View {
        HStack {
            Text(feature)
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(free)
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.textMuted)
                .frame(width: 60)
            Text(pro)
                .font(HuddleFont.caption())
                .foregroundColor(HuddleColors.mostLikelyTo)
                .frame(width: 60)
        }
    }

    private func pricingButton(_ tier: String, price: String, badge: String?, highlighted: Bool) -> some View {
        Button {
            // TODO: StoreKit purchase
            HapticManager.tap()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(tier)
                        .font(HuddleFont.heading(16))
                        .foregroundColor(.white)
                    Text(price)
                        .font(HuddleFont.caption())
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                if let badge {
                    Text(badge)
                        .font(HuddleFont.caption(9))
                        .foregroundColor(highlighted ? .black : .white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(highlighted ? HuddleColors.mostLikelyTo : .white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(highlighted ? HuddleColors.mostLikelyTo.opacity(0.3) : HuddleColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(highlighted ? HuddleColors.mostLikelyTo : HuddleColors.cardBorder, lineWidth: highlighted ? 2 : 1)
            )
        }
    }
}
