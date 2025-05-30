import Foundation
import SwiftUI
import Network

/// API响应模型（泛型）
struct ApiResponse<T: Decodable>: Decodable {
    /// 是否成功
    let success: Bool

    /// 消息
    let message: String?

    /// 错误代码
    let code: String?

    /// 数据
    let data: T?
}

/// API响应模型（无数据）
struct ApiResponseEmpty: Decodable {
    /// 是否成功
    let success: Bool

    /// 消息
    let message: String?

    /// 错误代码
    let code: String?
}

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case requestFailed(Error)
    case serverError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case notFound
    case badRequest(String)
    case businessError(message: String, code: String?)
    case unknown
}

class APIService {
    static let shared = APIService()

    // 后端API地址
    // 注意：后端控制器已经包含了"api"前缀，所以baseURL不需要再加"/api"
    // 生产环境
    // private let baseURL = "https://api.pregnancybattle.com"
    // 开发环境 - 使用127.0.0.1而不是localhost以确保iOS模拟器能够连接
    private let baseURL = "http://127.0.0.1:5094"
    // Azure部署环境
    // private let baseURL = "https://pregnancybattle-api.azurewebsites.net"

    // 配置URLSession，添加超时设置
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60.0  // 请求超时60秒（增加AI处理时间）
        config.timeoutIntervalForResource = 120.0 // 资源超时120秒
        config.waitsForConnectivity = true       // 等待网络连接
        return URLSession(configuration: config)
    }()

    private let jsonDecoder = JSONDecoder()

    // 调试模式开关
    private let isDebugMode = true
    private let jsonEncoder = JSONEncoder()

    // 网络监控
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    private var isNetworkAvailable = true

    // 获取完整的API URL
    private func getFullURL(endpoint: String) -> String {
        // 检查endpoint是否已经包含了api前缀
        if endpoint.hasPrefix("api/") {
            return "\(baseURL)/\(endpoint)"
        } else {
            return "\(baseURL)/api/\(endpoint)"
        }
    }

    private init() {
        // 自定义日期解码策略，兼容后端返回的日期格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // 创建支持毫秒的ISO8601格式解析器
        let iso8601WithMilliseconds = ISO8601DateFormatter()
        iso8601WithMilliseconds.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        // 标准ISO8601格式解析器（不带毫秒）
        let iso8601Standard = ISO8601DateFormatter()

        // 创建支持7位小数的日期格式解析器
        let extendedDateFormatter = DateFormatter()
        extendedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        extendedDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        extendedDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // 首先尝试使用带毫秒的ISO8601格式解析（后端返回的格式）
            if let date = iso8601WithMilliseconds.date(from: dateString) {
                return date
            }

            // 尝试使用支持7位小数的日期格式解析器（后端返回的格式）
            if let date = extendedDateFormatter.date(from: dateString) {
                return date
            }

            // 然后尝试使用标准ISO8601格式解析（不带毫秒）
            if let date = iso8601Standard.date(from: dateString) {
                return date
            }

            // 尝试使用自定义格式解析
            if let date = dateFormatter.date(from: dateString) {
                return date
            }

            // 如果是空日期值，返回遥远的过去日期
            if dateString == "0001-01-01T00:00:00" {
                return Date(timeIntervalSince1970: 0)
            }

            // 尝试手动解析带有多位小数的日期格式
            if dateString.contains(".") && dateString.hasSuffix("Z") {
                // 提取基本部分和小数部分
                let components = dateString.components(separatedBy: ".")
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
                    if let date = iso8601WithMilliseconds.date(from: reformattedDateString) {
                        return date
                    }
                }
            }

            print("[APIService] 无法解析日期字符串: \(dateString)")

            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Date string does not match format expected by formatter."
                )
            )
        }

        jsonEncoder.dateEncodingStrategy = .iso8601

        // 配置枚举编码策略，确保枚举值正确序列化
        jsonEncoder.outputFormatting = .prettyPrinted

        // 添加User-Agent，方便后端识别请求来源 (可选)
        // URLSessionConfiguration.default.httpAdditionalHeaders = ["User-Agent": "PregnancyBattleApp/1.0"]

        // 启动网络监控
        startNetworkMonitoring()
    }

    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
                print("[APIService] Network status: \(path.status == .satisfied ? "Available" : "Unavailable")")
            }
        }
        networkMonitor.start(queue: networkQueue)
    }

    func request<T: Decodable>(endpoint: String, method: String = "GET", body: Encodable? = nil, headers: [String: String]? = nil) async throws -> T {
        // 检查网络连接状态 - 暂时禁用此检查以解决iOS模拟器连接问题
        // if !isNetworkAvailable {
        //     print("[APIService] Error: No network connection available")
        //     throw APIError.requestFailed(URLError(.notConnectedToInternet))
        // }

        let isLoginOrRegister = endpoint == "users/login" || endpoint == "users/register"
        let fullURLString = getFullURL(endpoint: endpoint)
        print("[APIService] Requesting: \(method) \(fullURLString)")

        guard let url = URL(string: fullURLString) else {
            print("[APIService] Error: Invalid URL - \(fullURLString)")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        // 设置请求超时，对于可能需要AI处理的接口增加超时时间
        if endpoint.contains("risk-assessment") {
            request.timeoutInterval = 90.0  // AI风险评估需要更长时间
        } else {
            request.timeoutInterval = 60.0  // 其他接口60秒
        }

        // 设置默认请求头
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("[APIService] Headers: Content-Type: application/json")

        // 添加自定义请求头
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
                print("[APIService] Headers: \(key): \(value)")
            }
        }

        // 添加认证令牌
        if !isLoginOrRegister {
            let (token, isTokenValid) = await MainActor.run {
                let authManager = AuthManager.shared
                return (authManager.accessToken, authManager.isTokenValid())
            }

            if let token = token {
                // 检查Token是否有效
                if !isTokenValid {
                    print("[APIService] Token已过期，清除认证状态")
                    await MainActor.run {
                        AuthManager.shared.logout()
                    }
                    throw APIError.unauthorized
                }

                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("[APIService] Headers: Authorization: Bearer [TOKEN_PRESENT]") // 不打印完整token
            } else {
                print("[APIService] Warning: No access token available for authenticated request")
                // 对于需要认证的请求，如果没有token，直接抛出未授权错误
                throw APIError.unauthorized
            }
        }

        // 编码请求体
        if let body = body {
            do {
                request.httpBody = try jsonEncoder.encode(body)
                if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                    print("[APIService] Request Body: \(bodyString)")
                } else {
                    print("[APIService] Request Body: (Encoded, not printable as UTF-8)")
                }
            } catch {
                print("[APIService] Error: Encoding request body failed - \(error.localizedDescription)")
                throw APIError.encodingError(error)
            }
        }

        do {
            print("[APIService] Sending request to \(url.absoluteString)")
            print("[APIService] Request method: \(request.httpMethod ?? "GET")")
            print("[APIService] Request headers: \(request.allHTTPHeaderFields ?? [:])")
            print("[APIService] Network monitor available: \(isNetworkAvailable)")
            
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[APIService] Error: Invalid response object")
                throw APIError.invalidResponse
            }

            print("[APIService] Response Status Code: \(httpResponse.statusCode)")
            if let responseDataString = String(data: data, encoding: .utf8) {
                 print("[APIService] Response Data: \(responseDataString)")
            } else {
                 print("[APIService] Response Data: (Not printable as UTF-8)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    // 尝试解析为ApiResponse<T>格式
                    do {
                        let apiResponse = try jsonDecoder.decode(ApiResponse<T>.self, from: data)
                        print("[APIService] 成功解码为ApiResponse<T>格式")

                        if apiResponse.success {
                            if let responseData = apiResponse.data {
                                print("[APIService] Success (ApiResponse.data): Decoded successfully.")
                                print("[APIService] 响应数据类型: \(type(of: responseData))")
                                return responseData
                            } else {
                                print("[APIService] Success (ApiResponse) but no data field, attempting to decode T directly from root.")
                                return try jsonDecoder.decode(T.self, from: data)
                            }
                        } else {
                            print("[APIService] Business Error (ApiResponse.success == false): \(apiResponse.message ?? "N/A"), Code: \(apiResponse.code ?? "N/A")")
                            throw APIError.businessError(message: apiResponse.message ?? "未知业务错误", code: apiResponse.code)
                        }
                    } catch {
                        print("[APIService] 解码为ApiResponse<T>格式失败: \(error)")
                        print("[APIService] 尝试直接解码为\(T.self)类型")

                        do {
                            let result = try jsonDecoder.decode(T.self, from: data)
                            print("[APIService] 直接解码成功，类型: \(T.self)")
                            return result
                        } catch {
                            print("[APIService] 直接解码失败: \(error)")
                            print("[APIService] 解码失败的类型: \(T.self)")
                            print("[APIService] 解码失败的数据: \(String(data: data, encoding: .utf8) ?? "Not UTF8")")

                            // 尝试使用JSONSerialization查看数据结构
                            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                               let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                               let prettyPrintedString = String(data: jsonData, encoding: .utf8) {
                                print("[APIService] JSON结构: \(prettyPrintedString)")
                            }

                            throw APIError.decodingError(error)
                        }
                    }
                } catch let apiError as APIError {
                    print("[APIService] Error during success handling (APIError): \(apiError)")
                    throw apiError
                } catch {
                    print("[APIService] Error: Decoding successful response failed - \(error.localizedDescription). Raw data: \(String(data: data, encoding: .utf8) ?? "Not UTF8")")

                    // 如果是DecodingError，打印更详细的信息
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("[APIService] 类型不匹配: 期望 \(type)，路径: \(context.codingPath)")
                        case .valueNotFound(let type, let context):
                            print("[APIService] 值未找到: 期望 \(type)，路径: \(context.codingPath)")
                        case .keyNotFound(let key, let context):
                            print("[APIService] 键未找到: \(key)，路径: \(context.codingPath)")
                        case .dataCorrupted(let context):
                            print("[APIService] 数据损坏: \(context.debugDescription)，路径: \(context.codingPath)")
                        @unknown default:
                            print("[APIService] 未知解码错误: \(decodingError)")
                        }
                    }

                    throw APIError.decodingError(error)
                }
            case 400:
                print("[APIService] Error (400 Bad Request)")

                // 打印原始响应数据，帮助调试
                let rawResponseString = String(data: data, encoding: .utf8) ?? "Not UTF8"
                print("[APIService] Raw response data: \(rawResponseString)")

                // 尝试解析为ApiResponse<T>格式
                do {
                    // 首先尝试解析为ApiResponse<T>格式
                    let apiResponse = try jsonDecoder.decode(ApiResponse<T>.self, from: data)
                    print("[APIService] Successfully parsed ApiResponse<T>: \(apiResponse.message ?? "N/A"), Code: \(apiResponse.code ?? "N/A"), Success: \(apiResponse.success)")

                    if !apiResponse.success {
                        // 直接使用后端返回的错误消息
                        let message = apiResponse.message ?? "请求参数无效"
                        print("[APIService] Using backend error message from ApiResponse<T>: \(message)")
                        throw APIError.businessError(message: message, code: apiResponse.code)
                    } else if let responseData = apiResponse.data {
                        // 如果成功且有数据，返回数据
                        print("[APIService] Success in 400 response (unusual): \(apiResponse.message ?? "N/A")")
                        return responseData
                    } else {
                        // 成功但无数据，尝试直接解码
                        print("[APIService] Success in 400 response but no data, attempting direct decode")
                        return try jsonDecoder.decode(T.self, from: data)
                    }
                } catch {
                    print("[APIService] Failed to parse as ApiResponse<T>: \(error.localizedDescription)")

                    // 尝试解析为ApiResponseEmpty格式
                    do {
                        let apiResponse = try jsonDecoder.decode(ApiResponseEmpty.self, from: data)
                        print("[APIService] Successfully parsed ApiResponseEmpty: \(apiResponse.message ?? "N/A"), Code: \(apiResponse.code ?? "N/A"), Success: \(apiResponse.success)")

                        if !apiResponse.success {
                            // 直接使用后端返回的错误消息
                            let message = apiResponse.message ?? "请求参数无效"
                            print("[APIService] Using backend error message from ApiResponseEmpty: \(message)")
                            throw APIError.businessError(message: message, code: apiResponse.code)
                        } else {
                            print("[APIService] Success in ApiResponseEmpty (unusual)")
                            throw APIError.badRequest("请求成功但返回格式异常")
                        }
                    } catch {
                        print("[APIService] Failed to parse as ApiResponseEmpty: \(error.localizedDescription)")

                        // 尝试解析为自定义格式
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let success = jsonObject["Success"] as? Bool,
                           let message = jsonObject["Message"] as? String {
                            print("[APIService] Parsed using JSONSerialization: Success=\(success), Message=\(message)")

                            if !success {
                                throw APIError.businessError(message: message, code: jsonObject["Code"] as? String)
                            } else {
                                // 如果成功，尝试解析data字段
                                print("[APIService] Success in JSONSerialization (unusual)")
                                if let dataDict = jsonObject["Data"] as? [String: Any] {
                                    // 将字典转换回JSON数据
                                    let jsonData = try JSONSerialization.data(withJSONObject: dataDict)
                                    // 解析为T类型
                                    return try jsonDecoder.decode(T.self, from: jsonData)
                                } else {
                                    // 没有data字段，尝试直接解码
                                    return try jsonDecoder.decode(T.self, from: data)
                                }
                            }
                        } else {
                            // 最后尝试解析为旧格式
                            if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                               let errorMessage = errorResponse["message"] {
                                print("[APIService] Error (400) - Parsed legacy error: \(errorMessage)")
                                throw APIError.badRequest(errorMessage)
                            } else {
                                // 使用通用的错误消息
                                print("[APIService] Error (400) - Failed to parse response in any format")
                                throw APIError.badRequest("请求参数无效")
                            }
                        }
                    }
                }
            case 401:
                print("[APIService] Error (401 Unauthorized)")

                // 如果不是登录或注册请求，尝试刷新Token
                if !isLoginOrRegister {
                    print("[APIService] 尝试刷新Token...")

                    // 清除当前无效的Token
                    await MainActor.run {
                        AuthManager.shared.logout()
                    }

                    print("[APIService] Token已清除，用户需要重新登录")
                }

                throw APIError.unauthorized
            case 404:
                print("[APIService] Error (404 Not Found) for URL: \(fullURLString)")

                // 尝试解析后端返回的错误消息
                do {
                    // 尝试解析为ApiResponse<T>格式
                    if let apiResponse = try? jsonDecoder.decode(ApiResponse<T>.self, from: data) {
                        print("[APIService] Successfully parsed 404 response as ApiResponse<T>: \(apiResponse.message ?? "N/A")")
                        throw APIError.notFound
                    }

                    // 尝试解析为ApiResponseEmpty格式
                    if let apiResponse = try? jsonDecoder.decode(ApiResponseEmpty.self, from: data) {
                        print("[APIService] Successfully parsed 404 response as ApiResponseEmpty: \(apiResponse.message ?? "N/A")")
                        throw APIError.notFound
                    }

                    // 尝试解析为简单消息格式
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let message = jsonObject["message"] as? String {
                        print("[APIService] Parsed 404 response using JSONSerialization: Message=\(message)")
                        throw APIError.notFound
                    }
                } catch let apiErr as APIError {
                    throw apiErr
                } catch {
                    print("[APIService] Failed to parse 404 response: \(error)")
                }

                // 如果无法解析，使用默认的notFound错误
                throw APIError.notFound
            default:
                print("[APIService] Error (Server Error): Status \(httpResponse.statusCode)")

                // 对于409冲突错误，尝试解析后端返回的错误消息
                if httpResponse.statusCode == 409 {
                    do {
                        // 尝试解析为ApiResponse<T>格式
                        if let apiResponse = try? jsonDecoder.decode(ApiResponse<T>.self, from: data) {
                            print("[APIService] Successfully parsed 409 response as ApiResponse<T>: \(apiResponse.message ?? "N/A")")
                            throw APIError.businessError(message: apiResponse.message ?? "资源冲突", code: apiResponse.code)
                        }

                        // 尝试解析为ApiResponseEmpty格式
                        if let apiResponse = try? jsonDecoder.decode(ApiResponseEmpty.self, from: data) {
                            print("[APIService] Successfully parsed 409 response as ApiResponseEmpty: \(apiResponse.message ?? "N/A")")
                            throw APIError.businessError(message: apiResponse.message ?? "资源冲突", code: apiResponse.code)
                        }
                    } catch let apiErr as APIError {
                        throw apiErr
                    } catch {
                        print("[APIService] Failed to parse 409 response: \(error)")
                    }
                }

                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let urlError as URLError {
            print("[APIService] Error: URLSession task failed - \(urlError.localizedDescription)")
            print("[APIService] URLError code: \(urlError.code.rawValue)")

            // 处理不同类型的URLError
            switch urlError.code {
            case .cancelled:
                print("[APIService] Request was cancelled")
                // 对于取消的请求，抛出特殊的取消错误
                throw CancellationError()
            case .timedOut:
                print("[APIService] Request timed out")
                throw APIError.requestFailed(urlError)
            case .notConnectedToInternet:
                print("[APIService] No internet connection")
                throw APIError.requestFailed(urlError)
            case .networkConnectionLost:
                print("[APIService] Network connection lost")
                throw APIError.requestFailed(urlError)
            default:
                print("[APIService] Other URLError: \(urlError.localizedDescription)")
                throw APIError.requestFailed(urlError)
            }
        } catch let apiErr as APIError {
             print("[APIService] Error: APIError caught - \(apiErr)")
             throw apiErr // Re-throw known API errors
        } catch {
            print("[APIService] Error: Unknown error during request - \(error.localizedDescription)")
            throw APIError.unknown // Or re-throw error directly
        }
    }

    // MARK: - 文件上传方法

    /// 上传单个文件
    /// - Parameters:
    ///   - endpoint: API端点
    ///   - fileData: 文件数据
    ///   - fileName: 文件名
    ///   - contentType: 文件类型
    ///   - folder: 存储文件夹
    /// - Returns: 文件上传结果
    func uploadFile<T: Decodable>(
        endpoint: String,
        fileData: Data,
        fileName: String,
        contentType: String,
        folder: String = "diary-media"
    ) async throws -> T {
        // 检查网络连接状态 - 暂时禁用此检查以解决iOS模拟器连接问题
        // if !isNetworkAvailable {
        //     print("[APIService] Error: No network connection available")
        //     throw APIError.requestFailed(URLError(.notConnectedToInternet))
        // }

        let fullURLString = getFullURL(endpoint: endpoint)
        print("[APIService] Uploading file to: \(fullURLString)")

        guard let url = URL(string: fullURLString) else {
            print("[APIService] Error: Invalid URL - \(fullURLString)")
            throw APIError.invalidURL
        }

        // 创建multipart/form-data请求
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120.0 // 文件上传需要更长时间

        // 生成boundary
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // 添加认证令牌
        let token = await MainActor.run {
            return AuthManager.shared.accessToken
        }
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("[APIService] Headers: Authorization: Bearer [TOKEN_PRESENT]")
        } else {
            print("[APIService] Warning: No access token available for file upload")
            throw APIError.unauthorized
        }

        // 构建multipart body
        var body = Data()

        // 添加文件数据
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // 添加folder参数
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"folder\"\r\n\r\n".data(using: .utf8)!)
        body.append(folder.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)

        // 结束boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("[APIService] Uploading file: \(fileName), size: \(fileData.count) bytes")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[APIService] Error: Invalid response object")
                throw APIError.invalidResponse
            }

            print("[APIService] Upload Response Status Code: \(httpResponse.statusCode)")
            if let responseDataString = String(data: data, encoding: .utf8) {
                print("[APIService] Upload Response Data: \(responseDataString)")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    // 尝试解析为ApiResponse<T>格式
                    let apiResponse = try jsonDecoder.decode(ApiResponse<T>.self, from: data)
                    print("[APIService] 文件上传成功解码为ApiResponse<T>格式")

                    if apiResponse.success {
                        if let responseData = apiResponse.data {
                            print("[APIService] File upload success: \(apiResponse.message ?? "N/A")")
                            return responseData
                        } else {
                            print("[APIService] File upload success but no data field")
                            return try jsonDecoder.decode(T.self, from: data)
                        }
                    } else {
                        print("[APIService] File upload business error: \(apiResponse.message ?? "N/A")")
                        throw APIError.businessError(message: apiResponse.message ?? "文件上传失败", code: apiResponse.code)
                    }
                } catch {
                    print("[APIService] 文件上传解码失败: \(error)")
                    throw APIError.decodingError(error)
                }
            case 400:
                print("[APIService] File upload error (400 Bad Request)")
                // 尝试解析错误消息
                if let errorData = try? jsonDecoder.decode(ApiResponseEmpty.self, from: data) {
                    throw APIError.businessError(message: errorData.message ?? "文件上传参数错误", code: errorData.code)
                } else {
                    throw APIError.badRequest("文件上传参数错误")
                }
            case 401:
                print("[APIService] File upload error (401 Unauthorized)")
                throw APIError.unauthorized
            case 413:
                print("[APIService] File upload error (413 Payload Too Large)")
                throw APIError.businessError(message: "文件大小超过限制", code: "FILE_TOO_LARGE")
            default:
                print("[APIService] File upload error: Status \(httpResponse.statusCode)")
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let urlError as URLError {
            print("[APIService] File upload URLError: \(urlError.localizedDescription)")
            throw APIError.requestFailed(urlError)
        } catch let apiErr as APIError {
            throw apiErr
        } catch {
            print("[APIService] File upload unknown error: \(error.localizedDescription)")
            throw APIError.unknown
        }
    }
}