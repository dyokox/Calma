// BiometricAuth.swift
// Handles biometric authentication (Face/TouchID) using LocalAuthentication

import LocalAuthentication

// Custom error type,
// handling the case where biometrics are not available
enum BiometricError: Error {
    case notAvailable
}

// All interactions happen on main thread
@MainActor
final class BiometricAuth {
    
    // Checks if biometric auth is available on the device
    func isAvailable() -> Bool {
        let context = LAContext()
        // Captures any system error if it fails
        var error: NSError?
        // Returns true if device supports and available
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // Performs the biometric auth
    func authenticate(reason: String) async throws -> Bool{
        // Created before each auth session to ensure clean auth session
        let context = LAContext()
        
        // Checks again if auth is available before proceeding
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.notAvailable
        }
        
        // Performs the auth, using await until the user complets/cancels the action
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
}

