//
//  ContentView.swift
//  bugidentifier
//
//  Created by Yakup Özmavi on 15.06.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    @AppStorage("hasPresentedInitialPaywall") private var hasPresentedInitialPaywall: Bool = false
    @State private var showPaywall: Bool = false

    var body: some View {
        ZStack {
            // Ensure full screen background coverage
            ThemeColors.background
                .ignoresSafeArea(.all)
            
            Group {
                if isOnboardingComplete {
                    MainTabView()
                } else {
                    OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .onChange(of: isOnboardingComplete) { isComplete in
            if isComplete && !hasPresentedInitialPaywall {
                showPaywall = true
                hasPresentedInitialPaywall = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
