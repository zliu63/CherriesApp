import Foundation

/// Check-in API response model
struct CheckIn: Codable, Identifiable {
    let id: String
    let userId: String
    let questId: String
    let dailyTaskId: String
    let checkInDate: Date
    let count: Int
    let notes: String?
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case questId = "quest_id"
        case dailyTaskId = "daily_task_id"
        case checkInDate = "check_in_date"
        case count
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Check-in create request model
struct CheckInCreate: Codable {
    let questId: String
    let dailyTaskId: String
    let checkInDate: String  // yyyy-MM-dd format
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case questId = "quest_id"
        case dailyTaskId = "daily_task_id"
        case checkInDate = "check_in_date"
        case notes
    }

    init(questId: String, dailyTaskId: String, date: Date, notes: String? = nil) {
        self.questId = questId
        self.dailyTaskId = dailyTaskId
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.checkInDate = formatter.string(from: date)
        self.notes = notes
    }
}

/// Check-in statistics response model
struct CheckInStats: Codable {
    let questId: String
    let userId: String
    let totalCheckIns: Int
    let totalPoints: Int
    let currentStreak: Int
    let longestStreak: Int

    enum CodingKeys: String, CodingKey {
        case questId = "quest_id"
        case userId = "user_id"
        case totalCheckIns = "total_check_ins"
        case totalPoints = "total_points"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
    }
}
