// ChartsView.swift
// Responsible for analysing and visualising the user mood data

import SwiftUI
import Charts
import SwiftData

struct ChartsView: View {
    // Shared calendar model
    @ObservedObject var vm: CalendarViewModel
    // All mood entries fetched from persistence
    let entries: [MoodEntry]
    // Calendar for date calc
    private let calendar = Calendar.current
    // Filter entries by selected month
    var filteredEntries: [MoodEntry] {
        entries.filter {
            calendar.isDate($0.createdAt, equalTo: vm.displayedMonth, toGranularity: .month)
        }
    }
    
    // Groups the entries by day and computes average mood score/day
    var dailyAverages: [(day: Date, average: Double)] {
        // Group entries by start of each day
        let grouped = Dictionary(grouping: filteredEntries) { calendar.startOfDay(for: $0.createdAt) }
        // Compute average for each day
        return grouped
            .map { (day: $0.key, average: $0.value.map { $0.mood.score }.reduce(0, +) / Double($0.value.count)) }
            .sorted { $0.day < $1.day }
    }
    // Overall average score (month)
    var averageScore: Double {
        guard !dailyAverages.isEmpty else { return 0 }
        return dailyAverages.map(\.average).reduce(0, +) / Double(dailyAverages.count)
    }
    
    // Mood label
    var averageMoodLabel: String {
        switch averageScore {
        case 4.5...: return "Amazing"
        case 3.5...: return "Good"
        case 2.5...: return "Neutral"
        case 1.5...: return "Bad"
        case 0...:   return "Terrible"
        default:     return "Neutral"
        }
    }
    // Mood distribution counts
    var moodCounts: [(mood: Mood, count: Int)] {
        Mood.allCases.map { mood in
            (mood: mood, count: filteredEntries.filter { $0.mood == mood }.count)
        }
    }
    
    // Streak logic based on all entries
    var currentStreak: Int {
        let days = Set(entries.map { calendar.startOfDay(for: $0.createdAt) })
        guard !days.isEmpty else { return 0 }
        
        var streak = 0
        var checking = calendar.startOfDay(for: Date())
        
        // If nothing logged today, starts checking from yesterday
        if !days.contains(checking) {
            checking = calendar.date(byAdding: .day, value: -1, to: checking) ?? checking
        }
        // Count consecutive days backwards
        while days.contains(checking) {
            streak += 1
            checking = calendar.date(byAdding: .day, value: -1, to: checking) ?? checking
        }
        return streak
    }
    
