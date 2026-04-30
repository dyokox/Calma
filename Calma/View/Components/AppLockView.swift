// AppLockView.swift
// Provides biometric based app locking functionality
// Wraps content view and conditionally restricts access

import SwiftUI

// Generic wrapper to protect (any) SwiftUI view,
// by requiring biometric auth to access
struct AppLockView<Content: View>: View {
    // Tracks the app state (active, background, inactive)
    @Environment(\.scenePhase) private var scenePhase
    // Stores if auth is enabled by the user
    @AppStorage("isFaceID") private var isFaceID = false
    // Indicates if the app is currently unlocked
    @State private var unlocked = true
    // Prevents multiple auth attempts at the same time
    @State private var isAuthenticating = false
    // Auto-auth once per lock
    @State private var didAutoPromptForThisLock = false
    // Tracks if app should lock after returning from bacgrkound
    @State private var lockArmed = false
    // Biometric auth service
    private let auth = BiometricAuth()
    // Protected content view
    let content: Content
    // Initialiser allows any SwiftUI view to be protected
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isFaceID && !unlocked {
                // If FaceID enabled + app locked - show lockscreen
                lockedView
            } else {
                // If not, show content
                content
            }
        }
        .onAppear {
            // If auth disabled, app automatically unlocked
            unlocked = !isFaceID
        }
        // Lifecycle handling
        .onChange(of: scenePhase) { _, phase in
            guard isFaceID else { return }
            switch phase {
            case .background:
                // Lock the app when it goes in background
                lockArmed = true
            case .active:
                // When returning, trigger lock
                if lockArmed {
                    unlocked = false
                    didAutoPromptForThisLock = false
                    lockArmed = false
                }
            default:
                break
            }
        }
        // Settings change handling
        .onChange(of: isFaceID) { _, newValue in
            if newValue {
                // If user enables -> lock the app immediately
                unlocked = false
                didAutoPromptForThisLock = false
            } else {
                // If disabled -> unlock app
                unlocked = true
                didAutoPromptForThisLock = true
            }
        }
    }
    
    // Shows the screen when the app is locked
    private var lockedView: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                Text("Locked")
                    .font(.title2)
                    .bold()
                Text("Unlock with Face ID to continue.")
                    .foregroundStyle(.secondary)
                Button(isAuthenticating ? "Unlocking..." : "Unlock") {
                    Task { await unlock() }
                }
                .disabled(isAuthenticating)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        // Automatically shows auth attempt when it appears
        .onAppear {
            guard !didAutoPromptForThisLock else { return }
            didAutoPromptForThisLock = true
            Task { await unlock() }
        }
    }
    
    // Handles biometric auth process
    @MainActor
    private func unlock() async {
        // Prevents duplicate auth attempts
        guard !isAuthenticating else { return }
        // Allow access is lock is disabled
        guard isFaceID else { unlocked = true; return }
        // Ensures device support for faceid
        guard auth.isAvailable() else { unlocked = false; return }
        isAuthenticating = true
        defer { isAuthenticating = false }
        do {
            // Attempts auth
            let ok = try await auth.authenticate(reason: "Unlock Calma")
            // Unlocks if successfull
            unlocked = ok
        } catch {
            // Fails/cancels -> remains locked
            unlocked = false
        }
    }
}
