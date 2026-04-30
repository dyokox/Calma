// MainView.swift
// Displays all the mood entries by selected month

import SwiftUI
import SwiftData

struct MainView: View {
    // Current selcted entry for viewing details
    @State private var selectedEntry: MoodEntry?
    // Current selected entry for editing
    @State private var entryToEdit: MoodEntry?
    // Controls presentation of mood entry
    @State private var showSteps = false
    // Seaerch text entered by user
    @State private var searchText = ""
    // Toggle search Ui visbility
    @State private var isSearching = false
    // SwiftData to save/delete entries
    @Environment(\.modelContext) private var modelContext
    // Fetches all mood entries and displayed by most recent first
    @Query(sort: \MoodEntry.createdAt, order: .reverse) private var entries: [MoodEntry]
    // Shared calendar for navigation
    @ObservedObject var vm: CalendarViewModel
    
    // Filter entries by search month and search query (if)
    var filteredEntries: [MoodEntry] {
        let calendar = Calendar.current
        // Filters entries by month
        let monthFiltered = entries.filter {
            calendar.isDate($0.createdAt, equalTo: vm.displayedMonth, toGranularity: .month)
        }
        // If search is empty, returns monthly results only
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return monthFiltered
        }
        let query = searchText.lowercased()
        // Applies the search text across multiple fields (title, journal text, emotions and tags)
        return monthFiltered.filter { entry in
            entry.mood.title.lowercased().contains(query) ||
            entry.journalText.lowercased().contains(query) ||
            entry.emotions.contains { $0.lowercased().contains(query) } ||
            entry.tags.contains { $0.lowercased().contains(query) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if isSearching {
                        HStack(spacing: 10) {
                            // Search bar
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                // Text inside the search bar
                                TextField("Search for journal, moods, emotions, tags...", text: $searchText)
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.blackOff)
                                    .autocorrectionDisabled()
                                    .submitLabel(.search)
                                // Clear button
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground).opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blackOff.opacity(0.08), lineWidth: 1)
                            )
                            // Cancel search button
                            Button("Cancel") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isSearching = false
                                    searchText = ""
                                }
                            }
                            .font(.custom("SFCompactText-Regular", size: 14))
                            .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            // Search result summary
                            if isSearching && !searchText.isEmpty {
                                HStack {
                                    Text(filteredEntries.isEmpty
                                         ? "No results for \"\(searchText)\""
                                         : "\(filteredEntries.count) result\(filteredEntries.count == 1 ? "" : "s") for \"\(searchText)\"")
                                    .font(.custom("SFCompactText-Regular", size: 13))
                                    .foregroundStyle(.secondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 15)
                                .padding(.top, 8)
                            }
                            // Displays the filtered entries
                            ForEach(filteredEntries) { entry in
                                MoodCardView(
                                    entry: entry,
                                    // Delete mood entry
                                    onDelete: {
                                        modelContext.delete(entry)
                                        try? modelContext.save()
                                    },
                                    // Edit mood entry
                                    onEdit: { entryToEdit = entry }
                                )
                                // On tap, opens detailed view of mood entry
                                .onTapGesture { selectedEntry = entry }
                            }
                            // Otherwise says no entries this month
                            if filteredEntries.isEmpty && !isSearching {
                                Text("No entries this month")
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 60)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
                
                // Floating add mood entry button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button { showSteps = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(20)
                                .background(Color.calmaPink)
                                .clipShape(Circle())
                                .shadow(color: Color.calmaPink.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 18)
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
                // Search toggle button
                ToolbarItem {
                    Button("Search", systemImage: "magnifyingglass") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSearching.toggle()
                            if !isSearching { searchText = "" }
                        }
                    }
                }
            }
            // Create new entry
            .sheet(isPresented: $showSteps) {
                MoodProcessView { showSteps = false } onSave: { _ in showSteps = false }
            }
            // View entry details
            .sheet(item: $selectedEntry) { entry in
                MoodDetailView(entry: entry)
            }
            // Edit entry details
            .sheet(item: $entryToEdit) { entry in
                MoodEditView(entry: entry)
            }
        }
    }
}
