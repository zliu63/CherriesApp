import Foundation

/// Unified API client with automatic token refresh
/// All authenticated requests should go through this client
class APIClient {
    static let shared = APIClient()

    private let baseURL = Constants.API.baseURL
    private let session = URLSession.shared

    /// Custom date decoder that handles multiple date formats from the backend
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first
            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

            // Try ISO8601 without fractional seconds
            iso8601Formatter.formatOptions = [.withInternetDateTime]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

            // Try simple date format (yyyy-MM-dd)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(dateString)"
            )
        }
        return decoder
    }()

    private init() {}

    // MARK: - Public API

    /// Perform an authenticated GET request
    func get<T: Decodable>(_ path: String) async throws -> T {
        return try await request(path, method: "GET", body: nil as Empty?)
    }

    /// Perform an authenticated POST request
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        return try await request(path, method: "POST", body: body)
    }

    /// Perform an authenticated POST request without response body
    func post<B: Encodable>(_ path: String, body: B) async throws {
        let _: Empty = try await request(path, method: "POST", body: body)
    }

    /// Perform an authenticated PATCH request
    func patch<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        return try await request(path, method: "PATCH", body: body)
    }

    /// Perform an authenticated DELETE request
    func delete(_ path: String) async throws {
        let _: Empty = try await request(path, method: "DELETE", body: nil as Empty?)
    }

    // MARK: - Core Request Method

    private func request<T: Decodable, B: Encodable>(
        _ path: String,
        method: String,
        body: B?
    ) async throws -> T {
        // 1. Refresh token if needed (before making the request)
        await AuthManager.shared.refreshTokenIfNeeded()

        // 2. Get current token
        guard let token = await AuthManager.shared.accessToken else {
            throw APIError.unauthorized(reason: .tokenExpired)
        }

        // 3. Build request
        let url = URL(string: "\(baseURL)\(path)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        if let body = body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        // 4. Execute request
        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            // 5. Handle response
            switch httpResponse.statusCode {
            case 200, 201:
                return try decoder.decode(T.self, from: data)
            case 204:
                // No content - return empty for void responses
                if let empty = Empty() as? T {
                    return empty
                }
                throw APIError.unknown
            case 401:
                // Token invalid even after refresh - log out
                await AuthManager.shared.logout()
                throw APIError.unauthorized(reason: .tokenExpired)
            default:
                if let errResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errResponse.detail)
                }
                throw APIError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Helper Types

/// Empty type for requests/responses without body
private struct Empty: Codable {
    init() {}
}
