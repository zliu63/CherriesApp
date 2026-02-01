import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var isFetching: Bool = false

    private var lastFetchAt: Date?
    private let throttleInterval: TimeInterval = 30

    private let authManager: AuthManager

    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }

    func fetchQuests(force: Bool = false) async {
        if !force {
            if let last = lastFetchAt, Date().timeIntervalSince(last) < throttleInterval {
                return
            }
        }
        lastFetchAt = Date()

        guard authManager.isAuthenticated, let token = authManager.accessToken else { return }
        if isFetching { return }
        isFetching = true
        defer { isFetching = false }
        do {
            let fetched = try await QuestService.shared.getQuests(token: token)
            quests = fetched
        } catch {
            print("[HomeViewModel] Failed to fetch quests: \(error)")
        }
    }

    func clearOnLogout() {
        quests.removeAll()
    }
}
