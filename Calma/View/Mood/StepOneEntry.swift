// StepOneView.swift
// Step one of mood flow: mood selection

import SwiftUI

struct StepOneView: View {
    // Shared data model built across steps temp
    @Binding var assembled: AssembledEntry
    // Callback for next step
    let next: () -> Void
    // Computed fallback mood used for emoji preview
    var selectedMood: Mood {
        assembled.mood ?? .neutral
    }

    var body: some View {
        ZStack {
            Color(.calmaBackground).ignoresSafeArea()
            // Progress indicator throughout the flow
            VStack(spacing: 0) {
                ProgressBarView(current: 0, total: 4)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer()

                // Emoji related to mood selected
                Text(selectedMood.emoji)
                    .font(.system(size: 90))
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                    .padding(.bottom, 28)

                // Header
                VStack(spacing: 8) {
                    Text("How are you feeling?")
                        .font(.custom("TiroTelugu-Italic", size: 32))
                        .foregroundStyle(.blackOff)
                        .multilineTextAlignment(.center)

                    Text("Choose the mood that best reflects\nhow you feel right now")
                        .font(.custom("SFCompactText-Regular", size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.bottom, 36)

                // Mood buttons
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        ForEach([Mood.amazing, .good, .neutral], id: \.id) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: assembled.mood == mood
                            ) {
                                assembled.mood = mood
                            }
                        }
                    }
                    HStack(spacing: 10) {
                        ForEach([Mood.bad, .terrible], id: \.id) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: assembled.mood == mood
                            ) {
                                assembled.mood = mood
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Next button
                Button {
                    next()
                } label: {
                    Text("Continue")
                        .font(.custom("SFCompactText-Regular", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(assembled.mood != nil ? Color.calmaPink : Color.secondary.opacity(0.2))
                        .foregroundStyle(assembled.mood != nil ? .white : .secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.2), value: assembled.mood != nil)
                }
                .disabled(assembled.mood == nil)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

// Mood selection button
private struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.title)
                    .font(.custom("SFCompactText-Regular", size: 13))
                    .foregroundStyle(isSelected ? moodColor : .blackOff.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? moodColor.opacity(0.1) : Color(.systemBackground).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? moodColor.opacity(0.5) : Color.blackOff.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
    // Maps mood text to colour
    private var moodColor: Color {
        switch mood {
        case .amazing: return .yellow
        case .good:    return .green
        case .neutral: return .gray
        case .bad:     return .orange
        case .terrible: return .red
        }
    }
}
