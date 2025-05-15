import Foundation

enum GiphyAPIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL constructed"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Invalid response from server (Status: \(statusCode))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

class GiphyAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.giphy.com/v1/gifs"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func search(query: String, offset: Int32 = 0, limit: Int32 = 20) async throws -> GiphySearchResponse {
        var components = URLComponents(string: "\(baseURL)/search")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        guard let url = components?.url else {
            throw GiphyAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GiphyAPIError.invalidResponse(-1)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw GiphyAPIError.invalidResponse(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(GiphySearchResponse.self, from: data)
        } catch let error as DecodingError {
            throw GiphyAPIError.decodingError(error)
        } catch let error as GiphyAPIError {
            throw error
        } catch {
            throw GiphyAPIError.networkError(error)
        }
    }
} 