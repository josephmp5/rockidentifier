import SwiftUI
import SafariServices

struct LegalLinksView: View {
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Legal Information")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryText)
                .padding(.top)
            
            VStack(spacing: 16) {
                // Privacy Policy Link
                Button(action: {
                    showingPrivacyPolicy = true
                }) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(ThemeColors.primaryAction)
                            .font(.system(size: 18))
                        
                        Text("Privacy Policy")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
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
                            .font(.system(size: 18))
                        
                        Text("Terms of Use (EULA)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ThemeColors.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
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
            
            Spacer()
        }
        .background(ThemeColors.background)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// SafariView wrapper for presenting web content
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor(ThemeColors.primaryAction)
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct LegalLinksView_Previews: PreviewProvider {
    static var previews: some View {
        LegalLinksView()
    }
}
