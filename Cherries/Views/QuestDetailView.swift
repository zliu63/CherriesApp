import SwiftUI

struct QuestDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: QuestDetailViewModel

    init(quest: Quest) {
        _viewModel = StateObject(wrappedValue: QuestDetailViewModel(quest: quest))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Scoreboard
                ScoreboardView(participants: viewModel.quest.participants)

                // Calendar Grid
                CalendarGridView(viewModel: viewModel)

                // Stats Header
                StatsHeaderView(stats: viewModel.stats)

                // Hint text
                Text("Tap a date to check in")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .scrollContentBackground(.hidden)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "FFE8EC"),
                    Color(hex: "E8F4FF"),
                    Color(hex: "F0E8FF")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle(viewModel.quest.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(AppColors.secondary)
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
        .overlay {
            if viewModel.showCheckInPopup {
                CheckInPopupView(
                    viewModel: viewModel,
                    isPresented: $viewModel.showCheckInPopup,
                    selectedDate: viewModel.selectedDate
                )
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
        .task {
            await viewModel.loadData()
        }
    }
}

#Preview {
    let quest = Quest(
        id: "1",
        name: "30-Day Fitness",
        description: "Get fit in 30 days",
        startDate: Date().addingTimeInterval(-7 * 24 * 3600),
        endDate: Date().addingTimeInterval(23 * 24 * 3600),
        creatorId: "user1",
        shareCode: "ABC123",
        shareCodeExpiresAt: Date(),
        createdAt: Date(),
        updatedAt: nil,
        dailyTasks: [
            DailyTask(id: "1", questId: "1", title: "Morning Exercise", description: "30 minutes workout", points: 10, createdAt: Date()),
            DailyTask(id: "2", questId: "1", title: "Read a Book", description: nil, points: 5, createdAt: Date())
        ],
        participants: []
    )
    NavigationStack {
        QuestDetailView(quest: quest)
    }
}
