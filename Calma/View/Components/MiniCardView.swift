// MiniCardView.swift
// Reusable UI component, in this case it's for ChartsView.swift

import SwiftUI

// It displays Title and Icon
// With either the list of tags or fallback message
struct MiniCardView: View {
    let title: String
    let icon: String
    let color: Color
    let tags: [String]
    let empty: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(color)
                Text(title)
                    .font(.custom("SFCompactText-Regular", size: 12))
                    .foregroundStyle(.secondary)
            }
            
            // Displays the fallback message if no tags
            if tags.isEmpty {
                Text(empty)
                    .font(.custom("SFCompactText-Regular", size: 12))
                    .foregroundStyle(.secondary.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // Otherwise displays the tags
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(color.opacity(0.3 + Double(index) * 0.15))
                                .frame(width: 7, height: 7)
                            Text(tag)
                                .font(.custom("SFCompactText-Regular", size: 13))
                                .foregroundStyle(.blackOff.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}
