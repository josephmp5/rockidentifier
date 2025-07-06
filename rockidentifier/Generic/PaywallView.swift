import SwiftUI
import RevenueCat

struct PaywallView: View {
    @EnvironmentObject var purchasesManager: PurchasesManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String? = nil
    @State private var countdown: Int = 5
    @State private var canDismiss: Bool
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var isModal: Bool

    init(isModal: Bool = false) {
        self.isModal = isModal
        self._canDismiss = State(initialValue: !isModal)
    }

    let premiumFeatures: [PremiumFeature] = [
        PremiumFeature(icon: "sparkles", title: "AI-Powered Precision", description: "Get the most accurate rock identifications."),
        PremiumFeature(icon: "infinity.circle.fill", title: "Unlimited Identifications", description: "Scan and identify as many rocks as you find."),
        PremiumFeature(icon: "rhombus.fill", title: "Build Your Collection", description: "Save every discovery to your personal journal."),
        PremiumFeature(icon: "eye.slash.fill", title: "Ad-Free Exploration", description: "Enjoy a focused experience without interruptions.")
    ]

    var body: some View {
        ZStack {
            // Background
            ThemeColors.background
                .edgesIgnoringSafeArea(.all)

            // Main Content
            VStack {
                if isModal {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing)
                    .padding(.top)
                }

                ScrollView(showsIndicators: false) {
                    paywallContent
                }
            }
            .edgesIgnoringSafeArea(.bottom)

            // Loading / Purchasing Overlay
            if isPurchasing || !purchasesManager.isSDKConfigured {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text(isPurchasing ? "Processing..." : "Initializing...")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            // Automatically select the first available package
            if let firstPackage = purchasesManager.offerings?.current?.availablePackages.first {
                selectedPackage = firstPackage
            }
        }
    }

    private var paywallContent: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 8) {
                Text("Unlock Crystara Premium")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                Text("Experience the full power of rock identification.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, isModal ? 0 : 60)
            .padding(.horizontal)

            // Features
            VStack(alignment: .leading, spacing: 20) {
                ForEach(premiumFeatures) { feature in
                    HStack(spacing: 15) {
                        Image(systemName: feature.icon)
                            .font(.title2)
                            .foregroundColor(ThemeColors.primaryAction)
                            .frame(width: 35)
                        VStack(alignment: .leading) {
                            Text(feature.title).bold()
                            Text(feature.description)
                                .foregroundColor(.white.opacity(0.8))
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .padding(.horizontal)
            
            // Spacer to push content up
            Spacer()
        }
        .padding(.bottom, 250) // Pushes content up to make space for sticky footer
        .foregroundColor(.white)
        .overlay(
            // Sticky Footer
            VStack(spacing: 20) {
                // Package Selection
                if let packages = purchasesManager.offerings?.current?.availablePackages {
                    ForEach(packages) { pkg in
                        Button(action: { selectedPackage = pkg }) {
                            HStack {
                                Text(pkg.storeProduct.localizedTitle)
                                Spacer()
                                Text(pkg.localizedPriceString)
                            }
                            .font(.headline.bold())
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(selectedPackage == pkg ? ThemeColors.primaryAction : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }

                // Purchase Button
                Button(action: { 
                    guard let package = selectedPackage else { return }
                    Task { await purchase(package: package) }
                }) {
                    Text("Unlock Premium")
                        .font(.headline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primaryAction)
                        .cornerRadius(15)
                }
                .disabled(isPurchasing || selectedPackage == nil)

                // Restore & Terms
                VStack {
                    Button(action: { Task { await restore() } }) {
                        Text("Restore Purchase")
                            .font(.footnote)
                    }
                    Text("Terms and Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .padding(.top)
            .background(.ultraThinMaterial)
            .edgesIgnoringSafeArea(.bottom)
            , alignment: .bottom
        )
    }

    func purchase(package: Package) async {
        isPurchasing = true
        errorMessage = nil
        do {
            let customerInfo = try await purchasesManager.purchasePackage(package)
            if customerInfo.entitlements[purchasesManager.premiumEntitlementID]?.isActive == true {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            // Optionally, show an alert here
        }
        isPurchasing = false
    }

    func restore() async {
        isPurchasing = true
        errorMessage = nil
        do {
            let customerInfo = try await purchasesManager.restorePurchases()
            if customerInfo.entitlements[purchasesManager.premiumEntitlementID]?.isActive == true {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            // Optionally, show an alert here
        }
        isPurchasing = false
    }
}

// MARK: - Subviews for Paywall

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct RestoreButton: View {
    let action: () -> Void
    var body: some View {
        Button("Restore Purchases", action: action).font(.subheadline).foregroundColor(Color.appThemePrimary)
    }
}

struct TermsAndPrivacyView: View {
    var body: some View {
        VStack(spacing: 5) {
            Text("By continuing, you agree to our").font(.caption2).foregroundColor(.gray)
            HStack {
                Link("Terms of Service", destination: URL(string: "https://www.example.com/terms")!)
                Text("&")
                Link("Privacy Policy", destination: URL(string: "https://www.example.com/privacy")!)
            }.font(.caption2).foregroundColor(Color.appThemePrimary)
        }
    }
}


// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(PurchasesManager.shared)
    }
}