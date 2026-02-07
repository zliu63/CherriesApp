import Foundation
import SwiftUI

@MainActor
final class QuestDetailViewModel: ObservableObject {
    @Published var quest: Quest
    @Published var checkIns: [CheckIn] = []
    @Published var stats: CheckInStats?
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var showCheckInPopup: Bool = false

    private let calendar = Calendar.current

    init(quest: Quest) {
        self.quest = quest
        // Set initial selected date to today or quest start date (whichever is later)
        let today = Date()
        if today < quest.startDate {
            self.selectedDate = quest.startDate
            self.currentMonth = quest.startDate
        } else if today > quest.endDate {
            self.selectedDate = quest.endDate
            self.currentMonth = quest.endDate
        } else {
            self.selectedDate = today
            self.currentMonth = today
        }
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        error = nil

        do {
            async let statsTask = CheckInService.shared.getStats(questId: quest.id)
            async let checkInsTask = CheckInService.shared.getCheckIns(
                questId: quest.id,
                forMonth: currentMonth
            )

            let (fetchedStats, fetchedCheckIns) = try await (statsTask, checkInsTask)
            stats = fetchedStats
            checkIns = fetchedCheckIns
        } catch {
            self.error = error.localizedDescription
            print("[QuestDetailViewModel] Failed to load data: \(error)")
        }

        isLoading = false
    }

    /// Load check-ins for the current month
    func loadCheckInsForCurrentMonth() async {
        do {
            checkIns = try await CheckInService.shared.getCheckIns(
                questId: quest.id,
                forMonth: currentMonth
            )
        } catch {
            print("[QuestDetailViewModel] Failed to load check-ins: \(error)")
        }
    }

    // MARK: - Check-in Operations

    /// Get count of check-ins for a specific task on a specific date
    func getCheckInCount(for task: DailyTask, on date: Date) -> Int {
        checkIns.first {
            $0.dailyTaskId == task.id &&
            calendar.isDate($0.checkInDate, inSameDayAs: date)
        }?.count ?? 0
    }

    /// Get the check-in for a specific task on a specific date
    func getCheckIn(for task: DailyTask, on date: Date) -> CheckIn? {
        let targetDate = calendar.startOfDay(for: date)
        return checkIns.first { checkIn in
            checkIn.dailyTaskId == task.id &&
            calendar.isDate(checkIn.checkInDate, inSameDayAs: targetDate)
        }
    }

    /// Add a check-in for a task on a specific date (increments count)
    func addCheckIn(for task: DailyTask, on date: Date) async {
        // Optimistically update UI so the counter feels instant.
        let previousCheckIns = checkIns
        let targetDate = calendar.startOfDay(for: date)
        var temporaryId: String?

        if let index = checkIns.firstIndex(where: { $0.dailyTaskId == task.id && calendar.isDate($0.checkInDate, inSameDayAs: targetDate) }) {
            let existing = checkIns[index]
            let optimistic = CheckIn(
                id: existing.id,
                userId: existing.userId,
                questId: existing.questId,
                dailyTaskId: existing.dailyTaskId,
                checkInDate: existing.checkInDate,
                count: existing.count + 1,
                notes: existing.notes,
                createdAt: existing.createdAt,
                updatedAt: existing.updatedAt
            )
            checkIns[index] = optimistic
        } else {
            let optimistic = CheckIn(
                id: "temp-\(UUID().uuidString)",
                userId: "",
                questId: quest.id,
                dailyTaskId: task.id,
                checkInDate: targetDate,
                count: 1,
                notes: nil,
                createdAt: Date(),
                updatedAt: nil
            )
            temporaryId = optimistic.id
            checkIns.append(optimistic)
        }

        do {
            let updatedCheckIn = try await CheckInService.shared.incrementCheckIn(
                questId: quest.id,
                dailyTaskId: task.id,
                date: date
            )
            // Replace optimistic entry with server response (using temp id or date/task match)
            if let tempId = temporaryId, let index = checkIns.firstIndex(where: { $0.id == tempId }) {
                checkIns[index] = updatedCheckIn
            } else if let index = checkIns.firstIndex(where: { $0.dailyTaskId == updatedCheckIn.dailyTaskId && calendar.isDate($0.checkInDate, inSameDayAs: updatedCheckIn.checkInDate) }) {
                checkIns[index] = updatedCheckIn
            } else {
                checkIns.append(updatedCheckIn)
            }
            await loadStats()
        } catch {
            // Roll back optimistic change on failure
            checkIns = previousCheckIns
            self.error = "Failed to create check-in"
            print("[QuestDetailViewModel] Increment check-in failed: \(error)")
        }
    }

