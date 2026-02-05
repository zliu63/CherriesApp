import Foundation
import SwiftUI

@MainActor
final class AddQuestViewModel: ObservableObject {
    @Published var questName: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var dailyTasks: [TaskInput] = []
    @Published var isCreating: Bool = false
    @Published var errorMessage: String?
    @Published var joinCode: String = ""
    @Published var isJoining: Bool = false

    struct TaskInput: Identifiable {
        let id = UUID()
        var title: String
        var points: Int
    }

    func addTask(title: String, pointsString: String) {
        guard !title.isEmpty, let points = Int(pointsString), points > 0 else { return }
        dailyTasks.append(TaskInput(title: title, points: points))
    }

    func removeTask(id: UUID) {
        if let idx = dailyTasks.firstIndex(where: { $0.id == id }) {
            dailyTasks.remove(at: idx)
        }
    }

    func resetTaskDraft() { }

    func createQuest() async throws -> Quest {
        isCreating = true
        errorMessage = nil
        defer { isCreating = false }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let tasksToCreate: [DailyTaskCreate]? = dailyTasks.isEmpty ? nil : dailyTasks.map { task in
            DailyTaskCreate(
                title: task.title,
                description: nil,
                points: task.points
            )
        }

        let questData = QuestCreate(
            name: questName,
            description: nil,
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            dailyTasks: tasksToCreate
        )

        let newQuest = try await QuestService.shared.createQuest(questData: questData)

        return newQuest
    }

    func joinQuest() async throws -> Quest {
        // Basic validation: 9-digit numeric code
        let digitsOnly = joinCode.filter { $0.isNumber }
        guard digitsOnly.count == 9 else {
            throw APIError.serverError("Invalid sharing code. Please enter the 9-digit code.")
        }
        isJoining = true
        errorMessage = nil
        defer { isJoining = false }
        let quest = try await QuestService.shared.joinQuest(shareCode: digitsOnly)
        return quest
    }
}
