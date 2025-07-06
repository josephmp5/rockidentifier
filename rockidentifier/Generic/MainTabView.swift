import SwiftUI

struct MainTabView: View {
    @Binding var showPaywall: Bool

    init(showPaywall: Binding<Bool>) {
        self._showPaywall = showPaywall
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
            .navigationTitle("Crystara")
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
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(showPaywall: .constant(false))
            .environmentObject(PurchasesManager.shared) // For previewing
    }
}
