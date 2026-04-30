// Mood.swift
// Defines the Mood model for the application

import Foundation
import SwiftUI

// Predefined states
// Codable - allows persistance
// CaseIterable - iteration over all moods
// Identifiable - enables use in foreach loops
enum Mood: String, Codable, CaseIterable, Identifiable {
    // Cases
    case amazing, good, neutral, bad, terrible
    // Required by Identifiable for SwiftUI rendering
    var id: String {
        rawValue
    }
    // Separates enum from presentation text (for UI)
    var title: String {
        switch self {
        case .amazing:
            return "Amazing"
        case .good:
            return "Good"
        case .neutral:
            return "Neutral"
        case .bad:
            return "Bad"
        case .terrible:
            return "Terrible"
        }
    }
    // Provides visual indicator for UI
    var emoji: String {
        switch self {
        case .amazing: 
            return "😁"
        case .good: 
            return "😊"
        case .neutral: 
            return "😐"
        case .bad: 
            return "😓"
        case .terrible: 
            return "😫"
        }
    }
    // Converts mood into quantitative value
    // Used for average daily chart
    var score: Double {
        switch self {
        case .amazing:  return 5
        case .good:     return 4
        case .neutral:  return 3
        case .bad:      return 2
        case .terrible: return 1
        }
    }
    // Consistent colour mapping for moods across the app
    var color: Color {
        switch self {
        case .amazing: return .yellow
        case .good:    return .green
        case .neutral: return .gray
        case .bad:     return .orange
        case .terrible: return .red
        }
    }
}
