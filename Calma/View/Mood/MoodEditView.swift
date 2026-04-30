// MoodEditView.swift
// View used to edit an existing mood entry

import SwiftUI
import SwiftData
import PhotosUI

struct MoodEditView: View {
    // SwiftData context for saving changes
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Selecting entry to edit
    let entry: MoodEntry
    
    // Editable states which are copies of entry data
    @State private var selectedMood: Mood
    @State private var selectedEmotions: Set<String>
    @State private var selectedTags: Set<String>
    @State private var journalText: String
    @State private var entryDate: Date
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    
    // available options for emotions
    private let emotions = [
        "Happy", "Sad", "Emotional", "Calm", "Anxious", "Motivated",
        "Tired", "Angry", "Grateful", "Stressed", "Excited", "Lonely",
        "Confident", "Overwhelmed", "Hopeful"
    ]
    
    // available options for tags
    private let tags = [
        "🤳 life", "💼 work", "📚 school", "🫂 friends", "💗 family", "🩺 health",
        "❤️ relationship", "💰 money", "💪 gym", "🏠 home", "✈️ travel", "🛁 self-care",
        "📖 study", "📱 social", "🛏️ sleep"
    ]
    
    // Initialiser, prefilling state with the existing data
    init(entry: MoodEntry) {
        self.entry = entry
        _selectedMood = State(initialValue: entry.mood)
        _selectedEmotions = State(initialValue: Set(entry.emotions))
        _selectedTags = State(initialValue: Set(entry.tags))
        _journalText = State(initialValue: entry.journalText)
        _entryDate = State(initialValue: entry.createdAt)
        _imageData = State(initialValue: entry.imageData)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Mood
                        EditSection(title: "Mood") {
                            VStack(spacing: 10) {
                                Text(selectedMood.emoji)
                                    .font(.system(size: 52))
                                    .frame(maxWidth: .infinity)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                // Mood buttons
                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        ForEach([Mood.amazing, .good, .neutral], id: \.id) { mood in
                                            MoodEditButton(mood: mood, isSelected: selectedMood == mood) {
                                                selectedMood = mood
                                            }
                                        }
                                    }
                                    HStack(spacing: 8) {
                                        ForEach([Mood.bad, .terrible], id: \.id) { mood in
                                            MoodEditButton(mood: mood, isSelected: selectedMood == mood) {
                                                selectedMood = mood
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Emotion chips selection
                        EditSection(title: "Emotions") {
                            FlowLayout(spacing: 8, lineSpacing: 8) {
                                ForEach(emotions, id: \.self) { emotion in
                                    ToggleChip(
                                        title: emotion,
                                        isSelected: selectedEmotions.contains(emotion),
                                        selectedColor: emotionColor(for: emotion)
                                    ) {
                                        if selectedEmotions.contains(emotion) {
                                            selectedEmotions.remove(emotion)
                                        } else {
                                            selectedEmotions.insert(emotion)
                                        }
                                    }
                                }
                            }
                        }

                        // Tags chips selection
                        EditSection(title: "Tags") {
                            FlowLayout(spacing: 8, lineSpacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    ToggleChip(
                                        title: tag,
                                        isSelected: selectedTags.contains(tag),
                                        selectedColor: .calmaPink
                                    ) {
                                        if selectedTags.contains(tag) {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                        }

                        // Journal editor
                        EditSection(title: "Journal") {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground).opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.blackOff.opacity(0.08), lineWidth: 1)
                                    )

                                TextEditor(text: $journalText)
                                    .padding(12)
                                    .frame(minHeight: 140)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .font(.custom("SFCompactText-Regular", size: 15))

                                if journalText.isEmpty {
                                    Text("Write about how you felt...")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.secondary)
                                        .padding(16)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        

                        // Photo attachmenet
                        EditSection(title: "Memory") {
                            if let data = imageData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(width: 390, height: 390)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    // Remove image button
                                    Button {
                                        withAnimation { imageData = nil; selectedItem = nil }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(.white)
                                            .shadow(radius: 4)
                                    }
                                    .padding(8)
                                }
                            } else {
                                // Picker for adding image
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.calmaPink)
                                        Text("Attach a photo")
                                            .font(.custom("SFCompactText-Regular", size: 15))
                                            .foregroundStyle(Color.calmaPink)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.calmaPink.opacity(0.06))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.calmaPink.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    )
                                }
                                // Load selected image
                                .onChange(of: selectedItem) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data),
                                           let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                                            withAnimation { imageData = compressed }
                                        }
                                    }
                                }
                            }
                        }

                        // Date picker
                        EditSection(title: "Date & time") {
                            DatePicker(
                                "Entry date",
                                selection: $entryDate,
                                in: ...Date(),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .tint(.calmaPink)
                            .labelsHidden()
                        }

                        // Save button
                        Button { saveChanges() } label: {
                            Text("Save changes")
                                .font(.custom("SFCompactText-Regular", size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.calmaPink)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .animation(.easeInOut(duration: 0.2), value: 1.0)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            // Title of the page
            .navigationTitle("Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("SFCompactText-Regular", size: 15))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    // Save logic
    private func saveChanges() {
        entry.moodRaw = selectedMood.rawValue
        entry.emotions = Array(selectedEmotions).sorted()
        entry.tags = Array(selectedTags).sorted()
        entry.journalText = journalText.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.createdAt = entryDate
        entry.imageData = imageData

        try? modelContext.save()
        dismiss()
    }
    
    // Emotion color mapping
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

// Reusable UI component to group related sections
private struct EditSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        // Section title
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("TiroTelugu-Italic", size: 20))
                .foregroundStyle(.blackOff)
            // Injected section content
            content()
        }
    }
}

// Custom selectable button for mood option
private struct MoodEditButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Mood
                Text(mood.title)
                    .font(.custom("SFCompactText-Regular", size: 12))
                    .foregroundStyle(isSelected ? moodColor : .blackOff.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? moodColor.opacity(0.1) : Color(.systemBackground).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? moodColor.opacity(0.4) : Color.blackOff.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
    
    // Mood type to UI colour for consistency
    private var moodColor: Color {
        switch mood {
        case .amazing:  return .yellow
        case .good:     return .green
        case .neutral:  return .gray
        case .bad:      return .orange
        case .terrible: return .red
        }
    }
}

// Reusable UI component chip for emotions and tags
private struct ToggleChip: View {
    let title: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(selectedColor)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(title)
                    .font(.custom("SFCompactText-Regular", size: 14))
                    .foregroundStyle(isSelected ? selectedColor : .blackOff.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? selectedColor.opacity(0.1) : Color(.systemBackground).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? selectedColor.opacity(0.4) : Color.blackOff.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
