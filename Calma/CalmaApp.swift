// CalmaApp.swift
// Entry point for the appl
import SwiftUI
import SwiftData

@main
struct CalmaApp: App {
    // Stores user preferences for dark or light mode
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            // Act as a gate, showing content only after successfull auth
            AppLockView() {
                ContentView()
                    // Global text override
                    .foregroundStyle(.blackOff)
                    // Dynamically switch between dark and light mode
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
        // SwiftData persistance container for moodentry model
        .modelContainer(for: MoodEntry.self)
    }
}
