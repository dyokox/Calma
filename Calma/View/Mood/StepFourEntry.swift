// StepFourView.swift
// Step four of mood flow: journal text

import SwiftUI

struct StepFourView: View {
    // Shared data model built across steps temp
    @Binding var assembled: AssembledEntry
    // Callbacks for next step, back, or skip
    let next: () -> Void
    let back: () -> Void
    let skip: () -> Void

    var body: some View {
        ZStack(alignment: .top){
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
                ProgressBarView(current: 3, total: 5)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                // Header
                VStack(spacing: 8) {
                    Text("Journal")
                        .font(.custom("TiroTelugu-Italic", size: 32))
                        .foregroundStyle(.blackOff)
                        .padding(.top, 28)

                    Text("Write about how you felt today")
                        .font(.custom("SFCompactText-Regular", size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 28)

                // Text editor card
                ZStack(alignment: .topLeading) {
                    // Background card
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground).opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.blackOff.opacity(0.08), lineWidth: 1)
                        )
                    // Editable text area
                    TextEditor(text: $assembled.journalText)
                        .padding(14)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .font(.custom("SFCompactText-Regular", size: 15))
                        .foregroundStyle(.blackOff)

                    // Placeholder overlay when empty
                    if assembled.journalText.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "applepencil.and.scribble")
                                .foregroundStyle(.calmaGray).opacity(0.40)
                            Text("What's on your mind?")
                                .font(.custom("SFCompactText-Regular", size: 15))
                                .foregroundStyle(.calmaGray).opacity(0.40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .allowsHitTesting(false)
                    }
                }
                .frame(height: 280)
                .padding(.horizontal, 24)

                Spacer()
                // Navigation buttons
                VStack(spacing: 10) {
                    // Next step
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
                    // Skip to next
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
            }
        }
    }
}
