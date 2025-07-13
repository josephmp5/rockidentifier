import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var purchasesManager: PurchasesManager
    @StateObject private var historyManager = HistoryManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var showPaywall = false
    @State private var showingClearAlert = false
    @State private var showingLegalLinks = false

    init() {
        // Set the unselected tab bar item color
        UITabBar.appearance().unselectedItemTintColor = UIColor(ThemeColors.secondaryText)
    }

    var body: some View {
        ZStack {
            // Full screen background coverage
            ThemeColors.background
                .ignoresSafeArea(.all)
            
            TabView(selection: $selectedTab) {
                NavigationStack {
                    CameraGalleryView(showPaywall: $showPaywall)
                        .navigationTitle("Crystara")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: { showingLegalLinks = true }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(ThemeColors.secondaryText)
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { showPaywall = true }) {
                                    Image(systemName: purchasesManager.isPremium ? "crown.fill" : "crown")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(ThemeColors.primaryAction)
                                }
                            }
                        }
                }
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 0 ? "camera.viewfinder" : "camera")
                            .font(.system(size: 20, weight: .medium))
                        Text("Identify")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .tag(0)

                NavigationStack {
                    HistoryView()
                        .navigationTitle("My Collection")
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if !historyManager.history.isEmpty {
                                    Button(action: { showingClearAlert = true }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(ThemeColors.accent)
                                    }
                                }
                            }
                        }
                }
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == 1 ? "clock.fill" : "clock")
                            .font(.system(size: 20, weight: .medium))
                        Text("History")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .tag(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tint(ThemeColors.primaryAction)
        .onAppear {
            // Customize tab bar appearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(ThemeColors.surface)
            
            // Selected item color
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(ThemeColors.primaryAction)
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(ThemeColors.primaryAction),
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
            ]
            
            // Unselected item color
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(ThemeColors.secondaryText)
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(ThemeColors.secondaryText),
                .font: UIFont.systemFont(ofSize: 12, weight: .medium)
            ]
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            // Customize navigation bar appearance for dark theme
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(ThemeColors.background)
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor(ThemeColors.primaryText)
            ]
            navBarAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor(ThemeColors.primaryText)
            ]
            
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingLegalLinks) {
            NavigationStack {
                LegalLinksView()
                    .navigationTitle("Legal Information")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingLegalLinks = false
                            }
                            .foregroundColor(ThemeColors.primaryAction)
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Clear History", isPresented: $showingClearAlert, actions: {
            Button("Clear", role: .destructive) { historyManager.clearHistory() }
        }, message: {
            Text("Are you sure you want to delete all identification history? This action cannot be undone.")
        })
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(PurchasesManager.shared) // For previewing
            .environmentObject(UserManager()) // For previewing
    }
}
