import SwiftUI
import FirebaseAuth

// MARK: - Data Model for Onboarding Pages
struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let headline: String
    let subheadline: String
    let showsDismissButton: Bool
}

// MARK: - Main Onboarding View
struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "onboarding_crystal",
            headline: "Welcome to Crystara",
            subheadline: "Your pocket guide to the world of minerals.",
            showsDismissButton: false
        ),
        OnboardingPage(
            imageName: "onboarding_scan_graphic",
            headline: "Identify with a Snap",
            subheadline: "Use your camera to instantly identify any rock or crystal.",
            showsDismissButton: false
        ),
        OnboardingPage(
            imageName: "onboarding_mineral_collage",
            headline: "Discover & Learn",
            subheadline: "Explore detailed properties, geological context, and fun facts for every discovery.",
            showsDismissButton: true
        )
    ]

    var body: some View {
        ZStack {
            // Ensure full screen coverage
            ThemeColors.background
                .ignoresSafeArea(.all)

            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingScreenView(page: pages[index], isOnboardingComplete: $isOnboardingComplete)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            VStack {
                Spacer()
                CustomProgressIndicator(numberOfPages: pages.count, currentPage: currentPage)
                    .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Individual Onboarding Screen
struct OnboardingScreenView: View {
    let page: OnboardingPage
    @Binding var isOnboardingComplete: Bool
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding()
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 0.8).delay(0.2), value: showContent)

            VStack(spacing: 15) {
                Text(page.headline)
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(ThemeColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(page.subheadline)
                    .font(.headline)
                    .foregroundColor(ThemeColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .opacity(showContent ? 1 : 0)
            .animation(.easeIn(duration: 0.8).delay(0.4), value: showContent)

            Spacer()

            if page.showsDismissButton {
                Button(action: {
                    // First, sign in the user anonymously.
                    AuthService.shared.signInAnonymously { result in
                        switch result {
                        case .success(let user):
                            print("Onboarding: Anonymous sign-in successful for user \(user.uid).")
                            // Now that sign-in is complete, dismiss the onboarding flow.
                            isOnboardingComplete = true
                        case .failure(let error):
                            // If sign-in fails, we should not proceed. 
                            // For now, we just log the error. A real app might show an alert.
                            print("Critical: Onboarding failed to sign in user anonymously. Error: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.primaryAction)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn(duration: 1.0).delay(0.6), value: showContent)
            } else {
                // Placeholder for the button to maintain layout consistency
                Button(action: {}) {
                    Text("Get Started")
                }
                .font(.headline)
                .fontWeight(.bold)
                .padding()
                .background(Color.clear)
                .cornerRadius(16)
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                .hidden() // Keep the space but don't show it
            }
        }
        .onAppear {
            showContent = false
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Custom Progress Indicator
struct CustomProgressIndicator: View {
    let numberOfPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? ThemeColors.primaryAction : Color.gray.opacity(0.5))
                    .frame(width: currentPage == index ? 24 : 8, height: 8)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboardingComplete: .constant(false))
    }
}
