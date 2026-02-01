import Foundation

struct AvatarData: Codable, Equatable {
    let type: String
    let value: String
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let username: String?
    let avatar: AvatarData?
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case avatar
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let user: User

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case user
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct SignupRequest: Codable {
    let email: String
    let username: String
    let password: String
}

struct LogoutResponse: Codable {
    let message: String
}

struct APIError: Codable {
    let detail: String
}

struct UserUpdate: Codable {
    let username: String?
    let avatar: AvatarData?
}
