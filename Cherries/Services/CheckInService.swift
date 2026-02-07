import Foundation

class CheckInService {
    static let shared = CheckInService()

    private init() {}

    /// Increment check-in count. Creates new record if not exists, otherwise increments count.
    func incrementCheckIn(questId: String, dailyTaskId: String, date: Date) async throws -> CheckIn {
        let request = CheckInCreate(questId: questId, dailyTaskId: dailyTaskId, date: date)
        return try await APIClient.shared.post("/checkins/increment", body: request)
    }

    /// Decrement check-in count. Returns nil if the check-in was deleted (count reached 0).
    func decrementCheckIn(questId: String, dailyTaskId: String, date: Date) async throws -> CheckIn? {
        let request = CheckInCreate(questId: questId, dailyTaskId: dailyTaskId, date: date)
        return try await APIClient.shared.post("/checkins/decrement", body: request)
    }

    /// Get check-ins for a quest. If forMonth is provided, returns check-ins for that month only.
    func getCheckIns(questId: String, forMonth date: Date? = nil) async throws -> [CheckIn] {
        var path = "/checkins/quest/\(questId)"
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            path += "?date=\(formatter.string(from: date))"
        }
        return try await APIClient.shared.get(path)
    }

    /// Get check-in statistics for a quest
    func getStats(questId: String) async throws -> CheckInStats {
        return try await APIClient.shared.get("/checkins/stats/\(questId)")
    }
}
