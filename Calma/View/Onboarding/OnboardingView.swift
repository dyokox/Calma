// OnboardingView.swift
// Controls the onboarding multistep process

import SwiftUI

struct OnboardingView: View {
    // Persistant onboarding state so it would show only one
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    // COntrols the step of the onboarding flow
    @State private var step: Int = 0
    
    var body: some View {
        VStack {
            // Progress indicator showing the progress
            ProgressBarView(current: step, total: 3)
                .padding(.top, 24)
            
            Spacer().frame(height: 10)
            
            Group {
                switch step {
                    // Welcome
                case 0:
                    WelcomeView(next: { step += 1 })
                    // Aware
                case 1:
                    AwareView(
                        next: { step += 1 },
                        back: { step -= 1 },
                        skip: { step += 1 }
                    )
                    // Safe space
                case 2:
                    SafeSpaceView(
                        next: { finish() },
                        back: { step -= 1 }
                    )
                    // Fallback
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut, value: step)
        }
        .background(Color(.calmaBackground).ignoresSafeArea())
    }
    
    // Marks onboarding complete so it won't show again
    private func finish() {
        hasOnboarded = true
    }
}
