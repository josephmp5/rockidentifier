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
        PremiumFeature(icon: "camera.filters", title: "Advanced Identification", description: "Unlock higher accuracy and more detailed bug reports."),
        PremiumFeature(icon: "sparkles", title: "Unlimited Scans", description: "Identify as many bugs as you want, without limits."),
        PremiumFeature(icon: "bookmark.fill", title: "Save Favorites", description: "Keep a personalized collection of your most interesting finds."),
        PremiumFeature(icon: "leaf.arrow.triangle.circlepath", title: "Ad-Free Experience", description: "Enjoy BugLens without any interruptions.")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.edgesIgnoringSafeArea(.all)

                if !purchasesManager.isSDKConfigured {
                    ProgressView("Initializing...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                } else {
                    ScrollView {
                        paywallContent
                    }
                }

                if isPurchasing {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    ProgressView("Processing...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if canDismiss {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.gray)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .onReceive(timer) { _ in
                if isModal {
                    if countdown > 0 {
                        countdown -= 1
                    } else if !canDismiss {
                        canDismiss = true
                        timer.upstream.connect().cancel()
                    }
                } else {
                    canDismiss = true
                    timer.upstream.connect().cancel()
                }
            }
            .onAppear {
                if isModal && !canDismiss {
                    countdown = 5
                }
            }
            .onChange(of: purchasesManager.offerings) { newOfferings in
                guard let offerings = newOfferings, let premiumOffering = offerings.offering(identifier: "premium_offering") else { return }
                
                let weeklyPackage = premiumOffering.availablePackages.first { pkg in
                    let id = pkg.storeProduct.productIdentifier.lowercased()
                    let title = pkg.storeProduct.localizedTitle.lowercased()
                    return id.contains("weekly") || title.contains("weekly")
                }
                selectedPackage = weeklyPackage ?? premiumOffering.availablePackages.first
            }
        }
        .accentColor(Color.appThemePrimary)
        .navigationViewStyle(.stack)
    }

    private var paywallContent: some View {
        VStack(spacing: 20) {
            HeaderView()
            FeatureGridView(features: premiumFeatures).padding(.horizontal)
            if let offerings = purchasesManager.offerings, let premiumOffering = offerings.offering(identifier: "premium_offering") {
                Text("Choose Your Plan").font(.title2).bold().padding(.top)
                ForEach(premiumOffering.availablePackages) { pkg in
                    PackageButton(package: pkg, isSelected: pkg == selectedPackage) {
                        selectedPackage = pkg
                    }
                }
                .padding(.horizontal)
            } else {
                ProgressView("Loading plans...").padding()
            }
            PurchaseButton(isPurchasing: $isPurchasing, selectedPackage: $selectedPackage) {
                guard let packageToPurchase = selectedPackage else {
                    errorMessage = "Please select a package."
                    return
                }
                Task { await purchase(package: packageToPurchase) }
            }
            .padding(.top)
            RestoreButton { Task { await restore() } }.padding(.bottom, 20)
            if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red).multilineTextAlignment(.center).padding()
            }
            TermsAndPrivacyView().padding(.bottom, 40)
        }
        .padding(.vertical)
    }

    func purchase(package: Package) async {
        isPurchasing = true
        errorMessage = nil
        do {
            let customerInfo = try await purchasesManager.purchasePackage(package)
            if customerInfo.entitlements[purchasesManager.premiumEntitlementID]?.isActive == true {
                dismiss()
            } else {
                errorMessage = "Purchase was successful, but premium access is not active."
            }
        } catch ErrorCode.paymentPendingError {
            errorMessage = "Your payment is pending."
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
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
            } else {
                errorMessage = "No active subscriptions found."
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
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

struct HeaderView: View {
    var body: some View {
        VStack {
            Image(systemName: "lock.shield.fill")
                .resizable().scaledToFit().frame(width: 60, height: 60)
                .foregroundColor(Color.appThemePrimary).padding(.bottom, 5)
            Text("Unlock BugLens Premium").font(.largeTitle).bold().multilineTextAlignment(.center).foregroundColor(Color.themeText)
            Text("Get unlimited access to all features and identify bugs like a pro!").font(.headline).foregroundColor(Color.themeSecondaryText).multilineTextAlignment(.center).padding(.horizontal, 30)
        }.padding(.top, 20)
    }
}

struct FeatureGridView: View {
    let features: [PremiumFeature]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(features) { feature in
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: feature.icon).font(.title2).foregroundColor(Color.appThemePrimary).frame(width: 30, alignment: .leading)
                    Text(feature.title).font(.headline).foregroundColor(Color.themeText)
                    Text(feature.description).font(.caption).foregroundColor(Color.themeSecondaryText).lineLimit(2, reservesSpace: true)
                }
                .frame(minHeight: 120, alignment: .topLeading).padding(12).background(Color.themeSecondaryBackground).cornerRadius(10)
            }
        }.padding(.top)
    }
}

struct PackageButton: View {
    let package: Package
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(package.storeProduct.localizedTitle).font(.headline).foregroundColor(isSelected ? .white : Color.themeText)
                    Text(package.storeProduct.localizedPriceString + priceSuffix(package: package)).font(.subheadline).foregroundColor(isSelected ? .white.opacity(0.8) : Color.themeSecondaryText)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle").foregroundColor(isSelected ? .white : Color.appThemePrimary).font(.title2)
            }
            .padding().background(isSelected ? Color.appThemePrimary : Color.themeCardBackground).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : Color.appThemePrimary.opacity(0.5), lineWidth: 1))
            .shadow(color: isSelected ? Color.appThemePrimary.opacity(0.3) : Color.black.opacity(0.1), radius: 5, y: 2)
        }
    }
    
    private func priceSuffix(package: Package) -> String {
        guard let period = package.storeProduct.subscriptionPeriod else { return "" }
        var suffix = ""
        if period.unit == .month, period.value == 1 { suffix = " / month" }
        else if period.unit == .year, period.value == 1 { suffix = " / year" }
        else { suffix = " for \(period.value) \(period.unit.debugDescription.lowercased())s" }
        if let intro = package.storeProduct.introductoryDiscount, intro.paymentMode == .freeTrial {
            suffix += " (after \(intro.subscriptionPeriod.value) \(intro.subscriptionPeriod.unit.debugDescription.lowercased()) free trial)"
        }
        return suffix
    }
}

struct PurchaseButton: View {
    @Binding var isPurchasing: Bool
    @Binding var selectedPackage: Package?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(selectedPackage == nil ? "Select a Plan Above" : "Continue").font(.headline).fontWeight(.bold).foregroundColor(.white).padding().frame(maxWidth: .infinity)
                .background(selectedPackage == nil ? Color.gray : Color.appThemePrimary).cornerRadius(12)
                .shadow(color: (selectedPackage == nil ? Color.gray : Color.appThemePrimary).opacity(0.4), radius: 8, y: 4)
        }
        .disabled(isPurchasing || selectedPackage == nil).padding(.horizontal, 30)
    }
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