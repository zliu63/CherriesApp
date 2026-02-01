import Foundation

enum AuthError: Error, LocalizedError {
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
            return "Invalid email or password"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class AuthService {
    static let shared = AuthService()

    private let baseURL = Constants.API.baseURL

    private init() {}

    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.unknown
            }

            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(AuthResponse.self, from: data)
            } else if httpResponse.statusCode == 401 {
                throw AuthError.unauthorized
            } else {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw AuthError.serverError(apiError.detail)
                }
                throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as AuthError {
            throw error
        } catch let error as DecodingError {
            throw AuthError.decodingError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    func signup(email: String, username: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(baseURL)/auth/register")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let signupRequest = SignupRequest(email: email, username: username, password: password)
        request.httpBody = try JSONEncoder().encode(signupRequest)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.unknown
            }

            if httpResponse.statusCode == 201 {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(AuthResponse.self, from: data)
            } else {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw AuthError.serverError(apiError.detail)
                }
                throw AuthError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as AuthError {
            throw error
        } catch let error as DecodingError {
            throw AuthError.decodingError(error)
        } catch {
            throw AuthError.networkError(error)
        }
    }

    func logout(token: String) async throws {
        let url = URL(string: "\(baseURL)/auth/logout")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AuthError.unknown
        }
    }
}
