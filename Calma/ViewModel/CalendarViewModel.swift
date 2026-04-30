// CalendarViewModel.swift
// Managing calendar state and month navigation logic

import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    // Dispalyed in calendar view
    @Published var displayedMonth: Date = Date()
    // System calendar instance used for calendar calculation
    let calendar = Calendar.current
    // Formtter used to display month and year
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    // Month navigation
    // Changes the month foward or backwards depending on value given
    func changeMonth(by value: Int) {
        // Calculates new month, if fails falls to current month
        displayedMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) ?? displayedMonth
    }
}
