// TabsView.swift
// Used to display all the tabs (navigation for the app and switching pages)

import SwiftUI
import SwiftData

struct TabsView: View {
    // VM used for calendar logic
    @StateObject private var vm = CalendarViewModel()
    // Automatically fetches mood entries from storage, sorted by most recent
    @Query(sort: \MoodEntry.createdAt, order: .reverse) private var entries: [MoodEntry]
    
    // Filters entries to only display for the current month
    var filteredEntries: [MoodEntry] {
        let calendar = Calendar.current
        return entries.filter { entry in
            calendar.isDate(entry.createdAt,
                            equalTo: vm.displayedMonth,
                            toGranularity: .month)
        }
    }
    
    var body: some View {
        ZStack {
            TabView {
                // Main tab (mood entries)
                MainView(vm: vm)
                    .tabItem { Label("Main", systemImage: "list.bullet.rectangle") }
                // Charts tab
                ChartsView(vm: vm, entries: entries)
                    .tabItem { Label("Charts", systemImage: "lines.measurement.horizontal.aligned.bottom") }
                // AI generated insight tab
                InsightView(vm: vm)
                    .tabItem { Label("CalmAI", systemImage: "sparkles") }
                // Settings tab
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            // Injects SwiftData model container into the entire tab
            // Allows all views to access mood entry persistance
            .modelContainer(for: MoodEntry.self)
            .accentColor(.calmaPink)
        }
    }
}
