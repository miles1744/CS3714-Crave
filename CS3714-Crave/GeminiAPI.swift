import Foundation

/// Singleton wrapper for making requests to the Gemini 2.5 Flash API
struct GeminiAPI {
    
    // Shared singleton instance
    static let shared = GeminiAPI()
    private init() {}
    
    // Retrieve API key from secure storage
    private var apiKey: String? {
        Secrets.shared.geminiAPIKey
    }
    
    /// Sends a prompt to Gemini and returns a condensed recipe string
    func generateRecipe(prompt: String) async throws -> String {
        // Ensure the API key exists and is not empty
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw NSError(
                domain: "Gemini",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing Gemini API key"]
            )
        }
        
        // API endpoint for Gemini 2.5 Flash content generation
        let endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        
        // Validate URL
        guard let url = URL(string: endpoint) else {
            throw NSError(
                domain: "Gemini",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid Gemini URL"]
            )
        }
        
        // 🟦 NEW: Condensed Response System Prompt
        let systemPrompt = """
        You are an AI that ALWAYS returns short, condensed recipe responses.
        Requirements:
        - Keep responses under 120 words.
        - Use short bullet points when possible.
        - Never include long paragraphs.
        - No Markdown code blocks.
        - No extra commentary.
        Only give the essential recipe idea.
        """
        
        // Wrap the user's prompt
        let userPrompt = "User request: \(prompt)"
        
        // Create the request body using Gemini API format
        let body: [String: Any] = [
            "system_instruction": [
                "role": "system",
                "parts": [
                    ["text": systemPrompt]
                ]
            ],
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": userPrompt]
                    ]
                ]
            ]
        ]
        
        // Serialize JSON body
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        // Configure URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send async request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate HTTP response
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "Gemini", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
        }
        
        // Handle non-2xx status codes
        guard 200..<300 ~= http.statusCode else {
            let bodyString = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "Gemini",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Gemini error: \(bodyString)"]
            )
        }
        
        // Decode Gemini response into structured model
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return decoded.textOutput
    }
    
    // MARK: - Response Model
    
    /// Codable structs to parse Gemini JSON response
    struct GeminiResponse: Codable {
        let candidates: [Candidate]?
        
        struct Candidate: Codable { let content: Content? }
        struct Content: Codable   { let parts: [Part]? }
        struct Part: Codable      { let text: String? }
        
        /// Extracts and joins all text parts from the first candidate
        var textOutput: String {
            candidates?.first?.content?.parts?
                .compactMap { $0.text }
                .joined(separator: "\n")
            ?? "No response from AI."
        }
    }
}
