// ProgressBarView.swift
// Custom animated progress bar (used for onboarding and mood flow)

import SwiftUI

struct ProgressBarView: View {
    // Current step
    let current: Int
    // Total number of steps in the flow
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            // Creates a capsule for each step in the flow
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(segmentColor(for: i))
                    // Active step is wider, other smaller
                    .frame(width: i == current ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: current)
            }
        }
    }
    
    // Determines visual state of each step
    private func segmentColor(for index: Int) -> Color {
        if index < current  { return Color.calmaPink.opacity(0.35) }
        if index == current { return Color.calmaPink }
        return Color.blackOff.opacity(0.1)
    }
}
