// SafeSpaceView.swift
// Final onboarding screen

import SwiftUI

struct SafeSpaceView: View {
    // Callbacks for next (finish) and back
    let next: () -> Void
    let back: () -> Void
    
    // Controls animations
    @State private var appeared = false
    
    // Structured data
    let promises: [(icon: String, color: Color, title: String, body: String)] = [
        (
            icon: "lock.shield",
            color: .calmaPink,
            title: "You own your data",
            body: "The security and privacy of your personal data are our top priority. We will never monetize or share your data without your explicit consent."
        ),
        (
            icon: "heart.circle",
            color: .calmaPink,
            title: "It's your freedom",
            body: "You can opt out of AI features at any time. Doing so immediately stops your data being processed externally, with no loss of core functionality."
        ),
        (
            icon: "exclamationmark.shield",
            color: .calmaPink,
            title: "Not a replacement for therapy",
            body: "Calma helps you reflect and understand your patterns. It is not a substitute for professional mental health care, and no insight should be treated as clinical advice."
        )
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color(.calmaBackground).ignoresSafeArea()
            // Back button
            HStack {
                Button { back() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.blackOff.opacity(0.6))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground).opacity(0.6))
                                .overlay(Circle().stroke(Color.blackOff.opacity(0.07), lineWidth: 1))
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .zIndex(1)

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 10) {
                        Text("This is your safe space")
                            .font(.custom("TiroTelugu-Italic", size: 30))
                            .foregroundStyle(.blackOff)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 100)
                    .padding(.bottom, 36)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                    // Promise cards
                    VStack(spacing: 12) {
                        ForEach(Array(promises.enumerated()), id: \.offset) { index, promise in
                            PromiseCard(
                                icon: promise.icon,
                                color: promise.color,
                                title: promise.title,
                                description: promise.body
                            )
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 16)
                            .animation(
                                .easeOut(duration: 0.5).delay(0.2 + Double(index) * 0.12),
                                value: appeared
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer().frame(height: 40)

                    // CTA
                    Button { next() } label: {
                        Text("I understand")
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
                    .animation(.easeOut(duration: 0.5).delay(0.65), value: appeared)
                    
                    Text("You can revisit these details anytime in Settings.")
                        .font(.custom("SFCompactText-Regular", size: 12))
                        .foregroundStyle(.secondary.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .padding(.bottom, 48)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.5).delay(0.75), value: appeared)
                }
            }
        }
        .onAppear { appeared = true }
    }
}

// Reusable UI component
struct PromiseCard: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(color)
            }
            // Title and description
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.custom("TiroTelugu-Italic", size: 18))
                    .foregroundStyle(.blackOff)
                Text(description)
                    .font(.custom("SFCompactText-Regular", size: 13))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blackOff.opacity(0.07), lineWidth: 1)
        )
    }
}

