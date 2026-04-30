// WelcomeView.swift
// First screen of the onboarding process

import SwiftUI

struct WelcomeView: View {
    let next: () -> Void
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color(.calmaBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                // Welcome text
                VStack(spacing: 6) {
                    Text("Welcome to")
                        .font(.custom("TiroTelugu-Regular", size: 22))
                        .foregroundStyle(.blackOff.opacity(0.6))
                    
                    Text("Calma")
                        .font(.custom("TiroTelugu-Italic", size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.calmaPink, .calmaPurple, .calmaBlue],
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                        )
                        .padding(.top, -8)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 24)
                .animation(.easeOut(duration: 0.6).delay(0.25), value: appeared)
                
                // Tagline
                Text("Your space to breathe, reflect, and reset.")
                    .font(.custom("SFCompactText-Regular", size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: appeared)
                
                Spacer()
                
                // CTA
                Button {
                    next()
                } label: {
                    Text("Let's begin")
                        .font(.custom("SFCompactText-Regular", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.calmaPink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.2), value: 1.0)
                }
                .padding(.horizontal, 28)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.6).delay(0.7), value: appeared)
                
                Text("Free to use · Private by design")
                    .font(.custom("SFCompactText-Regular", size: 12))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.8), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }
}
