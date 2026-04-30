// MoodProcessView.swift
// Handles the multi step process of mood entry

import SwiftUI

struct MoodProcessView: View {
    // Tracks if the steps were done
    @AppStorage("stepsDone") private var stepsDone = false
    // Controls the current step in the flow
    @State private var step: Int = 0
    // Temporary model that saves the user input
    @State private var assembled = AssembledEntry()
    // Calls when the flow finishes
    let onFinish: () -> Void
    // Called when a completed mood entry
    let onSave: (MoodEntry) -> Void

    var body: some View {
        VStack {
            Group {
                switch step {
                case 0:
                    // Mood selection
                    StepOneView(
                        assembled: $assembled,
                        next: { step = 1 }
                    )

                case 1:
                    // Emotions selection
                    StepTwoView(
                        assembled: $assembled,
                        next: { step = 2 },
                        back: { step -= 1 },
                        skip: { step = 2 }
                    )

                case 2:
                    // Tags selection
                    StepThreeView(
                        assembled: $assembled,
                        next: { step = 3 },
                        back: { step -= 1 },
                        skip: { step = 3 }
                    )

                case 3:
                    // Journal writing
                    StepFourView(
                        assembled: $assembled,
                        next: { step = 4 },
                        back: { step -= 1 },
                        skip: { step = 4 }
                    )
                    
                case 4:
                    // Image and date
                    StepFiveView(
                        assembled: $assembled,
                        next: { finish() },
                        back: { step -= 1 },
                        onSave: onSave,
                    )
                // Fallback
                default:
                    EmptyView()
                }
            }
            .animation(.easeInOut, value: step)
        }
        .background(Color(.calmaBackground).ignoresSafeArea())
    }
    
    // Marks the mood flow completed and triggers dismissal 
    private func finish() {
        stepsDone = true
        onFinish()
    }
}
