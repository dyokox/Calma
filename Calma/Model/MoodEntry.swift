// MoodEntry.swift
// Defines the persistent data model for mood entry

import Foundation
import SwiftData

// Enables SwiftData persistance
@Model
final class MoodEntry {
    var createdAt: Date // When created
    var moodRaw: String // Storing mood as String due to SwiftUI enum issues
    var emotionsData: Data // Emotions stored as json data
    var tagsData: Data // Tags stored as json data
    var journalText: String // Journal text
    var imageData: Data? // Image/Memory
    
    // Creates new mood entry from the user input
    init(createdAt: Date = .now, mood: Mood, emotions: [String],
         tags: [String], journalText: String, imageData: Data? = nil) {
        self.createdAt = createdAt
        self.moodRaw = mood.rawValue
        // Encodes emotions/tags array into json data for persistance
        // for SwiftData compatibility
        self.emotionsData = (try? JSONEncoder().encode(emotions)) ?? Data()
        self.tagsData = (try? JSONEncoder().encode(tags)) ?? Data()
        self.journalText = journalText
        self.imageData = imageData
    }
    // Converts raw string into mood enum
    // Defaults to neutral if decoding failed
    var mood: Mood {
        Mood(rawValue: moodRaw) ?? .neutral
    }

    var emotions: [String] {
        // Decodes json data into usable swift arraay
        get { (try? JSONDecoder().decode([String].self, from: emotionsData)) ?? [] }
        // Encodes array back into json data
        set { emotionsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var tags: [String] {
        // Decodes json data into usable swift arraay
        get { (try? JSONDecoder().decode([String].self, from: tagsData)) ?? [] }
        // Encodes array back into json data
        set { tagsData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }
}
