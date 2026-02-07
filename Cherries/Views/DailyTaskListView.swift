import SwiftUI

struct DailyTaskListView: View {
    @ObservedObject var viewModel: QuestDetailViewModel

    private var selectedDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: viewModel.selectedDate)
    }

    private var canCheckInToday: Bool {
        viewModel.canCheckIn(for: viewModel.selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date Header
            HStack {
                Text(selectedDateFormatted)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                if !canCheckInToday {
                    Text("Future date")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            // Task List
            if viewModel.quest.dailyTasks.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checklist")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No tasks for this quest")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(viewModel.quest.dailyTasks) { task in
                    TaskRowView(
                        task: task,
                        isCompleted: viewModel.isTaskCompleted(task, on: viewModel.selectedDate),
                        canCheckIn: canCheckInToday
                    ) {
                        Task {
                            await viewModel.toggleCheckIn(for: task)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct TaskRowView: View {
    let task: DailyTask
    let isCompleted: Bool
    let canCheckIn: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: {
            if canCheckIn {
                onToggle()
            }
        }) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isCompleted ? AppColors.accent : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCompleted {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Task Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)

                    if let description = task.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Points Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("+\(task.points)")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(isCompleted ? AppColors.accent : AppColors.achievementOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    (isCompleted ? AppColors.accent : AppColors.achievementOrange)
                        .opacity(0.1)
                )
                .cornerRadius(8)
            }
            .padding(12)
            .background(
                isCompleted
                    ? AppColors.accent.opacity(0.05)
                    : Color.gray.opacity(0.03)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(canCheckIn ? 1.0 : 0.6)
        .disabled(!canCheckIn)
    }
}

#Preview {
    let quest = Quest(
        id: "1",
        name: "Test Quest",
        description: nil,
        startDate: Date().addingTimeInterval(-7 * 24 * 3600),
        endDate: Date().addingTimeInterval(23 * 24 * 3600),
        creatorId: "user1",
        shareCode: "ABC123",
        shareCodeExpiresAt: Date(),
        createdAt: Date(),
        updatedAt: nil,
        dailyTasks: [
            DailyTask(id: "1", questId: "1", title: "Morning Exercise", description: "30 minutes workout", points: 10, createdAt: Date()),
            DailyTask(id: "2", questId: "1", title: "Read a Book", description: nil, points: 5, createdAt: Date()),
            DailyTask(id: "3", questId: "1", title: "Drink Water", description: "8 glasses", points: 3, createdAt: Date())
        ],
        participants: []
    )
    DailyTaskListView(viewModel: QuestDetailViewModel(quest: quest))
        .padding()
        .background(Color.gray.opacity(0.1))
}
