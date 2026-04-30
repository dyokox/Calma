// OptInView.swift
// Presents the user consent sreen about AI-insight usage

import SwiftUI

struct OptInView: View {
    // Tracks if the checkbox is selected or not
    @State private var hasConsented = false
    // Persistent storage of the user decision (enabled or not)
    // Disabled by default
    @AppStorage("aiConsentGiven") private var aiConsentGiven = false
    // Environment handle, used to close the view
    @Environment(\.dismiss) var dismiss
    
    // Structure data explaining about the AI usage
    // Icon + Title + Explanation
    let sections: [(icon: String, title: String, bullets: [String])] = [
        (
            // Feature explanation
            icon: "sparkles",
            title: "What this feature does",
            bullets: [
                "Analyses your written journal entries",
                "Reviews your logged moods, emotions, and tags",
                "Generates a personalised monthly emotional summary"
            ]
        ),
        (
            // Data explanation
            icon: "externaldrive",
            title: "How your data is processed",
            bullets: [
                "Sent securely to Groq Inc., a third-party AI provider",
                "Processing may occur outside the UK under standard contractual clauses",
                "Used only to generate your response — never to train AI models",
                "Not used to make automated decisions about you"
            ]
        ),
        (   // Limitations disclaimer
            icon: "exclamationmark.triangle",
            title: "Important limitations",
            bullets: [
                "Insights may be inaccurate, incomplete, or misleading",
                "This is not medical or psychological advice",
                "Do not rely on it for decisions affecting your health"
            ]
        ),
        (   // User rights
            icon: "hand.raised",
            title: "Your rights",
            bullets: [
                "This feature is entirely optional",
                "You can withdraw consent at any time in Settings",
                "Legal basis: Article 6(1)(a) and Article 9(2)(a) UK GDPR"
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
                            Text("CalmAI Consent")
                                .font(.custom("TiroTelugu-Italic", size: 30))
                                .foregroundStyle(.blackOff)
                                .multilineTextAlignment(.center)
                                .padding(.top, 20)

                            Text("Before enabling AI insights, please take a moment to understand how your data is used.")
                                .font(.custom("SFCompactText-Regular", size: 15))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                                .padding(.bottom, 28)
                        }
                        .frame(maxWidth: .infinity)

                        // Dynamically generates the cards based on the data
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

                        // Groq link for user's to check out
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 12))
                            Text("Learn more about [Groq's privacy policy](https://groq.com/privacy)")
                                .font(.custom("SFCompactText-Regular", size: 13))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Checkbox
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(hasConsented ? Color.calmaPink : Color.secondary.opacity(0.4), lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                                if hasConsented {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.calmaPink)
                                }
                            }
                            // Consent statement
                            Text("I have read and understood the information above, and I consent to my data being processed for AI-powered features.")
                                .font(.custom("SFCompactText-Regular", size: 14))
                                .foregroundStyle(.blackOff)
                                .lineSpacing(3)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { hasConsented.toggle() }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                        // Button
                        Button {
                            aiConsentGiven = true
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Enable CalmAI")
                                    .font(.custom("SFCompactText-Regular", size: 16))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            // Depends on whether the checkbox selected or not
                            .background(hasConsented ? Color.calmaPink : Color.secondary.opacity(0.2))
                            .foregroundStyle(hasConsented ? .white : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .animation(.easeInOut(duration: 0.2), value: hasConsented)
                        }
                        .disabled(!hasConsented)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // User does not accept and goes back to settings
                        Button("No thanks") {
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
