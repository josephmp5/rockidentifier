import SwiftUI
import RevenueCat
import SafariServices

struct PaywallView: View {
    @EnvironmentObject var purchasesManager: PurchasesManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedPackage: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String? = nil
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    @State private var timeRemaining = 5
    @State private var timer: Timer? = nil
    var isModal: Bool

    init(isModal: Bool = false) {
        self.isModal = isModal
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
                            if timeRemaining > 0 {
                                Text("\(timeRemaining)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                        .disabled(timeRemaining > 0)
                        .opacity(timeRemaining > 0 ? 0.8 : 1.0)
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
            // Automatically select the weekly package to promote it.
            if let weeklyPackage = purchasesManager.offerings?.current?.availablePackages.first(where: { $0.storeProduct.subscriptionPeriod?.unit == .week }) {
                selectedPackage = weeklyPackage
            } else if let firstPackage = purchasesManager.offerings?.current?.availablePackages.first {
                // Fallback to the first package if no weekly option is found
                selectedPackage = firstPackage
            }
            
            // Start the 5-second timer
            timeRemaining = 5
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
        .onDisappear {
            // Clean up the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: URL(string: "https://sites.google.com/view/rock-identifier-crystal/ana-sayfa")!)
        }
        .sheet(isPresented: $showingTermsOfUse) {
            SafariView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
    }

    private var paywallContent: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 8) {
                Text("Unlock Crystara Premium")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                Text("Experience the full power of rock identification.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(ThemeColors.secondaryText)
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
                                .foregroundColor(ThemeColors.secondaryText)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
            // Removed the ugly semi-transparent background

            // Spacer to push content up
            Spacer()
        }
        .padding(.bottom, 300) // Adjusted padding for new footer design
        .foregroundColor(ThemeColors.primaryText)
        .overlay(
            // Sticky Footer
            VStack(spacing: 15) {
                // Package Selection
                if let packages = purchasesManager.offerings?.current?.availablePackages {
                    VStack(spacing: 12) {
                        ForEach(packages) { pkg in
                            let isSelected = selectedPackage == pkg
                            Button(action: { selectedPackage = pkg }) {
                                HStack(spacing: 15) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(pkg.storeProduct.localizedTitle)
                                            .fontWeight(.bold)
                                        if pkg.storeProduct.subscriptionPeriod?.unit == .week {
                                            Text("Best Value")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(isSelected ? .white.opacity(0.8) : ThemeColors.primaryAction)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(pkg.localizedPriceString)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .foregroundColor(isSelected ? .white : ThemeColors.primaryText)
                                .background(isSelected ? ThemeColors.primaryAction : Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                }

                // Purchase Button
                Button(action: {
                    guard let package = selectedPackage else { return }
                    Task { await purchase(package: package) }
                }) {
                    Text("Unlock Premium")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primaryAction)
                        .cornerRadius(15)
                        .shadow(color: ThemeColors.primaryAction.opacity(0.4), radius: 8, y: 4)
                }
                .disabled(isPurchasing || selectedPackage == nil)

                // Subscription Information & Legal Links
                VStack(spacing: 12) {
                    // Restore Purchase
                    Button(action: { Task { await restore() } }) {
                        Text("Restore Purchase")
                            .font(.footnote)
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                    
                    // Subscription Details
                    VStack(spacing: 6) {
                        Text("Auto-renewing monthly subscription")
                            .font(.caption2)
                            .foregroundColor(ThemeColors.secondaryText)
                        
                        Text("Subscription automatically renews unless cancelled at least 24 hours before the end of the current period")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Legal Links
                    HStack(spacing: 20) {
                        Button(action: { showingPrivacyPolicy = true }) {
                            Text("Privacy Policy")
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryAction)
                                .underline()
                        }
                        
                        Button(action: { showingTermsOfUse = true }) {
                            Text("Terms of Use")
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryAction)
                                .underline()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .padding(.top, 20)
            .background(
                // Clean background with a top fade to blend with scrolling content
                VStack(spacing: 0) {
                    LinearGradient(gradient: Gradient(colors: [ThemeColors.background.opacity(0), ThemeColors.background]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 20)
                    Rectangle()
                        .fill(ThemeColors.background)
                }
                .edgesIgnoringSafeArea(.bottom)
            )
            , alignment: .bottom
        )
    }

    func purchase(package: Package) async {
        isPurchasing = true
        errorMessage = nil
        
        do {
            let customerInfo = try await purchasesManager.purchasePackage(package)
            
            // Always set isPurchasing to false on main thread
            await MainActor.run {
                self.isPurchasing = false
            }
            
            if customerInfo.entitlements[purchasesManager.premiumEntitlementID]?.isActive == true {
                print("Purchase successful, dismissing paywall")
                // Dismiss on main thread
                await MainActor.run {
                    self.dismiss()
                }
            }
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isPurchasing = false
            }
        }
    }

    func restore() async {
        isPurchasing = true
        errorMessage = nil
        
        do {
            let customerInfo = try await purchasesManager.restorePurchases()
            
            // Always set isPurchasing to false on main thread
            await MainActor.run {
                self.isPurchasing = false
            }
            
            if customerInfo.entitlements[purchasesManager.premiumEntitlementID]?.isActive == true {
                print("Restore successful, dismissing paywall")
                // Dismiss on main thread
                await MainActor.run {
                    self.dismiss()
                }
            }
        } catch {
            print("Restore failed: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isPurchasing = false
            }
        }
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