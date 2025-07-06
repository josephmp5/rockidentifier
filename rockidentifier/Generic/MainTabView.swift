import SwiftUI

struct MainTabView: View {
    @Binding var showPaywall: Bool

    init(showPaywall: Binding<Bool>) {
        self._showPaywall = showPaywall
        // Set the unselected tab bar item color
        UITabBar.appearance().unselectedItemTintColor = UIColor(ThemeColors.secondaryText)
    }

    var body: some View {
        TabView {
            CameraGalleryView(showPaywall: $showPaywall)
                .tabItem {
                    Label("Identify", systemImage: "camera.viewfinder")
                }

            HistoryView(showPaywall: $showPaywall)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
        .tint(ThemeColors.primaryAction) // Sets the selected tab item color
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(showPaywall: .constant(false))
            .environmentObject(PurchasesManager.shared) // For previewing
    }
}
