// SettingsView.swift
// Handles user preferences: dark mode, faceid, ai insights, tarot insight, and legal (privacy policy and tos)

import SwiftUI
import PhotosUI

struct SettingsView: View {
    // If faceID is enabled or not
    @AppStorage("isFaceID") private var isFaceID = false
    // If dark mode is enabled or not
    @AppStorage("isDarkMode") private var isDarkMode = false
    // If ai usage consent is given or not
    @AppStorage("aiConsentGiven") private var aiConsentGiven = false
    // If tarot is enabled or not
    @AppStorage("tarotEnabled") private var tarotEnabled = false
    // Controls tos modal (used to navigate to TOSView.swift)
    @State private var showTerms = false
    // Controls privacy policy modal (used to navigate to PrivacyPolicyView.swift)
    @State private var showPrivacy = false
    // Navigates to OptInView.swift or OptOutView.swift
    @State private var showAIConsentFlow = false
    // Dislays faceID errors
    @State private var errorMessage: String?
    // Shows loading spinnner during auth
    @State private var isTogglingFaceID = false
    // UI representation of faceid toggle
    @State private var faceIDToggleUI = false
    private let auth = BiometricAuth()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.calmaBackground).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Settings")
                                .font(.custom("TiroTelugu-Italic", size: 36))
                                .foregroundStyle(.blackOff)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                        
                        // General
                        SettingsSection(title: "General") {
                            // Dark Mode
                            HStack(spacing: 14) {
                                Image(systemName: "moon.stars")
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.calmaPink)
                                Text("Dark mode")
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.blackOff)
                                Spacer()
                                // Toggle for dark mode
                                Toggle("", isOn: $isDarkMode)
                                    .toggleStyle(.switch)
                                    .tint(.calmaPink)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider().padding(.leading, 52)
                            
                            // Face ID
                            HStack(spacing: 14) {
                                Image(systemName: "faceid")
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.calmaPink)
                                Text("Face ID")
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(.blackOff)
                                Spacer()
                                if isTogglingFaceID {
                                    ProgressView().scaleEffect(0.8)
                                } else {
                                    // Toggle for faceid
                                    Toggle("", isOn: Binding(
                                        get: { faceIDToggleUI },
                                        set: { newValue in
                                            Task { await handleFaceIDToggle(newValue) }
                                        }
                                    ))
                                    .toggleStyle(.switch)
                                    .tint(.calmaPink)
                                    .labelsHidden()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.custom("SFCompactText-Regular", size: 12))
                                    .foregroundStyle(.red)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                            }
                        }
                        
                        // Additional Features
                        SettingsSection(title: "Additional Features") {
                            // AI Insights
                            HStack(spacing: 14) {
                                Image(systemName: "sparkles")
                                    .font(.custom("SFCompactText-Regular", size: 15))
                                    .foregroundStyle(aiConsentGiven ? .calmaPink : .secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("AI insight")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.blackOff)
                                    Text(aiConsentGiven ? "Enabled" : "Disabled")
                                        .font(.custom("SFCompactText-Regular", size: 12))
                                        .foregroundStyle(aiConsentGiven ? .calmaPink : .secondary)
                                }
                                Spacer()
                                Button {
                                    showAIConsentFlow = true
                                } label: {
                                    Text(aiConsentGiven ? "Opt out" : "Enable")
                                        .font(.custom("SFCompactText-Regular", size: 13))
                                        .foregroundStyle(aiConsentGiven ? .red.opacity(0.8) : .calmaPink)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(aiConsentGiven ? Color.red.opacity(0.08) : Color.calmaPink.opacity(0.08))
                                        )
                                }
                                // Depending on if consent was given or not, will show either
                                // OptOutView.swift or OptInView.swift
                                .navigationDestination(isPresented: $showAIConsentFlow) {
                                    if aiConsentGiven { OptOutView() } else { OptInView() }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            // Tarot Insight (visible only if insights are enabled)
                            if aiConsentGiven {
                                Divider().padding(.leading, 52)
                                
                                HStack(spacing: 14) {
                                    Image(systemName: "lanyardcard")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.calmaPink)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Monthly tarot card")
                                            .font(.custom("SFCompactText-Regular", size: 15))
                                            .foregroundStyle(.blackOff)
                                        Text("Adds a reflective tarot reading to your monthly insight")
                                            .font(.custom("SFCompactText-Regular", size: 12))
                                            .foregroundStyle(.secondary)
                                            .lineSpacing(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $tarotEnabled)
                                        .toggleStyle(.switch)
                                        .tint(.calmaPink)
                                        .labelsHidden()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .animation(.easeInOut, value: aiConsentGiven)
                            }
                        }
                        
                        // Legal
                        SettingsSection(title: "Legal") {
                            Button {
                                showTerms = true
                            } label: {
                                // Terms of Use
                                HStack(spacing: 14) {
                                    Image(systemName: "doc.text")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.blackOff.opacity(0.5))
                                    Text("Terms of use")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.blackOff)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading, 52)
                            
                            Button {
                                showPrivacy = true
                            } label: {
                                // Privacy Policy
                                HStack(spacing: 14) {
                                    Image(systemName: "questionmark.text.page")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.blackOff.opacity(0.5))
                                    Text("Privacy policy")
                                        .font(.custom("SFCompactText-Regular", size: 15))
                                        .foregroundStyle(.blackOff)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        // Sync UI toggle with stored faceid state
        .onAppear { faceIDToggleUI = isFaceID }
        .onChange(of: isFaceID) { _, newValue in faceIDToggleUI = newValue }
        // modal presentations
        .sheet(isPresented: $showTerms) { TOSView() }
        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
    }
    
    // Ensures biometric auth before enabling
    @MainActor
    private func handleFaceIDToggle(_ newValue: Bool) async {
        errorMessage = nil
        // Turning faceid off turns no verification
        guard newValue else {
            isFaceID = false
            faceIDToggleUI = false
            return
        }
        isTogglingFaceID = true
        defer { isTogglingFaceID = false }
        
        // Checks device supports faceid
        guard auth.isAvailable() else {
            isFaceID = false; faceIDToggleUI = false
            errorMessage = "Face ID isn't available on this device."
            return
        }
        do {
            // Attempts auth
            let ok = try await auth.authenticate(reason: "Enable Face ID to lock Calma.")
            isFaceID = ok; faceIDToggleUI = ok
            if !ok { errorMessage = "Face ID was cancelled or failed." }
        } catch {
            isFaceID = false; faceIDToggleUI = false
            errorMessage = "Face ID was cancelled or failed."
        }
    }
    
    
    // Reusable section container to group settings
    private struct SettingsSection<Content: View>: View {
        let title: String
        @ViewBuilder let content: () -> Content
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Section title
                Text(title)
                    .font(.custom("SFCompactText-Regular", size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 6)
                // Content
                VStack(spacing: 0) {
                    content()
                }
                .background(Color(.systemBackground).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blackOff.opacity(0.07), lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
    }
}

