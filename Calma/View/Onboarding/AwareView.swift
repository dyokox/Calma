// AwareView.swift
// Explains the purpose of the application

import SwiftUI

struct AwareView: View {
    // Callbacks for next step, back or skip
    let next: () -> Void
    let back: () -> Void
    let skip: () -> Void
    
    // Entrance animation control
    @State private var appeared = false
    
    // Structured data
    let highlights: [(icon: String, color: Color, text: String)] = [
        (icon: "circle.fill",
         color: .calmaPink,
         text: "Recognise patterns in how you feel"),
        (icon: "circle.fill",
         color: .calmaPink,
         text: "Track emotional trends over time"),
        (icon: "circle.fill",
         color: .calmaPink,
         text: "Gain insight to help yourself grow")
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

            VStack(spacing: 0) {
                Spacer()
                // Header
                VStack(spacing: 10) {
                    Text("Become aware")
                        .font(.custom("TiroTelugu-Italic", size: 32))
                        .foregroundStyle(.blackOff)
                        .multilineTextAlignment(.center)

                    Text("Understand which emotions you experience most,\nso you can begin to work with them.")
                        .font(.custom("SFCompactText-Regular", size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 28)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)

                Spacer()

                // Highlight cards
                VStack(spacing: 12) {
                    ForEach(Array(highlights.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 16) {
                            ZStack {
                                Image(systemName: item.icon)
                                    .font(.system(size: 5))
                                    .foregroundStyle(item.color)
                            }
                            Text(item.text)
                                .font(.custom("SFCompactText-Regular", size: 15))
                                .foregroundStyle(.blackOff.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color(.systemBackground).opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blackOff.opacity(0.07), lineWidth: 1)
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(
                            .easeOut(duration: 0.5).delay(0.25 + Double(index) * 0.12),
                            value: appeared
                        )
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // CTA
                Button { next() } label: {
                    Text("Let's go")
                        .font(.custom("SFCompactText-Regular", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.calmaPink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.2), value: 1.0)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.65), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }
}
