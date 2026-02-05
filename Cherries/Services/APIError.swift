import Foundation

/// Unified error type for all API operations
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unauthorized(reason: UnauthorizedReason)
    case unknown

    enum UnauthorizedReason {
        case invalidCredentials  // Login failed - wrong email/password
        case tokenExpired        // Token expired or invalid
        case unknown
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        case .unauthorized(let reason):
            switch reason {
            case .invalidCredentials:
                return "Invalid email or password"
            case .tokenExpired:
                return "Session expired. Please log in again."
            case .unknown:
                return "Unauthorized"
            }
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

/// Backend error response format (for JSON decoding)
struct ErrorResponse: Codable {
    let detail: String
}
