import Foundation
import RevenueCat
import SwiftUI
import FirebaseFirestore // For database updates
import FirebaseAuth     // To get the current user's ID

// Conform to PurchasesDelegate
class PurchasesManager: NSObject, ObservableObject, PurchasesDelegate {
    static let shared = PurchasesManager()

    @Published var offerings: Offerings? = nil
    @Published var isSDKConfigured = false
    @Published var isPremium = false

    let premiumEntitlementID = "premium"
    private var db = Firestore.firestore()

    private override init() { // Private to ensure singleton, override for NSObject
        super.init()
        print("PurchasesManager instance created.")
    }

    /// This method should be called only after the Purchases SDK has been configured.
    func initializeData() {
        print("SDK configured. Setting delegate and initializing PurchasesManager data.")
        Purchases.shared.delegate = self
        
        Task {
            await MainActor.run {
                self.isSDKConfigured = true
            }
            await getOfferings()
            await updatePremiumStatus()
        }
    }
    
    // MARK: - PurchasesDelegate Methods
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        // This delegate method is the single source of truth for subscription status.
        Task {
            await MainActor.run {
                let premiumStatus = customerInfo.entitlements[self.premiumEntitlementID]?.isActive == true
                self.isPremium = premiumStatus
                print("Delegate: Customer info updated. User is \(self.isPremium ? "Premium" : "Not Premium").")
                self.updateUserDocument(isPremium: premiumStatus)
            }
        }
    }

    @MainActor
    func getOfferings() async {
        guard isSDKConfigured else { return }
        do {
            self.offerings = try await Purchases.shared.offerings()
            print("PurchasesManager: Offerings fetched successfully.")
        } catch {
            print("Error fetching offerings: \(error.localizedDescription)")
        }
    }

    @MainActor
    func purchasePackage(_ package: Package) async throws -> CustomerInfo {
        guard isSDKConfigured else {
            throw NSError(domain: "PurchasesManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "SDK not ready"])
        }
        // The delegate will automatically update the isPremium state.
        return try await Purchases.shared.purchase(package: package).customerInfo
    }

    @MainActor
    func restorePurchases() async throws -> CustomerInfo {
        guard isSDKConfigured else {
            throw NSError(domain: "PurchasesManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "SDK not ready"])
        }
        // The delegate will automatically update the isPremium state.
        return try await Purchases.shared.restorePurchases()
    }

    func updatePremiumStatus() async {
        // Used for checking status on initial launch.
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.isPremium = customerInfo.entitlements[self.premiumEntitlementID]?.isActive == true
                print("Initial check: User is \(self.isPremium ? "Premium" : "Not Premium").")
            }
        } catch {
            print("Error fetching customer info for initial premium status: \(error)")
        }
    }
    
    private func updateUserDocument(isPremium: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(uid)
        userRef.updateData(["isPremium": isPremium]) { error in
            if let error = error {
                print("Error updating user's premium status in Firestore: \(error.localizedDescription)")
            } else {
                print("Successfully updated user's premium status in Firestore.")
            }
        }
    }
}
