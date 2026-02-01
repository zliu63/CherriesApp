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

    struct TaskInput: Identifiable {
        let id = UUID()
        var title: String
        var points: Int
    }

    private let authManager: AuthManager

    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
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
        guard let token = authManager.accessToken else {
            throw AuthError.unauthorized
        }
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

        let newQuest = try await QuestService.shared.createQuest(
            token: token,
            questData: questData
        )

        return newQuest
    }
}
