import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false

    private let tokenKey = "cherries_access_token"
    private let userKey = "cherries_user"

    private init() {
        loadStoredSession()
    }

    var accessToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    private func loadStoredSession() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    private func saveSession(token: String, user: User) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userKey)
        }
        self.currentUser = user
        self.isAuthenticated = true
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.currentUser = nil
        self.isAuthenticated = false
    }

    func login(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let response = try await AuthService.shared.login(email: email, password: password)
        saveSession(token: response.accessToken, user: response.user)
    }

    func signup(email: String, username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let response = try await AuthService.shared.signup(email: email, username: username, password: password)
        saveSession(token: response.accessToken, user: response.user)
    }

    func logout() async {
        isLoading = true
        defer { isLoading = false }

        if let token = accessToken {
            try? await AuthService.shared.logout(token: token)
        }
        clearSession()
    }
}
