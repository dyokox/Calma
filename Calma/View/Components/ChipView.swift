// ChipView.swift
// Defines reusable UI components for displayings chips (emotions/tags)
// Includes custom dynamic wrapping, as SwiftUI doesnt provide native wrapping

import SwiftUI

// Custom layout that arranges subviews horizontally and wraps them in new rows
struct FlowLayout: Layout {
    // Horizontal spacing between them
    var spacing: CGFloat = 8
    // Vertical spacing between rows
    var lineSpacing: CGFloat = 8
    // Calculates total size required for layout
    // SwiftUI calls to understand how much space is needed
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        // If width undefined returns 0 - cannot layout
        guard width > 0 else { return .zero }
        // Height dynamically calculated based on wrapping rows
        return CGSize(width: width, height: computeHeight(for: subviews, in: width))
    }
    
    // Simulates layout to determine how many rows are needed
    private func computeHeight(for subviews: Subviews, in width: CGFloat) -> CGFloat {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                // If exceeds current row width, wraps to next row
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + lineSpacing
                    rowHeight = 0
                }

                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            // Final height includes last row
            return y + rowHeight
        }
    
    // Positions each subview in the given position
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            var x = bounds.minX
            var y = bounds.minY
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                // Wrap to next row if needed
                if x + size.width > bounds.maxX && x > bounds.minX {
                    x = bounds.minX
                    y += rowHeight + lineSpacing
                    rowHeight = 0
                }
                
                // Place subview at calcualted position
                subview.place(
                    at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )

                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
        }
}

// Defines logical grouping for chip types
enum ChipStyle { case emotion, tag }

// Generates consistent colour for each emotion
// By using hashing it ensures the same word - same colour
private func emotionColor(for text: String) -> Color {
    let colors: [Color] = [.calmaPink, .blue, .green, .orange, .purple]
    let idx = abs(text.lowercased().hashValue) % colors.count
    return colors[idx]
}

// Reusable UI component representing a chip
struct Chip: View {
    let text: String
    var style: ChipVariant = .plain

    enum ChipVariant { case emotion, tag, plain, detail }

    var body: some View {
        Text(text)
            .font(.custom("SFCompactText-Medium", size: fontSize))
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
     
    
    // Styling properties
    private var fontSize: CGFloat {
        switch style {
        case .plain, .detail: return 12
        case .emotion, .tag:  return 10
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .emotion:
            return emotionColor(for: text).opacity(0.12)
        case .tag:
            return Color(.systemBackground).opacity(0.6)
        case .plain, .detail:
            return Color(.systemBackground).opacity(0.6)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .emotion:
            return emotionColor(for: text)
        case .tag:
            return Color.blackOff.opacity(0.6)
        case .plain, .detail:
            return Color.blackOff
        }
    }

    private var borderColor: Color {
        switch style {
        case .emotion:
            return emotionColor(for: text).opacity(0.3)
        case .tag:
            return Color.blackOff.opacity(0.12)
        case .plain, .detail:
            return Color.blackOff.opacity(0.15)
        }
    }
}

// Displays limited number (3) of chips per row
struct CompactChipRow: View {
    let items: [String]
    let style: ChipStyle
    var maxShown: Int = 3

    var body: some View {
        let shown = Array(items.prefix(maxShown))
        // Number of hidden items
        let remaining = max(0, items.count - shown.count)

        HStack(spacing: 6) {
            // Renders the visible chips
            ForEach(shown, id: \.self) { item in
                Chip(text: item, style: style == .emotion ? .emotion : .tag)
            }
            
            // The overflow indicator (e.g., +2 etc)
            if remaining > 0 {
                Text("+\(remaining)")
                    .font(.custom("SFCompactText-Medium", size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.blackOff.opacity(0.08), lineWidth: 1)
                    )
            }
            Spacer(minLength: 0)
        }
    }
}

// Displays all the chips by using FlowLayout with automatic wrapping
struct ChipsGrid: View {
    let items: [String]
    var style: ChipStyle = .tag

    var body: some View {
        FlowLayout(spacing: 8, lineSpacing: 8) {
            ForEach(items, id: \.self) { item in
                Chip(text: item, style: style == .emotion ? .emotion : .tag)
            }
            
        }
    }
}
