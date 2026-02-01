import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?

    private let authManager: AuthManager

    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }

    func saveAvatar(emoji: String) async {
        guard let token = authManager.accessToken else { return }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let avatarData = AvatarData(type: "emoji", value: emoji)
            let updatedUser = try await ProfileService.shared.updateProfile(
                token: token,
                avatar: avatarData
            )
            authManager.updateUser(updatedUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
