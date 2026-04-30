//  PrivacyPolicyView.swift
// Displays all the privacy policy of the application

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Structured data to allow for dynamic rendering through the components (PolicyCardView.swift)
    let sections: [(title: String, body: String)] = [
        (
            title: "Who we are",
            body: "Calma is a personal mood and wellness journalling application developed independently. We are committed to protecting your privacy and being transparent about how your data is handled.\n"
        ),
        (
            title: "What data we collect",
            body: "Calma collects only the data you choose to provide:\n\n• Mood entries, including mood, emotions, and tags\n• Journal text you write within the app\n• Photos you choose to attach to entries\n• App preferences such as Face ID and dark mode settings\n\nAll of this data is stored locally on your device. We do not operate servers that store your personal data."
        ),
        (
            title: "How your data is used",
            body: "Your data is used solely to provide the features of the Calma app:\n\n• Displaying your mood history and patterns\n• Generating charts and insights within the app\n• If you have consented, sending relevant mood data to our AI provider (Groq Inc.) to generate monthly insights\n\nWe do not sell, rent, or share your personal data with third parties for marketing or advertising purposes."
        ),
        (
            title: "AI features and third-party processing",
            body: "If you choose to enable CalmAI, certain data (mood entries, emotions, tags, and journal excerpts) will be sent to Groq Inc., an AI infrastructure company based in the United States, for the purpose of generating your monthly emotional summary.\n\nThis transfer is made under standard contractual clauses (SCCs) recognised under UK GDPR Article 46. Groq does not retain your data beyond the duration of the API request and does not use it to train AI models.\n\nYou can withdraw consent for AI processing at any time via Settings → Additional Features → AI Insight. Withdrawing consent immediately stops further data being sent to Groq."
        ),
        (
            title: "Legal basis for processing",
            body: "We process your data under the following legal bases as defined by UK GDPR:\n\n• Article 6(1)(a) — Consent: for AI-powered features, where you have explicitly opted in\n• Article 6(1)(b) — Contract: to provide the core functionality of the app you have chosen to use\n• Article 9(2)(a) — Explicit consent: where mood or emotional data constitutes special category health-related data\n\nYou may withdraw consent at any time without affecting the lawfulness of processing carried out before withdrawal."
        ),
        (
            title: "Data retention",
            body: "Your data is retained locally on your device for as long as you use the app. You can delete individual entries at any time within the app. Uninstalling Calma from your device will remove all locally stored data.\n\nData processed by Groq Inc. via the AI features is not retained by Groq after a response is returned."
        ),
        (
            title: "Your rights under UK GDPR",
            body: "As a UK resident, you have the following rights regarding your personal data:\n\n• Right of access — request a copy of data we hold about you\n• Right to rectification — request correction of inaccurate data\n• Right to erasure — request deletion of your data\n• Right to restrict processing — ask us to limit how we use your data\n• Right to data portability — receive your data in a portable format\n• Right to object — object to processing based on legitimate interests\n• Right to withdraw consent — at any time, without penalty\nYou also have the right to lodge a complaint with the Information Commissioner's Office (ICO) at ico.org.uk."
        ),
        (
            title: "Cookies and tracking",
            body: "Calma does not use cookies, advertising trackers, or any analytics tools that monitor your behaviour across apps or websites. The only data collected is what you explicitly enter into the app."
        ),
        (
            title: "Children's privacy",
            body: "Calma is not directed at children under the age of 13. We do not knowingly collect personal data from children."
        ),
        (
            title: "Changes to this policy",
            body: "We may update this Privacy Policy from time to time. When we do, we will update the effective date below and notify you within the app where appropriate. Continued use of Calma after changes constitutes acceptance of the updated policy.\n\nEffective date: April 2026"
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 12) {
                                Text("Privacy Policy")
                                    .font(.custom("TiroTelugu-Italic", size: 30))
                                    .foregroundStyle(.blackOff)
                            }
                            // When last updated
                            Text("Last updated April 2026 · Calma")
                                .font(.custom("SFCompactText-Regular", size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 28)
                        
                        // Dynamically rendering each section (using PolicyCardView.swift)
                        VStack(spacing: 12) {
                            ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                                PolicyCardView(
                                    number: index + 1,
                                    title: section.title,
                                    description: section.body
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
