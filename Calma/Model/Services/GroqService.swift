// GroqService.swift
// Responsible for the comm. with Groq AI API, acting as a network layer

import Foundation
import SwiftUI

// Defines the error that could occur with Groq API
enum GroqError: Error {
    case aiDisabled // No consent given
    case tokenLimitReached // Token limit reached
    case httpError(Int, String) // Generic HTTP response and API response message
    case unknown(String) // Fallback error for anything unexpected
}

@MainActor
final class GroqService {
    // The API key used for auth requests to Groq
    private let apiKey = "YOUR_API_KEY_HERE"
    // Single instance to allow shared access across the app
    static let shared = GroqService()
    // Base endpoint for the Groq API
    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    // Persistent user settings, if the user gave consent for AI or not
    @AppStorage("aiConsentGiven") private var aiConsentGiven = false

    // Responsible for sending the chat messages to Groq API
    // messages - array of message dictionaries
    // model - the ai model used
    // returns generated insight as string
    // throws error depending on type
    func send(messages: [[String: String]], model: String = "openai/gpt-oss-120b") async throws -> String {
        // Ensures that the ai wont run unless user has given explicit consent
        guard aiConsentGiven else {
            throw GroqError.aiDisabled
        }
        
        // Creates and configures the http request
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        // Auth header
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        // Specifies the request body format (json)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Constructs the expected json body
        let body: [String: Any] = [
            "model": model,
            "messages": messages,
            "max_tokens": 6600
        ]
        
        // Converts dictionary to json data for http transmission
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        // Async network request, suspending exec until response is received
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validates the http response to be proper
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Checks the http status code for success
        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempts at extracting the erorr message returned by api
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            // Specific for token limit errors
            if httpResponse.statusCode == 413 ||
               errorString.lowercased().contains("token") {
                throw GroqError.tokenLimitReached
            }
            // Generic http error for everything else
            throw GroqError.httpError(httpResponse.statusCode, errorString)
        }
    
        // Decodes json response into a swift model
        let decoded = try JSONDecoder().decode(GroqResponse.self, from: data)
        // Extarcts the ai message otherwise returns empty string if no valid response
        return decoded.choices.first?.message.content ?? ""
    }
}

// Represents the structure of the Groq API response
struct GroqResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
