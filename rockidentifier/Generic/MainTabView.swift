import SwiftUI

struct MainTabView: View {
    @State private var showPaywall = false

    init() {
        // Set the unselected tab bar item color
        UITabBar.appearance().unselectedItemTintColor = UIColor(ThemeColors.secondaryText)
    }

    var body: some View {
        NavigationStack {
            TabView {
                CameraGalleryView()
                    .tabItem {
                        Label("Identify", systemImage: "camera.viewfinder")
                    }

                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.fill")
                    }
            }
            .tint(ThemeColors.primaryAction) // Sets the selected tab item color
            .navigationTitle("Rock Identifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showPaywall = true
                    }) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(ThemeColors.primaryAction)
                    }
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(isModal: false)
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(PurchasesManager.shared) // For previewing
    }
}
