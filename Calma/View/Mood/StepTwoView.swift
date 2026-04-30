// StepTwoView.swift
// Step two of mood flow: emotions

import SwiftUI

struct StepTwoView: View {
    // Shared data model built across steps temp
    @Binding var assembled: AssembledEntry
    // Callback for next step, back, or skip step
    let next: () -> Void
    let back: () -> Void
    let skip: () -> Void
    
    // Predefined list of tags
    private let emotions = [
        "Happy", "Sad", "Emotional", "Calm", "Anxious", "Motivated",
        "Tired", "Angry", "Grateful", "Stressed", "Excited", "Lonely",
        "Confident", "Overwhelmed", "Hopeful"
    ]
    
    var body: some View {
        ZStack (alignment: .top) {
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
            
            VStack(spacing: 0) {
                // Progress indicator throughout the flow
                ProgressBarView(current: 1, total: 4)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                // Header
                VStack(spacing: 8) {
                    Text("Emotions")
                        .font(.custom("TiroTelugu-Italic", size: 32))
                        .foregroundStyle(.blackOff)
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)
                    
                    Text("Select everything you felt today")
                        .font(.custom("SFCompactText-Regular", size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 28)
                
                // Chip grid
                ScrollView {
                    // Generates a selectable chip for each tag
                    FlowLayout(spacing: 10, lineSpacing: 10) {
                        ForEach(emotions, id: \.self) { emotion in
                            EmotionToggleChip(
                                title: emotion,
                                color: emotionColor(for: emotion),
                                isSelected: assembled.emotions.contains(emotion)
                            ) {
                                if assembled.emotions.contains(emotion) {
                                    assembled.emotions.remove(emotion)
                                } else {
                                    assembled.emotions.insert(emotion)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Selection count
                if !assembled.emotions.isEmpty {
                    Text("\(assembled.emotions.count) selected")
                        .font(.custom("SFCompactText-Regular", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                // Buttons
                VStack(spacing: 10) {
                    Button {
                        next()
                    } label: {
                        Text("Continue")
                            .font(.custom("SFCompactText-Regular", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.calmaPink)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    // Skip button
                    Button {
                        skip()
                    } label: {
                        Text("Skip this step")
                            .font(.custom("SFCompactText-Regular", size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .animation(.easeInOut(duration: 0.2), value: assembled.emotions.isEmpty)
            }
        }
    }
    
    // Emotion to colour for visual grouping
    private func emotionColor(for emotion: String) -> Color {
        switch emotion {
        case "Happy", "Excited", "Grateful": return .yellow
        case "Sad", "Lonely":               return .blue
        case "Angry", "Stressed":           return .red
        case "Calm", "Hopeful":             return .green
        case "Motivated", "Confident":      return .calmaPink
        default:                            return .gray
        }
    }
}

// MARK: - Emotion toggle chip
private struct EmotionToggleChip: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                // Checkmark only if selected
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(color)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(title)
                    .font(.custom("SFCompactText-Regular", size: 14))
                    .foregroundStyle(isSelected ? color : .blackOff.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? color.opacity(0.1) : Color(.systemBackground).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isSelected ? color.opacity(0.4) : Color.blackOff.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
