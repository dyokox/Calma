// MoodDetailView.swift
// Presents a detailed view of the selected entry

import SwiftUI

struct MoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    // Selected mood entry to display
    let entry: MoodEntry
    
    var body: some View {
        ZStack {
            Color(.calmaBackground).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        // Mood
                        Text(entry.mood.title)
                            .font(.custom("TiroTelugu-Italic", size: 42))
                            .foregroundStyle(.blackOff)
                        // Time and date
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Text(entry.createdAt, format: .dateTime.hour().minute())
                                .font(.custom("SFCompactText-Regular", size: 13))
                                .foregroundStyle(.secondary)
                            Text("·")
                                .foregroundStyle(.secondary)
                            Text(entry.createdAt, format: .dateTime.weekday(.wide).day().month(.wide))
                                .font(.custom("SFCompactText-Regular", size: 13))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28)
                    .padding(.bottom, 26)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.blackOff.opacity(0.07))
                        .frame(height: 1)
                        .padding(.horizontal, 22)
                    
                    VStack(alignment: .leading, spacing: 26) {
                        // Emotions
                        if !entry.emotions.isEmpty {
                            DetailSection(title: "Emotions") {
                                ChipsGrid(items: entry.emotions, style: .emotion)
                            }
                        }
                        if !entry.tags.isEmpty {
                            DetailSection(title: "Tags") {
                                ChipsGrid(items: entry.tags, style: .tag)
                            }
                        }
                        
                        // Journal
                        DetailSection(title: "Journal") {
                            if entry.journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                EmptyStateRow(icon: "text.alignleft", label: "No notes added")
                            } else {
                                Text(entry.journalText)
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.blackOff.opacity(0.8))
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        // Memory
                        DetailSection(title: "Memory") {
                            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(width: 390, height: 390)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            } else {
                                EmptyStateRow(icon: "photo", label: "No memory added")
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 26)
                    .padding(.bottom, 50)
                }
            }
        }
        // Sheet presenttion config
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// Reusable UI component for sections (e.g., emotions, tags, journal, image)
private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("TiroTelugu-Italic", size: 20))
                .foregroundStyle(.blackOff)
            content()
        }
    }
}

// Displays a placeholder if there is no data to display
private struct EmptyStateRow: View {
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(.blackOff.opacity(0.25))
            Text(label)
                .font(.custom("SFCompactText-Regular", size: 14))
                .foregroundStyle(.blackOff.opacity(0.3))
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
