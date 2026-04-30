// StepFiveView.swift
// Final step of mood flow: image attachment and date (and saving)

import SwiftUI
import SwiftData
import PhotosUI

struct StepFiveView: View {
    // SwiftData context to persist the data
    @Environment(\.modelContext) private var modelContext
    // Shared data being pulled from all the steps
    @Binding var assembled: AssembledEntry
    // Photo picker states
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    // Navigation callbacks
    let next: () -> Void
    let back: () -> Void
    // Called after success
    let onSave: (MoodEntry) -> Void

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
                ProgressBarView(current: 4, total: 5)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                // Header
                VStack(spacing: 8) {
                    Text("Finish up")
                        .font(.custom("TiroTelugu-Italic", size: 32))
                        .foregroundStyle(.blackOff)
                        .padding(.top, 28)

                    Text("Add a memory and confirm the time")
                        .font(.custom("SFCompactText-Regular", size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 32)

                ScrollView {
                    VStack(spacing: 16) {
                        // Photo card
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Memory", systemImage: "photo")
                                .font(.custom("TiroTelugu-Italic", size: 13))
                                .foregroundStyle(.secondary)
                            // If image exists shows preview
                            if let data = selectedImageData,
                               let uiImage = UIImage(data: data) {
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
                                        withAnimation {
                                            selectedImageData = nil
                                            selectedItem = nil
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(.white)
                                            .shadow(radius: 4)
                                    }
                                    .padding(8)
                                }
                            } else {
                                // Photo picker if no image selected
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.calmaPink)
                                        Text("Attach a memory")
                                            .font(.custom("SFCompactText-Regular", size: 15))
                                            .foregroundStyle(Color.calmaPink)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.calmaPink.opacity(0.06))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.calmaPink.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6]))
                                    )
                                }
                                // Converts image into compressed data
                                .onChange(of: selectedItem) {_, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data),
                                           let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                                            withAnimation { selectedImageData = compressed }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground).opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Date selection
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Date & time", systemImage: "clock")
                                .font(.custom("TiroTelugu-Italic", size: 13))
                                .foregroundStyle(.secondary)

                            DatePicker(
                                "Entry date",
                                selection: $assembled.date,
                                in: ...Date(),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .tint(.calmaPink)
                            .labelsHidden()
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground).opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                Spacer()
                
                // Save button
                Button {
                    saveEntry()
                } label: {
                    Text("Save entry")
                        .font(.custom("SFCompactText-Regular", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.calmaPink)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // Save logic
    private func saveEntry() {
        let entry = MoodEntry(
            createdAt: assembled.date,
            mood: assembled.mood ?? .neutral,
            emotions: Array(assembled.emotions).sorted(),
            tags: Array(assembled.tags).sorted(),
            journalText: assembled.journalText.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: selectedImageData
        )
        modelContext.insert(entry)
        do {
            try modelContext.save()
            onSave(entry)
            assembled.reset()
            next()
        } catch {
            print("Save failed:", error)
        }
    }
}
