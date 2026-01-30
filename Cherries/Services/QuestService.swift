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

    private let baseURL = "http://localhost:8000/api/v1"

    private init() {}

    // 创建Quest
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Quest.self, from: data)
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

    // 获取所有Quests
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode([Quest].self, from: data)
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

    // 通过分享码加入Quest
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(Quest.self, from: data)
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
}
