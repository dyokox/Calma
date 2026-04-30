// ContentView.swift
// Root view of the app

import SwiftUI

struct ContentView: View {
    // Onboarding is false by default
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some View {
        // Displays main app interface if onboarding complete
        if hasOnboarded {
            TabsView()
        // Otherwise prompts the onboarding process
        } else {
            OnboardingView()
        }
    }
}
