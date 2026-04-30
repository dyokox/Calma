// MoodCardView.pdf
// Reusable card for mood entries

import SwiftUI

struct MoodCardView: View {
    // Holds temp pdf file url after export
    @State private var pdfURL: URL?
    // Triggers the ios file save/share ui
    @State private var showFileMover: Bool = false
    // displays alert if export fails
    @State private var showExportError = false
    
    // Mood entry to display
    let entry: MoodEntry
    // Callback for deleting the entry
    var onDelete: () -> Void
    // Callback for editing the entry
    var onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                // Mood Entry Title -> e.g., Neutral
                    Text(entry.mood.title)
                        .font(.custom("TiroTelugu-Italic", size: 28))
                        .foregroundStyle(.blackOff)
                
                Spacer()
                
                // Menu -> Edit, Save to PDF, Delete
                Menu {
                    // Edit entry
                        // Calls function to edit
                    Button("Edit entry", systemImage: "pencil") { onEdit() }
                    // Save to PDF
                        // Calls MoodPDF to save the entry
                    Button("Save to PDF", systemImage: "square.and.arrow.up") {
                        do {
                            let url = try MoodPDF.export(entry: entry)
                            pdfURL = url
                            showFileMover = true
                        } catch {
                            print("PDF export failed:", error)
                            showExportError = true
                        }
                    }
                    // Delete entry
                        // Deletes the entry
                    Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 16))
                        .foregroundStyle(.blackOff.opacity(0.5))
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, -8)
            }
            .padding(.bottom, 12)

            // Emotions chips
                // If there is emotions, it will display max 3 and +n if n>3
            if !entry.emotions.isEmpty {
                CompactChipRow(items: entry.emotions, style: .emotion, maxShown: 3)
                    .padding(.bottom, 6)
            }

            // Tags
                // If there is tags, it will display max 3 and +n if n>3
            if !entry.tags.isEmpty {
                CompactChipRow(items: entry.tags, style: .tag, maxShown: 3)
                    .padding(.bottom, 6)
            }

            Spacer().frame(height: entry.emotions.isEmpty && entry.tags.isEmpty ? 0 : 10)

            // Divider
            Rectangle()
                .fill(Color.blackOff.opacity(0.08))
                .frame(height: 1)
                .padding(.bottom, 10)

            // Footer
            HStack(alignment: .center) {
                // Journal indicator
                HStack(spacing: 5) {
                    Image(systemName: hasJournal ? "text.alignleft" : "text.alignleft")
                        .font(.system(size: 11))
                        .foregroundStyle(hasJournal ? Color.calmaPink : Color.blackOff.opacity(0.3))
                    Text(hasJournal ? "Journal added" : "No journal")
                        .font(.custom("SFCompactText-Regular", size: 12))
                        .foregroundStyle(hasJournal ? Color.calmaPink : Color.blackOff.opacity(0.35))
                }

                // Image indicator
                if entry.imageData != nil {
                    HStack(spacing: 5) {
                        Image(systemName: "photo")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.calmaPink)
                        Text("Photo")
                            .font(.custom("SFCompactText-Regular", size: 12))
                            .foregroundStyle(Color.calmaPink)
                    }
                    .padding(.leading, 10)
                }

                Spacer()

                // Time + date
                VStack(alignment: .trailing, spacing: 1) {
                    Text(entry.createdAt, format: .dateTime.hour().minute())
                        .font(.custom("SFCompactText-Regular", size: 12))
                        .foregroundStyle(.blackOff.opacity(0.6))
                    Text(entry.createdAt, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                        .font(.custom("SFCompactText-Regular", size: 11))
                        .foregroundStyle(.blackOff.opacity(0.35))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(entry.mood.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.whiteOff.opacity(0.5))
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(entry.mood.color.opacity(0.5), lineWidth: 1.5)
        )
        .shadow(color: Color.blackOff.opacity(0.04), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        // Presents ios file saving UI when pdf is generated
        .fileMover(isPresented: $showFileMover, file: pdfURL) { result in
            switch result {
            case .success(let savedURL):
                print("PDF saved to:", savedURL)
            case .failure(let error):
                print("Save failed:", error)
            }
            // resets after operation
            pdfURL = nil
        }
        // show if export pdf fails
        .alert("Export failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Something went wrong generating the PDF. Please try again.")
        }
    }
    // Determines if the journal is empty or not 
    private var hasJournal: Bool {
        !entry.journalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
