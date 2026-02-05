import Foundation

class ProfileService {
    static let shared = ProfileService()

    private init() {}

    /// Update user profile (avatar and/or username)
    func updateProfile(avatar: AvatarData? = nil, username: String? = nil) async throws -> User {
        let updateRequest = UserUpdate(username: username, avatar: avatar)
        return try await APIClient.shared.patch("/profile", body: updateRequest)
    }
}
