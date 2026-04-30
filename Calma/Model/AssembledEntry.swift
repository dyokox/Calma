// AssembledEntry.swift
// Defines a temp in-memory model used to assemble MoodEntry,
// while the user is doing it and then finalized and persisted

import Foundation

// Editable state of mood entry
// Conforms to equatable to allow for comparison
struct AssembledEntry: Equatable {
    var date: Date = Date()
    var mood: Mood? = nil
    var emotions: Set<String> = []
    var tags: Set<String> = []
    var journalText: String = ""
    
    // Resets the entire draft after completion or cancels
    mutating func reset() {
        mood = nil
        emotions.removeAll()
        tags.removeAll()
        journalText = ""
        
    }
}


