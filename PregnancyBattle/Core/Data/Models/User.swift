import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let username: String
    let email: String
    let phoneNumber: String
    let nickname: String?
    let avatarUrl: String?
    let createdAt: Date
    let lastLoginAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case phoneNumber = "phoneNumber"
        case nickname
        case avatarUrl = "avatarUrl"
        case createdAt = "createdAt"
        case lastLoginAt = "lastLoginAt"
    }
}

struct CreateUserRequest: Codable {
    let username: String
    let email: String
    let phoneNumber: String
    let password: String
    let nickname: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let expiresIn: Int
    let user: User
}

struct SendVerificationCodeRequest: Codable {
    let email: String?
    let phoneNumber: String?
}

struct SendVerificationCodeResponse: Codable {
    let success: Bool
    let message: String
    let codeExpireTime: Date
}

struct VerifyCodeRequest: Codable {
    let email: String?
    let phoneNumber: String?
    let code: String
}

struct VerifyCodeResponse: Codable {
    let success: Bool
    let message: String
    let resetToken: String
}

struct ResetPasswordRequest: Codable {
    let resetToken: String
    let newPassword: String
}

struct ResetPasswordResponse: Codable {
    let success: Bool
    let message: String
}