    /// Remove one check-in for a task on a specific date (decrements count)
    func removeCheckIn(for task: DailyTask, on date: Date) async {
        guard let existingCheckIn = getCheckIn(for: task, on: date) else { return }

        // Optimistically update UI
        let previousCheckIns = checkIns
        if existingCheckIn.count > 1 {
            let optimistic = CheckIn(
                id: existingCheckIn.id,
                userId: existingCheckIn.userId,
                questId: existingCheckIn.questId,
                dailyTaskId: existingCheckIn.dailyTaskId,
                checkInDate: existingCheckIn.checkInDate,
                count: existingCheckIn.count - 1,
                notes: existingCheckIn.notes,
                createdAt: existingCheckIn.createdAt,
                updatedAt: existingCheckIn.updatedAt
            )
            if let index = checkIns.firstIndex(where: { $0.id == existingCheckIn.id }) {
                checkIns[index] = optimistic
            }
        } else {
            checkIns.removeAll { $0.id == existingCheckIn.id }
        }

        do {
            let updatedCheckIn = try await CheckInService.shared.decrementCheckIn(
                questId: quest.id,
                dailyTaskId: task.id,
                date: date
            )
            if let updated = updatedCheckIn {
                // Update the check-in with new count
                if let index = checkIns.firstIndex(where: { $0.id == updated.id }) {
                    checkIns[index] = updated
                }
            } else {
                // Check-in was deleted (count reached 0)
                checkIns.removeAll { $0.id == existingCheckIn.id }
            }
            await loadStats()
        } catch {
            // Roll back optimistic change on failure
            checkIns = previousCheckIns
            self.error = "Failed to remove check-in"
            print("[QuestDetailViewModel] Decrement check-in failed: \(error)")
        }
    }

    func toggleCheckIn(for task: DailyTask) async {
        if getCheckIn(for: task, on: selectedDate) != nil {
            await removeCheckIn(for: task, on: selectedDate)
        } else {
            await addCheckIn(for: task, on: selectedDate)
        }
    }

    private func loadStats() async {
        do {
            stats = try await CheckInService.shared.getStats(questId: quest.id)
        } catch {
            print("[QuestDetailViewModel] Failed to reload stats: \(error)")
        }
    }

    // MARK: - Date Helpers

    func isDateInQuestRange(_ date: Date) -> Bool {
        let start = calendar.startOfDay(for: quest.startDate)
        let end = calendar.startOfDay(for: quest.endDate)
        let target = calendar.startOfDay(for: date)
        return target >= start && target <= end
    }

    func canCheckIn(for date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        return isDateInQuestRange(date) && target <= today
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - Check-in Status

    func isTaskCompleted(_ task: DailyTask, on date: Date) -> Bool {
        getCheckIn(for: task, on: date) != nil
    }

    func completionStatus(for date: Date) -> CompletionStatus {
        guard isDateInQuestRange(date) else { return .none }

        let targetDate = calendar.startOfDay(for: date)
        let dayCheckIns = checkIns.filter { calendar.isDate($0.checkInDate, inSameDayAs: targetDate) }
        let totalTasks = quest.dailyTasks.count

        if totalTasks == 0 { return .none }
        if dayCheckIns.isEmpty { return .none }
        // Count unique tasks that have at least one check-in
        if dayCheckIns.count >= totalTasks { return .complete }
        return .partial
    }

    // MARK: - Calendar Navigation

    func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
            Task {
                await loadCheckInsForCurrentMonth()
            }
        }
    }

    func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
            Task {
                await loadCheckInsForCurrentMonth()
            }
        }
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var daysInMonth: [Date?] {
        var days: [Date?] = []

        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else { return days }

        // Add empty slots for days before the first of the month
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        for _ in 0..<leadingEmptyDays {
            days.append(nil)
        }

        // Add all days in the month
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? monthInterval.end
        }

        return days
    }

    var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday
        return Array(symbols[(firstWeekday - 1)...]) + Array(symbols[..<(firstWeekday - 1)])
    }
}

// MARK: - Completion Status

enum CompletionStatus {
    case none
    case partial
    case complete

    var color: Color {
        switch self {
        case .none: return .clear
        case .partial: return .orange
        case .complete: return .green
        }
    }

    var indicatorColor: Color {
        switch self {
        case .none: return Color.red.opacity(0.7)
        case .partial: return .orange
        case .complete: return .green
        }
    }
}
