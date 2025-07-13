import SwiftUI

struct SubscriptionInfoView: View {
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Subscription Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryText)
                .padding(.top)
            
            VStack(spacing: 16) {
                // Subscription Title
                InfoCard(
                    icon: "crown.fill",
                    title: "Crystara Premium",
                    description: "Unlimited rock identifications with advanced features"
                )
                
                // Subscription Length
                InfoCard(
                    icon: "calendar",
                    title: "Subscription Length",
                    description: "Auto-renewing monthly subscription"
                )
                
                // Subscription Price
                InfoCard(
                    icon: "dollarsign.circle.fill",
                    title: "Subscription Price",
                    description: "$4.99 per month (price may vary by region)"
                )
                
                // Auto-renewal Information
                InfoCard(
                    icon: "arrow.clockwise",
                    title: "Auto-Renewal",
                    description: "Subscription automatically renews unless cancelled at least 24 hours before the end of the current period"
                )
            }
            .padding(.horizontal)
            
            Divider()
                .background(ThemeColors.secondaryText.opacity(0.3))
                .padding(.horizontal)
            
            // Required Legal Links
            VStack(spacing: 16) {
                Text("Required Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryText)
                
                VStack(spacing: 12) {
                    // Privacy Policy Link
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(ThemeColors.primaryAction)
                                .font(.system(size: 16))
                            
                            Text("Privacy Policy")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "link")
                                .foregroundColor(ThemeColors.secondaryText)
                                .font(.system(size: 14))
                        }
                        .padding()
                        .background(ThemeColors.surface)
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showingPrivacyPolicy) {
                        SafariView(url: URL(string: "https://sites.google.com/view/rock-identifier-crystal/ana-sayfa")!)
                    }
                    
                    // Terms of Use Link
                    Button(action: {
                        showingTermsOfUse = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(ThemeColors.primaryAction)
                                .font(.system(size: 16))
                            
                            Text("Terms of Use (EULA)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.primaryText)
                            
                            Spacer()
                            
                            Image(systemName: "link")
                                .foregroundColor(ThemeColors.secondaryText)
                                .font(.system(size: 14))
                        }
                        .padding()
                        .background(ThemeColors.surface)
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showingTermsOfUse) {
                        SafariView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(ThemeColors.background)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ThemeColors.primaryAction)
                .font(.system(size: 20))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.primaryText)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(ThemeColors.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(ThemeColors.surface)
        .cornerRadius(12)
    }
}

struct SubscriptionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionInfoView()
    }
}
