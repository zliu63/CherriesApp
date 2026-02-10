import SwiftUI

struct CalendarGridView: View {
    @ObservedObject var viewModel: QuestDetailViewModel

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: { viewModel.previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.secondary)
                }

                Spacer()

                Text(viewModel.monthTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: { viewModel.nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.secondary)
                }
            }
            .padding(.horizontal, 8)

            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(Array(viewModel.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(viewModel.daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isToday: viewModel.isToday(date),
                            isSelected: viewModel.isSelected(date),
                            isInRange: viewModel.isDateInQuestRange(date),
                            completionStatus: viewModel.completionStatus(for: date)
                        )
                        .onTapGesture {
                            if viewModel.isDateInQuestRange(date) {
                                viewModel.selectedDate = date
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.showCheckInPopup = true
                                }
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
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

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let isInRange: Bool
    let completionStatus: CompletionStatus

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Selection/Today indicator
                if isSelected {
                    Circle()
                        .fill(AppColors.secondary)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(AppColors.secondary, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }

                Text(dayNumber)
                    .font(.system(size: 16, weight: isToday || isSelected ? .semibold : .regular))
                    .foregroundColor(textColor)
            }
            .frame(width: 44, height: 36)

            // Completion indicator dot
            if isInRange && completionStatus != .none {
                Circle()
                    .fill(completionStatus.indicatorColor)
                    .frame(width: 6, height: 6)
            } else if isInRange {
                // Show red dot for days with no check-ins (only past days)
                let today = Calendar.current.startOfDay(for: Date())
                let thisDay = Calendar.current.startOfDay(for: date)
                if thisDay < today {
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 44)
        .opacity(isInRange ? 1.0 : 0.3)
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isInRange {
            return .gray.opacity(0.5)
        } else {
            return .primary
        }
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
        dailyTasks: [],
        participants: []
    )
    CalendarGridView(viewModel: QuestDetailViewModel(quest: quest))
        .padding()
        .background(Color.gray.opacity(0.1))
}
