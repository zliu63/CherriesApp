import Foundation

class QuestService {
    static let shared = QuestService()

    private init() {}

    /// Create a new Quest
    func createQuest(questData: QuestCreate) async throws -> Quest {
        return try await APIClient.shared.post("/quests", body: questData)
    }

    /// Get all Quests for the current user
    func getQuests() async throws -> [Quest] {
        return try await APIClient.shared.get("/quests")
    }

    /// Join a Quest using share code
    func joinQuest(shareCode: String) async throws -> Quest {
        let joinRequest = QuestJoinRequest(shareCode: shareCode)
        return try await APIClient.shared.post("/quests/join", body: joinRequest)
    }

    /// Delete a Quest
    func deleteQuest(questId: String) async throws {
        try await APIClient.shared.delete("/quests/\(questId)")
    }
}
