//  PolicyCardView.swift
// Collapsable reusable UI component for PrivacyPolicyView.swift and TOSView.swift

import SwiftUI

struct PolicyCardView: View {
    let number: Int
    let title: String
    let description: String
    var accentColor: Color = .calmaPink
    // Tracks if the card expanded or collapsed
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header button with animation
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    // Number for visual structure
                    Text("\(number)")
                        .font(.custom("TiroTelugu-Italic", size: 14))
                        .foregroundStyle(accentColor)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle().fill(accentColor.opacity(0.1))
                        )
                    // Title of the section
                    Text(title)
                        .font(.custom("SFCompactText-Regular", size: 15))
                        .fontWeight(.medium)
                        .foregroundStyle(.blackOff)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    // Arrow down to show its expandable
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: expanded)
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            // Checks if the card is expanded
            if expanded {
                // Divider to separate the header and description
                Rectangle()
                    .fill(Color.blackOff.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                // Showcases the description of the card
                Text(description)
                    .font(.custom("SFCompactText-Regular", size: 14))
                    .foregroundStyle(.secondary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground).opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blackOff.opacity(0.07), lineWidth: 1)
        )
    }
}
