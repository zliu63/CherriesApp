import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false

    private let tokenKey = "cherries_access_token"
    private let refreshTokenKey = "cherries_refresh_token"
    private let tokenTimestampKey = "cherries_token_timestamp"
    private let userKey = "cherries_user"

    /// Token refresh threshold in seconds (15 minutes)
    private let tokenRefreshThreshold: TimeInterval = 15 * 60

    private init() {
        loadStoredSession()
    }

    var accessToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    var refreshToken: String? {
        UserDefaults.standard.string(forKey: refreshTokenKey)
    }

    var tokenTimestamp: Date? {
        UserDefaults.standard.object(forKey: tokenTimestampKey) as? Date
    }

    /// Check if token needs refresh (older than 15 minutes)
    var shouldRefreshToken: Bool {
        guard let timestamp = tokenTimestamp else { return true }
        return Date().timeIntervalSince(timestamp) > tokenRefreshThreshold
    }

    private func loadStoredSession() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    private func saveSession(token: String, refreshToken: String, user: User) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        UserDefaults.standard.set(Date(), forKey: tokenTimestampKey)
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
        self.currentUser = user
        self.isAuthenticated = true
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenTimestampKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.currentUser = nil
        self.isAuthenticated = false
    }

    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let response = try await AuthService.shared.login(email: email, password: password)
        saveSession(token: response.accessToken, refreshToken: response.refreshToken, user: response.user)
    }

    func signup(email: String, username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let response = try await AuthService.shared.signup(email: email, username: username, password: password)
        saveSession(token: response.accessToken, refreshToken: response.refreshToken, user: response.user)
    }

    func logout() async {
        isLoading = true
        defer { isLoading = false }

        if let token = accessToken {
            try? await AuthService.shared.logout(token: token)
        }
        clearSession()
    }

    /// Refresh access token if needed (token older than 15 minutes)
    func refreshTokenIfNeeded() async {
        guard isAuthenticated,
              shouldRefreshToken,
              let currentRefreshToken = refreshToken else {
            return
        }

        do {
            let response = try await AuthService.shared.refreshToken(refreshToken: currentRefreshToken)
            saveSession(token: response.accessToken, refreshToken: response.refreshToken, user: response.user)
            print("[AuthManager] Token refreshed successfully")
        } catch {
            print("[AuthManager] Failed to refresh token: \(error.localizedDescription)")
            // If refresh fails (e.g., refresh token expired), log the user out
            if case APIError.unauthorized = error {
                await logout()
            }
        }
    }

    func updateUser(_ updatedUser: User) {
        self.currentUser = updatedUser
        if let token = accessToken, let refresh = refreshToken {
            saveSession(token: token, refreshToken: refresh, user: updatedUser)
        }
    }
}
