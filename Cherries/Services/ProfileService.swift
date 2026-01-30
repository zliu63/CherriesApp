import Foundation

enum ProfileError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case unknown

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
        case .unauthorized:
            return "Unauthorized"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class ProfileService {
    static let shared = ProfileService()

    // TODO: Update this to your actual backend URL
    private let baseURL = "http://localhost:8000/api/v1"

    private init() {}

    func updateProfile(token: String, avatar: AvatarData? = nil, username: String? = nil) async throws -> User {
        let url = URL(string: "\(baseURL)/profile")!

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let updateRequest = UserUpdate(username: username, avatar: avatar)
        request.httpBody = try JSONEncoder().encode(updateRequest)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ProfileError.unknown
            }

            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(User.self, from: data)
            } else if httpResponse.statusCode == 401 {
                throw ProfileError.unauthorized
            } else {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw ProfileError.serverError(apiError.detail)
                }
                throw ProfileError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as ProfileError {
            throw error
        } catch let error as DecodingError {
            throw ProfileError.decodingError(error)
        } catch {
            throw ProfileError.networkError(error)
        }
    }
}
