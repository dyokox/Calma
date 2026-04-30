// InsightViewModel.swift
// Handles the AI generated insights based on mood entry data


import Foundation
import Combine
import SwiftUI

// Represents the possible states of the insight generation flow
enum AIState {
    case idle // No request
    case loading // Request in progress
    case success(String) // Successfully received text
    case disabled // AI disabled (needs explicit consent)
    case disabledToast // AI disabled but previous insights exist
    case tokenLimitReached // Token limit reached
    case error(String) // Generic errors
}

@MainActor
class InsightViewModel: ObservableObject {
    // Current ai state for UI rendering
    @Published var state: AIState = .idle
    // Stores the raw ai response
    @Published var response = ""
    // Simple loading flag for ui spinner
    @Published var isLoading = false
    
    // Filters mood entries for specific month
    func entries(for month: Date, from entries: [MoodEntry]) -> [MoodEntry] {
        let calendar = Calendar.current
        return entries.filter {
            calendar.isDate($0.createdAt, equalTo: month, toGranularity: .month)
        }
    }
    
    // Generates a monthly insight using Groq AI
    func generateSummary(from entries: [MoodEntry], includeTarot: Bool = false, hasPriorInsight: Bool = false) async {
        // Guard against empty dataset
        guard !entries.isEmpty else {
            state = .error("No data available for this month.")
            return
        }
        // Set loading state
        isLoading = true
        state = .loading
        
        do {
            // Build structured prompt from journal entries
            let prompt = buildMonthlySummaryPrompt(from: entries)
            // Optional tarot instruction if feature enabled
            let tarotInstruction = includeTarot ? """
                ## Tarot Card
                Choose one tarot card that best represents this person's month. Give the card name, and in 2-3 sentences explain why it reflects their emotional journey this month. Keep it warm and reflective, not mystical or dramatic.
                """ : ""
            // Sends request to Groq AI
            let result = try await GroqService.shared.send(messages: [
                [
                    "role": "system",
                    "content": """
                    You are a calm mental wellness assistant. You do not give professional advice, medication recommendations
                    or anything a professional should do instead. If you receive subjects about self-harming generate the insights
                    as usual and provide phone numbers and links to free professional help in UK and other countries, with advice
                    to seek professional help if possible.
                    If more concerning entries are provided, generate a gentle answer how you cannot give any advice on that
                    subject and that immediate professional help should be searched for.
                    IMPORTANT: Your response MUST follow this exact format with line breaks.
                    Rules:
                    - Every section MUST start on a NEW LINE
                    - Add a blank line between sections
                    - NEVER join headings and text on the same line
                    - Use "-" for bullet points
                    - Do NOT use HTML or <br>
                    - Do NOT write everything in one paragraph

                    FORMAT EXACTLY LIKE THIS:
                    ## Overall Trend
                    Your paragraph here.
                    ## Key Emotions
                    - Overwhelmed: explanation
                    - Anxious: explanation
                    ## Notable Patterns
                    - Pattern: explanation
                    ## Gentle Suggestions
                    - Suggestion
                    - Suggestion
                    \(tarotInstruction)

                    Keep it concise, supportive, and readable.
                    """
                ],
                ["role": "user", "content": prompt]
            ])
            // Stoers successfull response
            response = result
            state = .success(result)

        } catch GroqError.aiDisabled {
            // If there's already an insight on screen, show a toast instead of wiping it
            state = hasPriorInsight ? .disabledToast : .disabled

        } catch GroqError.tokenLimitReached {
            // API quota exceeded
            state = .tokenLimitReached
        } catch {
            // Generic errors
            state = .error(error.localizedDescription)
        }
        // Reset loading state
        isLoading = false
    }
    
    // Converts monthly entries into a structured prompt for AI
    private func buildMonthlySummaryPrompt(from entries: [MoodEntry]) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        // Formats each entry into readable blocks
        let summary = entries.map { entry in
            """
            Date: \(formatter.string(from: entry.createdAt))
            Mood: \(entry.mood.title)
            Emotions: \(entry.emotions.joined(separator: ", "))
            Tags: \(entry.tags.joined(separator: ", "))
            Journal: \(entry.journalText.prefix(200))
            """
        }.joined(separator: "\n\n")
        
        // final prompt sent to ai
        return """
        Here is my journal data for this month:

        \(summary)

        Please analyse this and provide a monthly emotional summary.
        """
    }
    
    // Resets vm back to initial state
    func reset() {
        response = ""
        state = .idle
        isLoading = false
    }
}
