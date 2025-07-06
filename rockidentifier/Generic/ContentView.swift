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
        Group {
            if isOnboardingComplete {
                MainTabView(showPaywall: $showPaywall)
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
        .onChange(of: isOnboardingComplete) { isComplete in
            if isComplete && !hasPresentedInitialPaywall {
                showPaywall = true
                hasPresentedInitialPaywall = true
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isModal: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
