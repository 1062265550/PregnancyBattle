import Foundation
import Combine
import SwiftUI

@MainActor // 将 AuthManager 标记为在主 Actor 上运行
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var currentUser: UserInfo?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?

    // 用户信息模型
    struct UserInfo: Codable, Identifiable {
        let id: UUID
        let username: String
        let email: String
        let phoneNumber: String?  // 修改为可选类型，因为后端可能返回null
        let nickname: String?
        let avatarUrl: String?
        let createdAt: Date
        let lastLoginAt: Date?

        // 添加CodingKeys枚举，用于自定义解码
        enum CodingKeys: String, CodingKey {
            case id
            case username
            case email
            case phoneNumber
            case nickname
            case avatarUrl
            case createdAt
            case lastLoginAt
        }

        // 添加自定义初始化方法，用于在LoginResponseData中创建实例
        init(id: UUID, username: String, email: String, phoneNumber: String?, nickname: String?, avatarUrl: String?, createdAt: Date, lastLoginAt: Date?) {
            self.id = id
            self.username = username
            self.email = email
            self.phoneNumber = phoneNumber
            self.nickname = nickname
            self.avatarUrl = avatarUrl
            self.createdAt = createdAt
            self.lastLoginAt = lastLoginAt
        }

        // 自定义解码初始化器
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(UUID.self, forKey: .id)
            username = try container.decode(String.self, forKey: .username)
            email = try container.decode(String.self, forKey: .email)
            phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
            nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
            avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)

            // 手动解析日期字符串
            let createdAtString = try container.decode(String.self, forKey: .createdAt)
            let lastLoginAtString = try container.decodeIfPresent(String.self, forKey: .lastLoginAt)

            // 创建ISO8601格式解析器（带毫秒）
            let iso8601WithMilliseconds = ISO8601DateFormatter()
            iso8601WithMilliseconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            // 创建支持7位小数的日期格式解析器
            let extendedDateFormatter = DateFormatter()
            extendedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
            extendedDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            extendedDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            // 解析createdAt
            var createdAtDate: Date? = nil

            // 首先尝试使用带毫秒的ISO8601格式解析
            createdAtDate = iso8601WithMilliseconds.date(from: createdAtString)

            // 然后尝试使用支持7位小数的日期格式解析器
            if createdAtDate == nil {
                createdAtDate = extendedDateFormatter.date(from: createdAtString)
            }

            // 如果还是解析失败，尝试手动处理
            if createdAtDate == nil && createdAtString.contains(".") && createdAtString.hasSuffix("Z") {
                // 提取基本部分和小数部分
                let components = createdAtString.components(separatedBy: ".")
                if components.count == 2 {
                    let basePart = components[0]
                    var fractionalPart = components[1]

                    // 移除Z后缀
                    if fractionalPart.hasSuffix("Z") {
                        fractionalPart = String(fractionalPart.dropLast())
                    }

                    // 限制小数部分为3位（毫秒）
                    let milliseconds = fractionalPart.prefix(3)

                    // 重新组合日期字符串
                    let reformattedDateString = "\(basePart).\(milliseconds)Z"

                    // 尝试使用ISO8601解析重新格式化的字符串
                    createdAtDate = iso8601WithMilliseconds.date(from: reformattedDateString)
                }
            }

            guard let finalCreatedAtDate = createdAtDate else {
                print("[UserInfo] 无法解析createdAt日期: \(createdAtString)")
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath + [CodingKeys.createdAt],
                        debugDescription: "无法解析createdAt日期: \(createdAtString)"
                    )
                )
            }
            createdAt = finalCreatedAtDate

            // 解析lastLoginAt（如果存在）
            if let lastLoginAtStr = lastLoginAtString {
                // 首先尝试使用带毫秒的ISO8601格式解析
                var parsedDate = iso8601WithMilliseconds.date(from: lastLoginAtStr)

                // 然后尝试使用支持7位小数的日期格式解析器
                if parsedDate == nil {
                    parsedDate = extendedDateFormatter.date(from: lastLoginAtStr)
                }

                // 如果还是解析失败，尝试手动处理
                if parsedDate == nil && lastLoginAtStr.contains(".") && lastLoginAtStr.hasSuffix("Z") {
                    // 提取基本部分和小数部分
                    let components = lastLoginAtStr.components(separatedBy: ".")
                    if components.count == 2 {
                        let basePart = components[0]
                        var fractionalPart = components[1]

                        // 移除Z后缀
                        if fractionalPart.hasSuffix("Z") {
                            fractionalPart = String(fractionalPart.dropLast())
                        }

                        // 限制小数部分为3位（毫秒）
                        let milliseconds = fractionalPart.prefix(3)

                        // 重新组合日期字符串
                        let reformattedDateString = "\(basePart).\(milliseconds)Z"

                        // 尝试使用ISO8601解析重新格式化的字符串
                        parsedDate = iso8601WithMilliseconds.date(from: reformattedDateString)
                    }
                }

                if let finalParsedDate = parsedDate {
                    lastLoginAt = finalParsedDate
                } else {
                    print("[UserInfo] 警告：无法解析lastLoginAt日期: \(lastLoginAtStr)，使用当前时间")
                    lastLoginAt = Date() // 使用当前时间作为后备
                }
            } else {
                lastLoginAt = nil
            }
        }
    }

    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userKey = "currentUser"

    var accessToken: String? {
        get { userDefaults.string(forKey: accessTokenKey) }
        set { userDefaults.set(newValue, forKey: accessTokenKey) }
    }

    var refreshToken: String? {
        get { userDefaults.string(forKey: refreshTokenKey) }
        set { userDefaults.set(newValue, forKey: refreshTokenKey) }
    }

    private init() {
        // 从UserDefaults加载用户信息
        if let userData = userDefaults.data(forKey: userKey) {
            // 使用与APIService相同的日期解析配置
            let decoder = JSONDecoder()

            // 不需要创建自定义格式解析器，因为我们使用标准的ISO8601解码策略

            // 使用标准的ISO8601解码策略，而不是自定义闭包
            decoder.dateDecodingStrategy = .iso8601

            if let user = try? decoder.decode(UserInfo.self, from: userData) {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                print("[AuthManager] 无法解码保存的用户数据")
            }
        }
    }

    // 用户注册请求模型
    struct CreateUserRequest: Codable {
        let username: String
        let email: String
        let phoneNumber: String
        let password: String
        let nickname: String?
    }

    // 用户注册响应模型
    struct RegisterResponse: Codable {
        let success: Bool
        let message: String?
        let code: String?
        let data: UserInfo?

        // 自定义解码初始化器
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            success = try container.decode(Bool.self, forKey: .success)
            message = try container.decodeIfPresent(String.self, forKey: .message)
            code = try container.decodeIfPresent(String.self, forKey: .code)
            data = try container.decodeIfPresent(UserInfo.self, forKey: .data)
        }
    }

    func register(username: String, email: String, phoneNumber: String, password: String, nickname: String?) async throws {
        isLoading = true
        error = nil

        do {
            let request = CreateUserRequest(
                username: username,
                email: email,
                phoneNumber: phoneNumber,
                password: password,
                nickname: nickname
            )

            do {
                // 使用RegisterResponse模型来匹配后端的响应格式
                let response: RegisterResponse = try await APIService.shared.request(
                    endpoint: "users/register",
                    method: "POST",
                    body: request
                )

                // 检查响应是否成功
                if !response.success {
                    print("[AuthManager] Register failed with error: \(response.message ?? "N/A"), Code: \(response.code ?? "N/A")")
                    throw APIError.businessError(message: response.message ?? "注册失败", code: response.code)
                }

                // 保存返回的用户信息
                if let user = response.data {
                    print("[AuthManager] Register successful. User data received: \(user.username)")
                    // 可以选择在这里保存更多用户信息，但不设置isAuthenticated
                    // 因为我们希望用户通过登录界面登录
                }

                self.isLoading = false
                return
            } catch let apiError as APIError {
                print("[AuthManager] Register caught APIError: \(apiError)")

                // 特别处理业务逻辑错误
                if case .businessError(let message, _) = apiError {
                    print("[AuthManager] Business error detected: \(message)")
                    self.error = message
                } else {
                    self.error = self.handleError(apiError)
                }

                self.isLoading = false
                throw apiError
            }
        } catch let apiError as APIError {
            self.isLoading = false
            print("[AuthManager] Register caught APIError (outer): \(apiError)")

            // 确保错误信息被设置
            if self.error == nil {
                self.error = self.handleError(apiError)
            }

            throw apiError
        } catch {
            self.isLoading = false
            print("[AuthManager] Register caught unknown error: \(error)")
            self.error = error.localizedDescription
            throw error
        }
    }

    // 登录请求模型
    struct LoginRequest: Codable {
        let username: String
        let password: String
    }

    // 登录响应数据模型
    struct LoginResponseData: Codable {
        let accessToken: String
        let refreshToken: String
        let tokenType: String
        let expiresIn: Int
        let user: UserInfo

        // 自定义解码初始化器
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            accessToken = try container.decode(String.self, forKey: .accessToken)
            refreshToken = try container.decode(String.self, forKey: .refreshToken)
            tokenType = try container.decode(String.self, forKey: .tokenType)
            expiresIn = try container.decode(Int.self, forKey: .expiresIn)

            // 使用自定义解码方式解析user字段
            let userContainer = try container.nestedContainer(keyedBy: UserInfo.CodingKeys.self, forKey: .user)

            let id = try userContainer.decode(UUID.self, forKey: .id)
            let username = try userContainer.decode(String.self, forKey: .username)
            let email = try userContainer.decode(String.self, forKey: .email)
            let phoneNumber = try userContainer.decode(String.self, forKey: .phoneNumber)
            let nickname = try userContainer.decodeIfPresent(String.self, forKey: .nickname)
            let avatarUrl = try userContainer.decodeIfPresent(String.self, forKey: .avatarUrl)

            // 手动解析日期字符串
            let createdAtString = try userContainer.decode(String.self, forKey: .createdAt)
            let lastLoginAtString = try userContainer.decodeIfPresent(String.self, forKey: .lastLoginAt)

            // 创建ISO8601格式解析器（带毫秒）
            let iso8601WithMilliseconds = ISO8601DateFormatter()
            iso8601WithMilliseconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            // 创建支持7位小数的日期格式解析器
            let extendedDateFormatter = DateFormatter()
            extendedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
            extendedDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            extendedDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            // 解析createdAt
            var createdAtDate: Date? = nil

            // 首先尝试使用带毫秒的ISO8601格式解析
            createdAtDate = iso8601WithMilliseconds.date(from: createdAtString)

            // 然后尝试使用支持7位小数的日期格式解析器
            if createdAtDate == nil {
                createdAtDate = extendedDateFormatter.date(from: createdAtString)
            }

            // 如果还是解析失败，尝试手动处理
            if createdAtDate == nil && createdAtString.contains(".") && createdAtString.hasSuffix("Z") {
                // 提取基本部分和小数部分
                let components = createdAtString.components(separatedBy: ".")
                if components.count == 2 {
                    let basePart = components[0]
                    var fractionalPart = components[1]

                    // 移除Z后缀
                    if fractionalPart.hasSuffix("Z") {
                        fractionalPart = String(fractionalPart.dropLast())
                    }

                    // 限制小数部分为3位（毫秒）
                    let milliseconds = fractionalPart.prefix(3)

                    // 重新组合日期字符串
                    let reformattedDateString = "\(basePart).\(milliseconds)Z"

                    // 尝试使用ISO8601解析重新格式化的字符串
                    createdAtDate = iso8601WithMilliseconds.date(from: reformattedDateString)
                }
            }

            guard let createdAt = createdAtDate else {
                print("[LoginResponseData] 无法解析createdAt日期: \(createdAtString)")
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: userContainer.codingPath + [UserInfo.CodingKeys.createdAt],
                        debugDescription: "无法解析createdAt日期: \(createdAtString)"
                    )
                )
            }

            // 解析lastLoginAt（如果存在）
            var lastLoginAt: Date? = nil
            if let lastLoginAtStr = lastLoginAtString {
                // 首先尝试使用带毫秒的ISO8601格式解析
                var parsedDate = iso8601WithMilliseconds.date(from: lastLoginAtStr)

                // 然后尝试使用支持7位小数的日期格式解析器
                if parsedDate == nil {
                    parsedDate = extendedDateFormatter.date(from: lastLoginAtStr)
                }

                // 如果还是解析失败，尝试手动处理
                if parsedDate == nil && lastLoginAtStr.contains(".") && lastLoginAtStr.hasSuffix("Z") {
                    // 提取基本部分和小数部分
                    let components = lastLoginAtStr.components(separatedBy: ".")
                    if components.count == 2 {
                        let basePart = components[0]
                        var fractionalPart = components[1]

                        // 移除Z后缀
                        if fractionalPart.hasSuffix("Z") {
                            fractionalPart = String(fractionalPart.dropLast())
                        }

                        // 限制小数部分为3位（毫秒）
                        let milliseconds = fractionalPart.prefix(3)

                        // 重新组合日期字符串
                        let reformattedDateString = "\(basePart).\(milliseconds)Z"

                        // 尝试使用ISO8601解析重新格式化的字符串
                        parsedDate = iso8601WithMilliseconds.date(from: reformattedDateString)
                    }
                }

                lastLoginAt = parsedDate
                if lastLoginAt == nil {
                    print("[LoginResponseData] 警告：无法解析lastLoginAt日期: \(lastLoginAtStr)，使用当前时间")
                    lastLoginAt = Date() // 使用当前时间作为后备
                }
            }

            // 创建UserInfo实例
            user = UserInfo(
                id: id,
                username: username,
                email: email,
                phoneNumber: phoneNumber,
                nickname: nickname,
                avatarUrl: avatarUrl,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt
            )
        }
    }

    // 登录响应模型
    struct LoginResponse: Codable {
        let success: Bool
        let message: String?
        let data: LoginResponseData?
    }

    func login(username: String, password: String) async throws {
        isLoading = true
        error = nil

        do {
            let request = LoginRequest(username: username, password: password)

            print("[AuthManager] 开始登录请求: \(username)")

            let response: LoginResponse = try await APIService.shared.request(
                endpoint: "users/login",
                method: "POST",
                body: request
            )

            print("[AuthManager] 登录响应成功: success=\(response.success), message=\(response.message ?? "无")")

            // 检查响应是否成功
            if !response.success {
                print("[AuthManager] 登录响应标记为不成功")
                throw APIError.businessError(message: response.message ?? "登录失败", code: nil)
            }

            // 确保响应中包含数据
            guard let responseData = response.data else {
                print("[AuthManager] 登录响应中没有data字段")
                throw APIError.businessError(message: "登录成功但未返回用户数据", code: nil)
            }

            print("[AuthManager] 用户信息: id=\(responseData.user.id), username=\(responseData.user.username), createdAt=\(responseData.user.createdAt), lastLoginAt=\(String(describing: responseData.user.lastLoginAt))")

            self.accessToken = responseData.accessToken
            self.refreshToken = responseData.refreshToken
            self.currentUser = responseData.user

            // 保存用户信息到UserDefaults
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601

            if let userData = try? encoder.encode(responseData.user) {
                self.userDefaults.set(userData, forKey: self.userKey)
            } else {
                print("[AuthManager] 无法编码用户数据")
            }

            self.isAuthenticated = true
            self.isLoading = false

            return
        } catch let apiError as APIError {
            self.isLoading = false
            self.error = self.handleError(apiError)
            throw apiError
        } catch {
            self.isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }

    func logout() {
        accessToken = nil
        refreshToken = nil
        currentUser = nil
        userDefaults.removeObject(forKey: userKey)
        isAuthenticated = false
    }

    // 发送验证码请求模型
    struct SendVerificationCodeRequest: Codable {
        let email: String?
        let phoneNumber: String?
    }

    // 发送验证码响应数据模型
    struct SendVerificationCodeResponseData: Codable {
        let codeExpireTime: Date

        // 自定义解码初始化器
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // 手动解析日期字符串
            let codeExpireTimeString = try container.decode(String.self, forKey: .codeExpireTime)

            // 创建ISO8601格式解析器（带毫秒）
            let iso8601WithMilliseconds = ISO8601DateFormatter()
            iso8601WithMilliseconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            // 创建支持7位小数的日期格式解析器
            let extendedDateFormatter = DateFormatter()
            extendedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
            extendedDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            extendedDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            // 解析codeExpireTime
            var expireTimeDate: Date? = nil

            // 首先尝试使用带毫秒的ISO8601格式解析
            expireTimeDate = iso8601WithMilliseconds.date(from: codeExpireTimeString)

            // 然后尝试使用支持7位小数的日期格式解析器
            if expireTimeDate == nil {
                expireTimeDate = extendedDateFormatter.date(from: codeExpireTimeString)
            }

            // 如果还是解析失败，尝试手动处理
            if expireTimeDate == nil && codeExpireTimeString.contains(".") && codeExpireTimeString.hasSuffix("Z") {
                // 提取基本部分和小数部分
                let components = codeExpireTimeString.components(separatedBy: ".")
                if components.count == 2 {
                    let basePart = components[0]
                    var fractionalPart = components[1]

                    // 移除Z后缀
                    if fractionalPart.hasSuffix("Z") {
                        fractionalPart = String(fractionalPart.dropLast())
                    }

                    // 限制小数部分为3位（毫秒）
                    let milliseconds = fractionalPart.prefix(3)

                    // 重新组合日期字符串
                    let reformattedDateString = "\(basePart).\(milliseconds)Z"

                    // 尝试使用ISO8601解析重新格式化的字符串
                    expireTimeDate = iso8601WithMilliseconds.date(from: reformattedDateString)
                }
            }

            guard let expireTime = expireTimeDate else {
                print("[SendVerificationCodeResponseData] 无法解析codeExpireTime日期: \(codeExpireTimeString)")
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath + [CodingKeys.codeExpireTime],
                        debugDescription: "无法解析codeExpireTime日期: \(codeExpireTimeString)"
                    )
                )
            }
            codeExpireTime = expireTime
        }
    }

    // 发送验证码响应模型
    struct SendVerificationCodeResponse: Codable {
        let success: Bool
        let message: String?
        let data: SendVerificationCodeResponseData?
    }

    func sendVerificationCode(email: String?, phoneNumber: String?) async throws -> SendVerificationCodeResponse {
        isLoading = true
        error = nil

        do {
            let request = SendVerificationCodeRequest(email: email, phoneNumber: phoneNumber)

            let response: SendVerificationCodeResponse = try await APIService.shared.request(
                endpoint: "users/forgot-password/send-code",
                method: "POST",
                body: request
            )

            // 检查响应是否成功
            if !response.success {
                throw APIError.businessError(message: response.message ?? "发送验证码失败", code: nil)
            }

            self.isLoading = false

            return response
        } catch let apiError as APIError {
            self.isLoading = false
            self.error = self.handleError(apiError)
            throw apiError
        } catch {
            self.isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }

    // 验证码验证请求模型
    struct VerifyCodeRequest: Codable {
        let email: String?
        let phoneNumber: String?
        let code: String
    }

    // 验证码验证响应数据模型
    struct VerifyCodeResponseData: Codable {
        let resetToken: String? // 重置密码令牌

        // 修改CodingKeys以匹配后端新的、符合API文档的响应 (小写驼峰)
        enum CodingKeys: String, CodingKey {
            case resetToken // 直接使用属性名，解码器会根据PropertyNamingStrategy处理 (如果APIService有配置)
                           // 或者明确指定 case resetToken = "resetToken"
        }

        // 自定义解码初始化器，添加详细日志
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // 移除对 success 和 message 的解码
            // success = try container.decode(Bool.self, forKey: .success)
            // print("[VerifyCodeResponseData] 成功解码success字段: \(success)")

            // message = try container.decodeIfPresent(String.self, forKey: .message)
            // print("[VerifyCodeResponseData] 成功解码message字段: \(message ?? "nil")")

            // 解码resetToken字段
            resetToken = try container.decodeIfPresent(String.self, forKey: .resetToken)
            print("[VerifyCodeResponseData] 成功解码resetToken字段: \(resetToken ?? "nil")")

            // 移除相关警告，因为不再有内部的 success 标志
            // if success && resetToken == nil {
            //     print("[VerifyCodeResponseData] 警告：success为true但resetToken为nil")
            // }
        }
    }

    // 验证码验证响应模型
    struct VerifyCodeResponse: Codable {
        let success: Bool
        let message: String?
        let data: VerifyCodeResponseData?

        // 添加CodingKeys枚举，确保字段名与后端完全匹配
        enum CodingKeys: String, CodingKey {
            case success = "success"
            case message = "message"
            case data = "data"
        }

        // 添加自定义解码初始化器，打印详细日志
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // 解码success字段
            success = try container.decode(Bool.self, forKey: .success)
            print("[VerifyCodeResponse] 成功解码success字段: \(success)")

            // 解码message字段
            message = try container.decodeIfPresent(String.self, forKey: .message)
            print("[VerifyCodeResponse] 成功解码message字段: \(message ?? "nil")")

            // 解码data字段
            do {
                data = try container.decodeIfPresent(VerifyCodeResponseData.self, forKey: .data)
                print("[VerifyCodeResponse] 成功解码data字段: \(data != nil ? "非空" : "nil")")

                // 如果data为nil，打印警告
                if data == nil {
                    print("[VerifyCodeResponse] 警告：data字段为nil")
                }
            } catch {
                print("[VerifyCodeResponse] 解码data字段失败: \(error)")
                data = nil
            }
        }
    }

    func verifyCode(email: String?, phoneNumber: String?, code: String) async throws -> String {
        isLoading = true
        error = nil

        do {
            let request = VerifyCodeRequest(email: email, phoneNumber: phoneNumber, code: code)

            // response 的类型是 VerifyCodeResponse, APIService.shared.request 会解码整个JSON到这个结构
            let response: VerifyCodeResponse = try await APIService.shared.request(
                endpoint: "users/forgot-password/verify-code",
                method: "POST",
                body: request
            )

            // 1. 检查外层API的 success 标志 (通常表示HTTP请求和基础处理是否成功)
            // APIService 内部的 request 方法应该已经处理了网络错误和非2xx状态码。
            // 此处的 response.success 是后端在统一响应格式中定义的。
            if !response.success {
                // 外层调用就失败了，直接抛出错误
                throw APIError.businessError(message: response.message ?? "验证码验证服务请求失败", code: nil)
            }

            // 2. 检查内层 data 是否成功解码
            // response.data 对应的是JSON中外层 "data": { ... } 部分
            guard let innerData = response.data else {
                // 如果 innerData 为 nil，意味着JSON中外层的 "data" 字段缺失，
                // 或者其内容无法解码为 VerifyCodeResponseData 结构。
                throw APIError.businessError(message: "验证码响应数据不完整或格式错误", code: nil)
            }

            // 3. 移除对 innerData.success 的检查，因为该字段已从 VerifyCodeResponseData 移除。
            // 外层的 response.success 已确认请求成功。
            // if !innerData.success {
            //     throw APIError.businessError(message: innerData.message ?? "验证码验证失败", code: nil)
            // }

            // 4. 现在直接检查 resetToken 是否存在于 innerData (VerifyCodeResponseData)
            guard let token = innerData.resetToken else {
                // 如果 resetToken 为 nil，说明后端未按预期返回令牌。
                // 使用外层 response.message 作为错误信息，如果它存在的话。
                throw APIError.businessError(message: response.message ?? "验证码验证成功但未返回有效的重置令牌", code: nil)
            }

            self.isLoading = false
            return token
        } catch let apiError as APIError {
            self.isLoading = false
            self.error = self.handleError(apiError)
            throw apiError
        } catch {
            self.isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }

    // 重置密码请求模型
    struct ResetPasswordRequest: Codable {
        let resetToken: String
        let newPassword: String
    }

    // 重置密码响应模型
    struct ResetPasswordResponse: Codable {
        let success: Bool
        let message: String?
        let data: String? // 可能为空，或者包含一些额外信息
    }

    func resetPassword(resetToken: String, newPassword: String) async throws {
        isLoading = true
        error = nil

        do {
            let request = ResetPasswordRequest(resetToken: resetToken, newPassword: newPassword)

            let response: ResetPasswordResponse = try await APIService.shared.request(
                endpoint: "users/forgot-password/reset-password",
                method: "POST",
                body: request
            )

            // 检查响应是否成功
            if !response.success {
                throw APIError.businessError(message: response.message ?? "重置密码失败", code: nil)
            }

            self.isLoading = false
        } catch let apiError as APIError {
            self.isLoading = false
            self.error = self.handleError(apiError)
            throw apiError
        } catch {
            self.isLoading = false
            self.error = error.localizedDescription
            throw error
        }
    }

    func handleError(_ error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "无效的请求地址"
        case .invalidResponse:
            return "服务器响应无效"
        case .invalidData:
            return "数据格式错误"
        case .requestFailed(let err):
            return "网络请求失败: \(err.localizedDescription)"
        case .serverError(let statusCode):
            return "服务器错误 (状态码: \(statusCode))"
        case .decodingError(let err):
            print("[AuthManager] Decoding Error: \(err)")
            return "数据解析失败"
        case .encodingError(_):
            return "请求数据编码失败"
        case .unauthorized:
            return "认证失败，请重新登录"
        case .notFound:
            return "请求的资源未找到"
        case .badRequest(let message):
            // 直接返回后端的错误消息，不添加前缀
            print("[AuthManager] Bad Request Error: \(message)")
            return message
        case .businessError(let message, let code):
            // 直接返回业务错误消息，不添加前缀或代码
            print("[AuthManager] Business Error: \(message), Code: \(code ?? "N/A")")
            return message
        case .unknown:
            return "发生未知错误"
        }
    }

    func saveCurrentUserToUserDefaults() {
        guard let user = self.currentUser else {
            userDefaults.removeObject(forKey: userKey)
            return
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let userData = try? encoder.encode(user) {
            userDefaults.set(userData, forKey: userKey)
        } else {
            print("[AuthManager] 无法编码用户数据以保存到UserDefaults")
        }
    }
}