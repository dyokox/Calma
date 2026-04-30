// InsightView.swift
// Displays the AI generated insights based on mood entries

import SwiftUI
import SwiftData

struct InsightView: View {
    // Managing insights and async state
    @StateObject private var ivm = InsightViewModel()
    // Fetches the mood entries
    @Query private var entries: [MoodEntry]
    // Shared calendar used for month
    @ObservedObject var vm: CalendarViewModel
    // Stores all generated month insights as json string
    @AppStorage("monthlyInsights") private var storedInsightsData: String = ""
    // Feature toggle for tarot insights (optional insight if AI is enabled)
    @AppStorage("tarotEnabled") private var tarotEnabled = false
    // Tracks the user consent about AI usage (disabled by default)
    @AppStorage("aiConsentGiven") private var aiConsentGiven = false
    // Controls temporary toast message when AI disabled
    @State private var showDisabledToast = false
    @State private var goToSettings = false
    @State private var goMoodEntry = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Unique key representation for selected month
                            let key = monthKey(from: vm.displayedMonth)
                            // Loads prev. saved insight for month (if exists)
                            let saved = loadInsights()[key]
                            
                            // Generate / Update button
                            Button(saved == nil ? "Generate insights" : "Update insight") {
                                Task {
                                    // Filters entries for selected month
                                    let filtered = ivm.entries(for: vm.displayedMonth, from: entries)
                                    // Triggers generation
                                    await ivm.generateSummary(
                                        from: filtered,
                                        includeTarot: tarotEnabled,
                                        hasPriorInsight: saved != nil
                                    )
                                    
                                    // Handles disabled AI toast feedback
                                    if case .disabledToast = ivm.state {
                                        showDisabledToast = true
                                        // Auto-dismiss after 3 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation { showDisabledToast = false }
                                        }
                                    }
                                    // Save the insight only if sucesssfully generated
                                    if case .success(let text) = ivm.state {
                                        saveInsight(text, for: vm.displayedMonth)
                                    }
                                }
                            }
                            .foregroundStyle(saved == nil ? .calmaBlue : .calmaPink)
                            
                            // Loading indicator
                            if case .loading = ivm.state {
                                ProgressView().padding(.top, 40)
                            }
                            
                            // Content rendeering
                            switch ivm.state {
                                
                            case .disabled:
                                // No prior insight + AI disabled — full message with settings button
                                VStack(spacing: 16) {
                                    // Tells user insight is disabled
                                    Text("AI Insight is disabled")
                                        .font(.custom("SFCompactText-Regular", size: 20))
                                        .foregroundStyle(.blackOff)
                                    // Tells how to enable
                                    Text("To enable this feature, go to Settings → AI Insight and turn it on.")
                                        .font(.custom("SFCompactText-Regular", size: 14))
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 30)
                                    // Quick CTA to enable it
                                    Button {
                                        goToSettings = true
                                    } label: {
                                        Text("Go to Settings")
                                            .font(.custom("SFCompactText-Regular", size: 14))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.calmaPink)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .navigationDestination(isPresented: $goToSettings) {
                                        SettingsView()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                // Catches token limit and tells the user to comeback later instead,
                                // of displaing error message from Groq API
                            case .tokenLimitReached:
                                Text("Too many entries to process right now, please try again later.")
                                    .font(.custom("SFCompactText-Regular", size: 14))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 40)
                                // Generic error handling
                            case .error(let msg):
                                Text(msg)
                                    .font(.custom("SFCompactText-Regular", size: 14))
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                    .padding(.top, 40)
                                
                            default:
                                // Show saved insight
                                if let saved {
                                    InsightFormatView(text: saved)
                                        .padding(.horizontal, 20)
                                } else if case .success(let text) = ivm.state {
                                    InsightFormatView(text: text)
                                        .padding(.horizontal, 20)
                                // Otherwise no insights for this month.
                                } else if case .idle = ivm.state {
                                    Text("No insights for this month yet.")
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 40)
                                    Button {
                                        goMoodEntry = true
                                    } label: {
                                        Text("Start logging")
                                            .font(.custom("SFCompactText-Regular", size: 14))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(Color.calmaPink)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                        .frame(maxWidth: .infinity)
                    }
                    // Reset vm when user switches month
                    .onChange(of: vm.displayedMonth) {
                        ivm.reset()
                    }
                    
                }
                
                // Floating toast (for ai disabled)
                if showDisabledToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 10) {
                            Text("AI Insight is disabled")
                                .font(.custom("SFCompactText-Regular", size: 14))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blackOff.opacity(0.75))
                        .clipShape(Capsule())
                        .padding(.bottom, 110)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .animation(.easeInOut(duration: 0.3), value: showDisabledToast)
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
        .sheet(isPresented: $goMoodEntry) {
            MoodProcessView { goMoodEntry = false } onSave: { _ in goMoodEntry = false }
        }
    }
    
    // Saves insight locally, keyed by month
    func saveInsight(_ text: String, for date: Date) {
        var dict = loadInsights()
        dict[monthKey(from: date)] = text
        // Encodes dictionary into json string
        if let data = try? JSONEncoder().encode(dict),
           let string = String(data: data, encoding: .utf8) {
            storedInsightsData = string
        }
    }
    
    // Generating unique string key for month
    func monthKey(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        return f.string(from: date)
    }
    
    // Loads the stored insights from pesistance and decodes json into dictionary
    func loadInsights() -> [String: String] {
        guard let data = storedInsightsData.data(using: .utf8) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }
    
}
