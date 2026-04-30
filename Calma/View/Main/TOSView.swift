// TOSView.swift
// Represents the Terms of Use for calma

import SwiftUI

struct TOSView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Structured data to allow for dynamic rendering through the components (PolicyCardView.swift)
    let sections: [(title: String, body: String)] = [
        (
            title: "Acceptance of terms",
            body: "By downloading, installing, or using Calma, you agree to be bound by these Terms of Use. If you do not agree, please do not use the app.\n\nThese terms form a legal agreement between you and the Calma developer. We reserve the right to update these terms at any time. Continued use of the app after changes constitutes acceptance."
        ),
        (
            title: "Description of the service",
            body: "Calma is a personal wellness journalling application that allows you to:\n\n• Log and track your mood, emotions, and daily experiences\n• Review your emotional patterns through charts and summaries\n• Optionally receive AI-generated monthly insights based on your entries\n\nCalma is provided for personal, non-commercial use only."
        ),
        (
            title: "Not a medical service",
            body: "Calma is a wellness tool only. It is not a medical device, mental health service, or clinical tool.\n\n• Nothing in Calma constitutes medical, psychological, psychiatric, or professional advice\n• AI-generated insights are informational and reflective only — they are not diagnoses or treatment recommendations\n• You should not use Calma as a substitute for professional mental health care\n• If you are in crisis or experiencing severe distress, please contact a qualified professional or call 116 123 (Samaritans, UK, free and 24/7)"
        ),
        (
            title: "Your content",
            body: "You retain full ownership of all content you create within Calma, including journal entries, mood logs, and photos.\n\nBy enabling AI features, you grant permission for your content to be processed by our third-party AI provider (Groq Inc.) solely for the purpose of generating insights for you. This permission is revocable at any time by disabling AI features in Settings."
        ),
        (
            title: "Acceptable use",
            body: "You agree not to:\n\n• Use Calma for any unlawful purpose\n• Attempt to reverse engineer, modify, or tamper with the app\n• Use the app in any way that could damage or impair its functionality\n\nCalma is intended for personal use only and must not be resold or redistributed."
        ),
        (
            title: "Third-party services",
            body: "Calma integrates with Groq Inc. for AI-powered features. Use of these features is subject to Groq's own terms and privacy policy, available at groq.com.\n\nWe are not responsible for the availability, accuracy, or content of third-party services. We will always notify you before your data is sent to any third party."
        ),
        (
            title: "Disclaimer of warranties",
            body: "Calma is provided on an 'as is' and 'as available' basis without warranties of any kind, express or implied.\n\nWe do not warrant that:\n\n• The app will be uninterrupted or error-free\n• AI-generated insights will be accurate, complete, or suitable for your situation\n• The app will meet your specific requirements\n\nTo the fullest extent permitted by law, we disclaim all implied warranties including merchantability and fitness for a particular purpose."
        ),
        (
            title: "Limitation of liability",
            body: "To the maximum extent permitted by applicable law, Calma and its developer shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the app, including but not limited to:\n\n• Reliance on AI-generated content\n• Loss of data\n• Emotional distress\n\nNothing in these terms limits liability for death or personal injury caused by negligence, or for fraud or fraudulent misrepresentation."
        ),
        (
            title: "Governing law",
            body: "These Terms of Use are governed by and construed in accordance with the laws of England and Wales. Any disputes arising from these terms or your use of Calma shall be subject to the exclusive jurisdiction of the courts of England and Wales."
        ),
        (
            title: "Contact",
            body: "If you have any questions about these Terms of Use, please contact us:\n\nEmail: dyokox@gmail.com\n\nEffective date: April 2026"
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
                                Text("Terms of Use")
                                    .font(.custom("TiroTelugu-Italic", size: 30))
                                    .foregroundStyle(.blackOff)
                            }
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
                                    description: section.body,
                                    accentColor: .calmaBlue
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
