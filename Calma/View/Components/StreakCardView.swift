// StreakCardView.swift
// UI Component for the streak card used in ChartsView.swift

import SwiftUI

struct StreakCardView: View {
    let currentStreak: Int
    let longestStreak: Int
    let loggedToday: Bool

    // Increases colour intensity of flame for visual progress
    private var flameColor: Color {
        if currentStreak == 0 { return .gray }
        if currentStreak < 3  { return .orange.opacity(0.7) }
        if currentStreak < 7  { return .orange }
        return .red
    }
    
    // Provides text encouragement to continue streak
    private var message: String {
        switch currentStreak {
        case 0:       return "Log today to start a streak"
        case 1:       return "You've started — keep it going"
        case 2...4:   return "Building momentum 🌱"
        case 5...9:   return "You're on a roll!"
        case 10...19: return "Impressive consistency 🔥"
        default:      return "Unstoppable 🏆"
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {

            // Streak count
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(currentStreak == 0 ? "—" : "\(currentStreak)")
                        .font(.custom("TiroTelugu-Italic", size: 48))
                        .foregroundStyle(flameColor)
                    if currentStreak > 0 {
                        Text("day\(currentStreak == 1 ? "" : "s")")
                            .font(.custom("SFCompactText-Regular", size: 16))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 6)
                    }
                }
                // Motivational message
                Text(message)
                    .font(.custom("SFCompactText-Regular", size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right side stats
            VStack(alignment: .trailing, spacing: 12) {

                // Indicates if today has been logged or not
                HStack(spacing: 6) {
                    Circle()
                        .fill(loggedToday ? Color.green : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Text(loggedToday ? "Logged today" : "Not logged today")
                        .font(.custom("SFCompactText-Regular", size: 12))
                        .foregroundStyle(loggedToday ? .primary : .secondary)
                }

                // Longest streak
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Best streak")
                        .font(.custom("SFCompactText-Regular", size: 11))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(longestStreak) day\(longestStreak == 1 ? "" : "s")")
                            .font(.custom("TiroTelugu-Italic", size: 16))
                            .foregroundStyle(.blackOff)
                            .padding(.top, 5)
                    }
                }
            }
        }
        .padding(18)
        // Subtle gradiant for visual appeal
        .background(
            ZStack {
                Color(.systemBackground).opacity(0.6)
                if currentStreak > 0 {
                    LinearGradient(
                        colors: [flameColor.opacity(0.06), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(currentStreak > 0 ? flameColor.opacity(0.2) : Color.blackOff.opacity(0.07), lineWidth: 1)
        )
    }
}
