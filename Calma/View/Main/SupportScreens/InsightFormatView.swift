// InsightFormatView.swit
// Custom view for the AI generated insight instead of raw and messy format


import SwiftUI

struct InsightFormatView: View {
    let text: String // Raw text
    
    // Splits the text in individual lines
    private var lines: [String] {
        text.components(separatedBy: "\n")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Iterates through each line
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                // Lines starting ## are headers
                if line.hasPrefix("## ") {
                    // Removes the hashes and space to extract the actual text
                    let heading = String(line.dropFirst(3))
                    Text(heading)
                        .font(.custom("TiroTelugu-Italic", size: 18))
                        .foregroundStyle(.blackOff)
                        .padding(.top, 20)
                        .padding(.bottom, 4)
                // Lines starting with - are bullet points
                } else if line.hasPrefix("- ") {
                    // Drops the - and space to extract the actual text
                    let bullet = String(line.dropFirst(2))
                    HStack(alignment: .top, spacing: 8) {
                        Text("·")
                            .foregroundStyle(.calmaPink)
                            .font(.custom("SFCompactText-Regular", size: 16))
                        Text(.init(bullet))
                            .font(.custom("SFCompactText-Regular", size: 15))
                            .foregroundStyle(.blackOff.opacity(0.85))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 3)
                // Adds the spacing between body of text
                } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                    Spacer().frame(height: 8)
                // Any other line is treated as normal text
                } else {
                    Text(.init(line))
                        .font(.custom("SFCompactText-Regular", size: 15))
                        .foregroundStyle(.blackOff.opacity(0.85))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
