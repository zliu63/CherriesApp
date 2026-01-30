import Foundation

// 后端返回的完整Quest
struct Quest: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let creatorId: String
    let shareCode: String
    let shareCodeExpiresAt: Date
    let createdAt: Date
    let updatedAt: Date?
    let dailyTasks: [DailyTask]

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case startDate = "start_date"
        case endDate = "end_date"
        case creatorId = "creator_id"
        case shareCode = "share_code"
        case shareCodeExpiresAt = "share_code_expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case dailyTasks = "daily_tasks"
    }

    // 计算属性用于UI显示
    var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }

    var progress: Double {
        // TODO: 根据daily tasks计算进度
        return 0.0
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }
}

struct DailyTask: Codable, Identifiable {
    let id: String
    let questId: String
    let title: String
    let description: String?
    let points: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description, points
        case questId = "quest_id"
        case createdAt = "created_at"
    }
}

// 创建Quest的请求体
struct QuestCreate: Codable {
    let name: String
    let description: String?
    let startDate: String  // ISO 8601 format: "2024-01-15"
    let endDate: String
    let dailyTasks: [DailyTaskCreate]?

    enum CodingKeys: String, CodingKey {
        case name, description
        case startDate = "start_date"
        case endDate = "end_date"
        case dailyTasks = "daily_tasks"
    }
}

struct DailyTaskCreate: Codable {
    let title: String
    let description: String?
    let points: Int
}

// 加入Quest的请求体
struct QuestJoinRequest: Codable {
    let shareCode: String

    enum CodingKeys: String, CodingKey {
        case shareCode = "share_code"
    }
}
