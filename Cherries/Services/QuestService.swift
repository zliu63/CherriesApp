import Foundation

enum QuestError: Error, LocalizedError {
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

class QuestService {
    static let shared = QuestService()

    private let baseURL = Constants.API.baseURL

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let iso8601Formatter = ISO8601DateFormatter()
            iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

            iso8601Formatter.formatOptions = [.withInternetDateTime]
            if let date = iso8601Formatter.date(from: dateString) {
                return date
            }

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

    // Create a new Quest
    func createQuest(token: String, questData: QuestCreate) async throws -> Quest {
        let url = URL(string: "\(baseURL)/quests")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONEncoder().encode(questData)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw QuestError.unknown
            }

            if httpResponse.statusCode == 201 {
                return try self.decoder.decode(Quest.self, from: data)
            } else if httpResponse.statusCode == 401 {
                throw QuestError.unauthorized
            } else {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw QuestError.serverError(apiError.detail)
                }
                throw QuestError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as QuestError {
            throw error
        } catch let error as DecodingError {
            throw QuestError.decodingError(error)
        } catch {
            throw QuestError.networkError(error)
        }
    }

    // Get all Quests for the current user
    func getQuests(token: String) async throws -> [Quest] {
        let url = URL(string: "\(baseURL)/quests")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw QuestError.unknown
            }

            if httpResponse.statusCode == 200 {
                return try self.decoder.decode([Quest].self, from: data)
            } else if httpResponse.statusCode == 401 {
                throw QuestError.unauthorized
            } else {
                throw QuestError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as QuestError {
            throw error
        } catch let error as DecodingError {
            throw QuestError.decodingError(error)
        } catch {
            throw QuestError.networkError(error)
        }
    }

    // Join a Quest using share code
    func joinQuest(token: String, shareCode: String) async throws -> Quest {
        let url = URL(string: "\(baseURL)/quests/join")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let joinRequest = QuestJoinRequest(shareCode: shareCode)
        request.httpBody = try JSONEncoder().encode(joinRequest)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw QuestError.unknown
            }

            if httpResponse.statusCode == 201 {
                return try self.decoder.decode(Quest.self, from: data)
            } else {
                if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw QuestError.serverError(apiError.detail)
                }
                throw QuestError.serverError("Server error: \(httpResponse.statusCode)")
            }
        } catch let error as QuestError {
            throw error
        } catch {
            throw QuestError.networkError(error)
        }
    }

    // Delete a Quest
    func deleteQuest(token: String, questId: String) async throws {
        let url = URL(string: "\(baseURL)/quests/\(questId)")!

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QuestError.unknown
        }

        if httpResponse.statusCode == 204 || httpResponse.statusCode == 200 {
            return
        } else if httpResponse.statusCode == 401 {
            throw QuestError.unauthorized
        } else {
            throw QuestError.serverError("Server error: \(httpResponse.statusCode)")
        }
    }
}
