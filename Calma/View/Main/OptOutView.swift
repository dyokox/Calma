// OptOutView.swift
// Allows the user to withdraw consent of using AI feature

import SwiftUI

struct OptOutView: View {
    // Tracks if the user confirming of withdrawal or not
    @State private var hasConfirmed = false
    // Persistent AI consent (true because user opted in if they have this screen)
    @AppStorage("aiConsentGiven") private var aiConsentGiven = true
    @Environment(\.dismiss) var dismiss

    // Structure data explaining about withdrwaal of the AI usage
    // Icon + Title + Explanation
    let sections: [(icon: String, title: String, bullets: [String])] = [
        (
            icon: "exclamationmark",
            title: "What changes",
            bullets: [
                "AI-powered monthly insights will be disabled",
                "Future entries will not be sent to any AI provider",
                "Previously generated insights remain visible locally"
            ]
        ),
        (
            icon: "externaldrive",
            title: "Your data",
            bullets: [
                "Data already processed by Groq may not be retrievable or deletable",
                "Your local mood entries and journals are not affected",
                "Nothing stored on your device will be deleted"
            ]
        ),
        (
            icon: "arrow.clockwise",
            title: "You can always change your mind",
            bullets: [
                "AI features can be re-enabled at any time from Settings",
                "You will be asked to consent again before any data is processed"
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(spacing: 10) {
                            Text("Disable CalmAI")
                                .font(.custom("TiroTelugu-Italic", size: 30))
                                .foregroundStyle(.blackOff)
                                .multilineTextAlignment(.center)
                                .padding(.top, 20)

                            Text("AI-powered insights will be turned off. Here's what that means for you.")
                                .font(.custom("SFCompactText-Regular", size: 15))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.bottom, 28)
                        }
                        .frame(maxWidth: .infinity)

                        // Info sections
                        VStack(spacing: 12) {
                            ForEach(sections, id: \.title) { section in
                                BulletCardView(
                                    icon: section.icon,
                                    title: section.title,
                                    bullets: section.bullets
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        // Checkbox
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(hasConfirmed ? Color.red.opacity(0.8) : Color.secondary.opacity(0.4), lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                                if hasConfirmed {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.red.opacity(0.8))
                                }
                            }
                            // Informed withdrawal statement
                            Text("I understand that disabling CalmAI will stop all future AI processing of my data.")
                                .font(.custom("SFCompactText-Regular", size: 14))
                                .foregroundStyle(.blackOff)
                                .lineSpacing(3)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { hasConfirmed.toggle() }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                        // Disable button
                        Button {
                            aiConsentGiven = false
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Disable CalmAI")
                                    .font(.custom("SFCompactText-Regular", size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(hasConfirmed ? Color.red.opacity(0.85) : Color.secondary.opacity(0.2))
                            .foregroundStyle(hasConfirmed ? .white : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .animation(.easeInOut(duration: 0.2), value: hasConfirmed)
                        }
                        .disabled(!hasConfirmed)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Keep enabled
                        Button("Keep AI features enabled") {
                            dismiss()
                        }
                        .font(.custom("SFCompactText-Regular", size: 14))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
