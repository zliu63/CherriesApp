import SwiftUI

struct CheckInPopupView: View {
    @ObservedObject var viewModel: QuestDetailViewModel
    @Binding var isPresented: Bool
    let selectedDate: Date

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }

    private var canCheckIn: Bool {
        viewModel.canCheckIn(for: selectedDate)
    }

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }

            // Popup content
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text(dateFormatted)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)

                    if !canCheckIn {
                        Text("Cannot check in for future dates")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                Divider()

                // Task list with counters
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.quest.dailyTasks) { task in
                            TaskCounterRow(
                                viewModel: viewModel,
                                task: task,
                                selectedDate: selectedDate,
                                canCheckIn: canCheckIn
                            )
                        }
                    }
                    .padding(20)
                }
                .frame(maxHeight: 400)

                Divider()

                // Close button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                }) {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.secondary)
                        .cornerRadius(12)
                }
                .padding(20)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 24)
        }
    }
}

struct TaskCounterRow: View {
    @ObservedObject var viewModel: QuestDetailViewModel
    let task: DailyTask
    let selectedDate: Date
    let canCheckIn: Bool

    private var count: Int {
        viewModel.getCheckInCount(for: task, on: selectedDate)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Task info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("+\(task.points) pts")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(AppColors.achievementOrange)
            }

            Spacer()

            // Counter controls
            HStack(spacing: 16) {
                // Decrement button
                Button(action: {
                    Task {
                        await viewModel.removeCheckIn(for: task, on: selectedDate)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(count > 0 ? AppColors.primary : Color.gray.opacity(0.3))
                }
                .disabled(count == 0)

                // Count display
                Text("\(count)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(minWidth: 30)

                // Increment button
                Button(action: {
                    Task {
                        await viewModel.addCheckIn(for: task, on: selectedDate)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(canCheckIn ? AppColors.accent : Color.gray.opacity(0.3))
                }
                .disabled(!canCheckIn)
            }
        }
        .padding(16)
        .background(
            count > 0
                ? AppColors.accent.opacity(0.08)
                : Color.gray.opacity(0.05)
        )
        .cornerRadius(12)
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
            DailyTask(id: "1", questId: "1", title: "Morning Exercise", description: "30 min workout", points: 10, createdAt: Date()),
            DailyTask(id: "2", questId: "1", title: "Read a Book", description: nil, points: 5, createdAt: Date()),
            DailyTask(id: "3", questId: "1", title: "Drink Water", description: "8 glasses", points: 3, createdAt: Date())
        ],
        participants: []
    )
    CheckInPopupView(
        viewModel: QuestDetailViewModel(quest: quest),
        isPresented: .constant(true),
        selectedDate: Date()
    )
}