    // Longest continuous streak
    var longestStreak: Int {
        let days = Set(entries.map { calendar.startOfDay(for: $0.createdAt) })
            .sorted()
        guard !days.isEmpty else { return 0 }
        
        var longest = 1
        var current = 1
        
        for i in 1..<days.count {
            let diff = calendar.dateComponents([.day], from: days[i - 1], to: days[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return longest
    }
    
    // Logged today indicator
    var loggedToday: Bool {
        let today = calendar.startOfDay(for: Date())
        return entries.contains { calendar.startOfDay(for: $0.createdAt) == today }
    }
    
    // Top 3 tags (monthly)
    var topTags: [(tag: String, count: Int)] {
        var counts: [String: Int] = [:]
        for entry in filteredEntries {
            for tag in entry.tags { counts[tag, default: 0] += 1 }
        }
        return counts.map { (tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }
    
    // Top 3 emotions (monthyl)
    var topEmotions: [(emotion: String, count: Int)] {
        var counts: [String: Int] = [:]
        for entry in filteredEntries {
            for emotion in entry.emotions { counts[emotion, default: 0] += 1 }
        }
        return counts.map { (emotion: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }
    
    // Top 3 tags when mood was good/amazing
    var goodMoodTags: [(tag: String, count: Int)] {
        let goodEntries = filteredEntries.filter { $0.mood == .amazing || $0.mood == .good }
        var counts: [String: Int] = [:]
        for entry in goodEntries {
            for tag in entry.tags { counts[tag, default: 0] += 1 }
        }
        return counts.map { (tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }
    
    // Top 3 tags when mood was bad/terrible
    var lowMoodTags: [(tag: String, count: Int)] {
        let lowEntries = filteredEntries.filter { $0.mood == .bad || $0.mood == .terrible }
        var counts: [String: Int] = [:]
        for entry in lowEntries {
            for tag in entry.tags { counts[tag, default: 0] += 1 }
        }
        return counts.map { (tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()
                ScrollView {
                    // Streak card
                    StreakCardView(
                        currentStreak: currentStreak,
                        longestStreak: longestStreak,
                        loggedToday: loggedToday
                    )
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                    
                    // If no mood entries (month) shows text
                    if filteredEntries.isEmpty {
                        VStack(spacing: 10) {
                            Text("No entries this month")
                                .font(.custom("SFCompactText-Regular", size: 16))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 60)
                    } else {
                        VStack(spacing: 14) {
                            
                            // Average mood trend chart
                            ChartCard(title: "Average daily mood", subtitle: averageMoodLabel) {
                                Chart(dailyAverages, id: \.day) { item in
                                    // Line
                                    LineMark(
                                        x: .value("Day", item.day, unit: .day),
                                        y: .value("Mood", item.average)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.calmaPink)
                                    // Area
                                    AreaMark(
                                        x: .value("Day", item.day, unit: .day),
                                        y: .value("Mood", item.average)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.calmaPink.opacity(0.2), .clear],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    // Points
                                    PointMark(
                                        x: .value("Day", item.day, unit: .day),
                                        y: .value("Mood", item.average)
                                    )
                                    .symbolSize(30)
                                    .foregroundStyle(Color.calmaPink)
                                }
                                .chartYScale(domain: 1...5)
                                .chartYAxis {
                                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let v = value.as(Int.self) {
                                                Text(["", "Terrible", "Bad", "Neutral", "Good", "Amazing"][v])
                                                    .font(.custom("SFCompactText-Regular", size: 10))
                                            }
                                        }
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 5)) {
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.day())
                                    }
                                }
                                .frame(height: 200)
                            }
                            
                            // Bar chart for mood breakdown count
                            ChartCard(title: "Mood breakdown", subtitle: nil) {
                                Chart(moodCounts, id: \.mood) { item in
                                    BarMark(
                                        x: .value("Mood", item.mood.title),
                                        y: .value("Count", item.count)
                                    )
                                    .foregroundStyle(Color.calmaPink.opacity(
                                        filteredEntries.isEmpty ? 0.2 :
                                            Double(item.count) / Double(filteredEntries.count + 1) + 0.2
                                    ))
                                    .cornerRadius(8)
                                    .annotation(position: .top, alignment: .center, spacing: 4) {
                                        VStack(spacing: 2) {
                                            Text(item.mood.emoji).font(.system(size: 16))
                                            if item.count > 0 {
                                                Text("\(item.count)")
                                                    .font(.custom("SFCompactText-Regular", size: 11))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks {
                                        AxisValueLabel()
                                            .font(.custom("SFCompactText-Regular", size: 11))
                                    }
                                }
                                .chartYAxis(.hidden)
                                .chartYScale(domain: 0...(moodCounts.map(\.count).max() ?? 1) + 2)
                                .frame(height: 180)
                            }
                            
                            // Top 3 tags of the month
                            if !topEmotions.isEmpty {
                                ChartCard(title: "Top emotions", subtitle: "Most logged this month") {
                                    VStack(spacing: 10) {
                                        ForEach(Array(topEmotions.enumerated()), id: \.offset) { index, item in
                                            TopItemRow(
                                                rank: index + 1,
                                                label: item.emotion,
                                                count: item.count,
                                                total: filteredEntries.count,
                                                color: emotionColor(for: item.emotion)
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Top 3 tags of the month
                            if !topTags.isEmpty {
                                ChartCard(title: "Top tags", subtitle: "Most logged this month") {
                                    VStack(spacing: 10) {
                                        ForEach(Array(topTags.enumerated()), id: \.offset) { index, item in
                                            TopItemRow(
                                                rank: index + 1,
                                                label: item.tag,
                                                count: item.count,
                                                total: filteredEntries.count,
                                                color: .calmaPink
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Top 3 tags when good/bad mood
                            HStack(spacing: 14) {
                                // Good mood tags
                                MiniCardView(
                                    title: "When thriving",
                                    icon: "sun.max",
                                    color: .green,
                                    tags: goodMoodTags.map(\.tag),
                                    empty: "Not enough entries logged"
                                )
                                
                                // Low mood tags
                                MiniCardView(
                                    title: "When struggling",
                                    icon: "cloud.rain",
                                    color: .blue,
                                    tags: lowMoodTags.map(\.tag),
                                    empty: "Not enough entries logged"
                                )
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                        .padding(.bottom, 100)
                    }
                }
            }
            .toolbar {
                // Month navigation
                ToolbarItem(placement: .principal) {
                    HStack {
                        Button { vm.changeMonth(by: -1) } label: {
                            Image(systemName: "chevron.left").foregroundStyle(.blackOff)
                        }
                        Spacer()
                        Text(vm.formatter.string(from: vm.displayedMonth))
                            .font(.custom("TiroTelugu-Italic", size: 25))
                        Spacer()
                        Button { vm.changeMonth(by: 1) } label: {
                            Image(systemName: "chevron.right").foregroundStyle(.blackOff)
                        }
                    }
                }
            }
        }
    }
    
    // Emotion strings to colour for visual consistency
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

// Reusable UI component to display charts
// Used for most logged this month (tags/emotions)
private struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("SFCompactText-Regular", size: 13))
                .foregroundStyle(.secondary)
            if let subtitle {
                Text(subtitle)
                    .font(.custom("TiroTelugu-Regular", size: 20))
                    .foregroundStyle(.blackOff)
            }
            content()
        }
        .padding(16)
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// Displays most logged this month
private struct TopItemRow: View {
    let rank: Int
    let label: String
    let count: Int
    let total: Int
    let color: Color
    // Fraction to represent how dominant this tag is
    // e.g. - 5 out of 20 = 0.25 or 25%
    var fraction: Double {
        total == 0 ? 0 : Double(count) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                // Rank
                Text("\(rank)")
                    .font(.custom("TiroTelugu-Italic", size: 13))
                    .foregroundStyle(color)
                    .frame(width: 18)
                // Tag/Emotion
                Text(label)
                    .font(.custom("SFCompactText-Regular", size: 14))
                    .foregroundStyle(.blackOff)
                Spacer()
                // Count
                Text("\(count)×")
                    .font(.custom("SFCompactText-Regular", size: 13))
                    .foregroundStyle(.secondary)
            }
            // Progress bar to show visually
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.6))
                        .frame(width: geo.size.width * fraction, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}
