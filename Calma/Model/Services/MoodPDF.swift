// MoodPDF.swift
// Responsible for exporting a mood entry into a PDF doc

import SwiftUI

// Entire pdf generation process
// Takes a mood entry -> creates a locally stored PDF doc url
struct MoodPDF {
    // SwiftUI render and UIImage generating has to happen on main thread
    @MainActor
    static func export(entry: MoodEntry) throws -> URL {
        // Creates the swiftui view representation of the mood entry
        // A4 width
        let view = PDFExportView(entry: entry)
            .frame(width: 595)
        
        // ImageRenderer converts swiftui view into UIKit image
        // PDF generation uses rendered images
        let renderer = ImageRenderer(content: view)
        // Defines the size
        renderer.proposedSize = ProposedViewSize(width: 595, height: nil)
        // Increases rendering resolution for higher quality
        renderer.scale = 2.0
        
        // Attempts to generate UIImage from SwiftUI view -> aborts if export fails
        guard let image = renderer.uiImage else {
            throw ExportError.renderFailed
        }

        // A4 height in points
        let pageHeight: CGFloat = 842
        // Total render height  of the content image
        let totalHeight = image.size.height
        // Calculates how many A4 pages will be needed
        let pageCount = Int(ceil(totalHeight / pageHeight))
        // Defines the page dimensions to fit A4 format
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: pageHeight)
        // UIKit PDF renderer to generate multipage PDF data
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
        // Generates the PDF by drawing slices of image per page
        let data = pdfRenderer.pdfData { ctx in
            for i in 0..<pageCount {
                ctx.beginPage()
                // Calculates vertical offset for each page slice
                let offsetY = CGFloat(i) * pageHeight
                // Draws image shifted upward
                image.draw(at: CGPoint(x: 0, y: -offsetY))
            }
        }
        // Creates the file name output using mood and date
        let filename = "Calma_\(entry.mood.title)_\(formatted(entry.createdAt)).pdf"
        // Stores file in temp directory
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        // Writes PDF to disk
        try data.write(to: url)
        return url
    }
    // Defines error case for PDF export
    enum ExportError: Error { case renderFailed }
    // Converts date into a file safe name format
    private static func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// Defines the visual layout of the PDF before render
private struct PDFExportView: View {
    let entry: MoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header bar
            Rectangle()
                .fill(Color(red: 0.95, green: 0.55, blue: 0.60))
                .frame(height: 6)

            VStack(alignment: .leading, spacing: 20) {
                // Row with Calma and date entry was created
                HStack {
                    Text("Calma")
                        .font(.custom("TiroTelugu-Italic", size: 13))
                        .foregroundStyle(Color(red: 0.95, green: 0.55, blue: 0.60))
                    Spacer()
                    Text(entry.createdAt.formatted(date: .long, time: .shortened))
                        .font(.custom("SFCompactText-Regular", size: 11))
                        .foregroundStyle(.secondary)
                }

                // Mood title e.g. Amazing
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(entry.mood.title)
                        .font(.custom("TiroTelugu-Italic", size: 40))
                        .foregroundStyle(.black)
                }

                Divider()
                
                // Emotions
                if !entry.emotions.isEmpty {
                    PDFSection(title: "Emotions") {
                        Text(entry.emotions.joined(separator: "  ·  "))
                            .font(.custom("SFCompactText-Regular", size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                // Tags
                if !entry.tags.isEmpty {
                    PDFSection(title: "Tags") {
                        Text(entry.tags.joined(separator: "  ·  "))
                            .font(.custom("SFCompactText-Regular", size: 13))
                            .foregroundStyle(.secondary)
                    }
                }

                // Journal
                PDFSection(title: "Journal") {
                    let text = entry.journalText.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text(text.isEmpty ? "No journal entry." : text)
                        .font(.custom("SFCompactText-Regular", size: 13))
                        .foregroundStyle(text.isEmpty ? .secondary : .primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Photo
                if let data = entry.imageData, let img = UIImage(data: data) {
                    PDFSection(title: "Memory") {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(40)
            .background(Color(red: 0.98, green: 0.97, blue: 0.95))
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
    }
}

// Reusable UI component to provide consistent styling 
private struct PDFSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("TiroTelugu-Italic", size: 16))
                .foregroundStyle(.black)
            content()
        }
    }
}
