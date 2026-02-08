import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    convenience init() {
        self.init(authManager: .shared)
    }

    func saveUsername(_ username: String) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let updatedUser = try await ProfileService.shared.updateProfile(username: username)
            authManager.updateUser(updatedUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveAvatar(emoji: String) async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let avatarData = AvatarData(type: "emoji", value: emoji)
            let updatedUser = try await ProfileService.shared.updateProfile(avatar: avatarData)
            authManager.updateUser(updatedUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
