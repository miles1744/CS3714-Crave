import Foundation

struct GeminiAPI {
    
    static let shared = GeminiAPI()
    private init() {}
    
    private var apiKey: String? {
        Secrets.shared.geminiAPIKey
    }
    
    func generateRecipe(prompt: String) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw NSError(
                domain: "Gemini",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing Gemini API key"]
            )
        }
        
        let endpoint =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        
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
        
        let userPrompt = "User request: \(prompt)"
        
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
        
        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "Gemini", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
        }
        
        guard 200..<300 ~= http.statusCode else {
            let bodyString = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(
                domain: "Gemini",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Gemini error: \(bodyString)"]
            )
        }
        
        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        return decoded.textOutput
    }
    
    // MARK: - Response Model
    
    struct GeminiResponse: Codable {
        let candidates: [Candidate]?
        
        struct Candidate: Codable { let content: Content? }
        struct Content: Codable   { let parts: [Part]? }
        struct Part: Codable      { let text: String? }
        
        var textOutput: String {
            candidates?.first?.content?.parts?
                .compactMap { $0.text }
                .joined(separator: "\n")
            ?? "No response from AI."
        }
    }
}
