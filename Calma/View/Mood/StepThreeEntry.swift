// StepThreeView.swift
// Step three of mood flow: tags

import SwiftUI

struct StepThreeView: View {
    // Shared data model built across steps temp
    @Binding var assembled: AssembledEntry
    // Callback for next step, back, or skip step
    let next: () -> Void
    let back: () -> Void
    let skip: () -> Void
    
    // Predefined list of tags
    private let tags = [
        "🤳 life", "💼 work", "📚 school", "🫂 friends", "💗 family", "🩺 health",
        "❤️ relationship", "💰 money", "💪 gym", "🏠 home", "✈️ travel", "🛁 self-care",
        "📖 study", "📱 social", "🛏️ sleep"
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
            
            // Progress indicator throughout the flow
            VStack(spacing: 0) {
                ProgressBarView(current: 2, total: 4)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                // Header
                VStack(spacing: 8) {
                    Text("Tags")
                        .font(.custom("TiroTelugu-Italic", size: 32))
                        .foregroundStyle(.blackOff)
                        .multilineTextAlignment(.center)
                        .padding(.top, 28)

                    Text("Tag the areas of life this relates to")
                        .font(.custom("SFCompactText-Regular", size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 28)
                
                ScrollView {
                    FlowLayout(spacing: 10, lineSpacing: 10) {
                        // Generates a selectable chip for each tag
                        ForEach(tags, id: \.self) { tag in
                            TagToggleChip(
                                title: tag,
                                isSelected: assembled.tags.contains(tag)
                            ) {
                                if assembled.tags.contains(tag) {
                                    assembled.tags.remove(tag)
                                } else {
                                    assembled.tags.insert(tag)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                Spacer()
                
                // Shows selected count of tags
                if !assembled.tags.isEmpty {
                    Text("\(assembled.tags.count) selected")
                        .font(.custom("SFCompactText-Regular", size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                
                VStack(spacing: 10) {
                    // Next button
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
                .animation(.easeInOut(duration: 0.2), value: assembled.tags.isEmpty)
            }
        }
    }
}

// Custom chip UI component
private struct TagToggleChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                // Shows checkmark only if selected
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.calmaPink)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(title)
                    .font(.custom("SFCompactText-Regular", size: 14))
                    .foregroundStyle(isSelected ? Color.calmaPink : .blackOff.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? Color.calmaPink.opacity(0.1) : Color(.systemBackground).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isSelected ? Color.calmaPink.opacity(0.4) : Color.blackOff.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
