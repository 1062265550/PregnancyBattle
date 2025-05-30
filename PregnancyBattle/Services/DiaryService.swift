import Foundation

/// 日记服务类
/// 负责处理所有与日记相关的API请求
class DiaryService {
    static let shared = DiaryService()

    private init() {}

    // MARK: - 日记CRUD操作

    /// 创建日记
    /// - Parameter request: 创建日记请求模型
    /// - Returns: 创建的日记对象
    func createDiary(request: CreateDiaryRequest) async throws -> Diary {
        return try await APIService.shared.request(
            endpoint: "diaries",
            method: "POST",
            body: request
        )
    }

    /// 获取指定ID的日记
    /// - Parameter diaryId: 日记ID
    /// - Returns: 日记对象
    func getDiary(diaryId: UUID) async throws -> Diary {
        return try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)",
            method: "GET"
        )
    }

    /// 获取用户所有日记（分页）
    /// - Parameters:
    ///   - page: 页码，默认为1
    ///   - pageSize: 每页数量，默认为10
    ///   - sortBy: 排序字段，可选值：diaryDate、createdAt，默认为diaryDate
    ///   - sortDirection: 排序方向，可选值：asc、desc，默认为desc
    /// - Returns: 分页日记列表
    func getUserDiaries(
        page: Int = 1,
        pageSize: Int = 10,
        sortBy: String = "diaryDate",
        sortDirection: String = "desc"
    ) async throws -> PagedDiaryList {
        let queryParams = [
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "sortBy": sortBy,
            "sortDirection": sortDirection
        ]

        let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = "diaries?\(queryString)"

        return try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET"
        )
    }

    /// 根据日期范围获取日记
    /// - Parameters:
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    ///   - page: 页码，默认为1
    ///   - pageSize: 每页数量，默认为10
    ///   - sortBy: 排序字段，默认为diaryDate
    ///   - sortDirection: 排序方向，默认为desc
    /// - Returns: 分页日记列表
    func getDiariesByDateRange(
        startDate: Date,
        endDate: Date,
        page: Int = 1,
        pageSize: Int = 10,
        sortBy: String = "diaryDate",
        sortDirection: String = "desc"
    ) async throws -> PagedDiaryList {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let queryParams = [
            "startDate": dateFormatter.string(from: startDate),
            "endDate": dateFormatter.string(from: endDate),
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "sortBy": sortBy,
            "sortDirection": sortDirection
        ]

        let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = "diaries/date-range?\(queryString)"

        return try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET"
        )
    }

    /// 根据标签获取日记
    /// - Parameters:
    ///   - tag: 标签名称
    ///   - page: 页码，默认为1
    ///   - pageSize: 每页数量，默认为10
    ///   - sortBy: 排序字段，默认为diaryDate
    ///   - sortDirection: 排序方向，默认为desc
    /// - Returns: 分页日记列表
    func getDiariesByTag(
        tag: String,
        page: Int = 1,
        pageSize: Int = 10,
        sortBy: String = "diaryDate",
        sortDirection: String = "desc"
    ) async throws -> PagedDiaryList {
        let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tag

        let queryParams = [
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "sortBy": sortBy,
            "sortDirection": sortDirection
        ]

        let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = "diaries/tag/\(encodedTag)?\(queryString)"

        return try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET"
        )
    }

    /// 根据情绪获取日记
    /// - Parameters:
    ///   - mood: 情绪状态
    ///   - page: 页码，默认为1
    ///   - pageSize: 每页数量，默认为10
    ///   - sortBy: 排序字段，默认为diaryDate
    ///   - sortDirection: 排序方向，默认为desc
    /// - Returns: 分页日记列表
    func getDiariesByMood(
        mood: MoodType,
        page: Int = 1,
        pageSize: Int = 10,
        sortBy: String = "diaryDate",
        sortDirection: String = "desc"
    ) async throws -> PagedDiaryList {
        let queryParams = [
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "sortBy": sortBy,
            "sortDirection": sortDirection
        ]

        let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = "diaries/mood/\(mood.rawValue)?\(queryString)"

        return try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET"
        )
    }

    /// 根据多个条件获取日记
    /// - Parameters:
    ///   - mood: 情绪状态（可选）
    ///   - tags: 标签名称列表（可选）
    ///   - startDate: 开始日期（可选）
    ///   - endDate: 结束日期（可选）
    ///   - page: 页码，默认为1
    ///   - pageSize: 每页数量，默认为10
    ///   - sortBy: 排序字段，默认为diaryDate
    ///   - sortDirection: 排序方向，默认为desc
    /// - Returns: 分页日记列表
    func getDiariesByMultipleFilters(
        mood: MoodType? = nil,
        tags: [String]? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        page: Int = 1,
        pageSize: Int = 10,
        sortBy: String = "diaryDate",
        sortDirection: String = "desc"
    ) async throws -> PagedDiaryList {
        var queryParams = [
            "page": "\(page)",
            "pageSize": "\(pageSize)",
            "sortBy": sortBy,
            "sortDirection": sortDirection
        ]

        // 添加可选的筛选条件
        if let mood = mood {
            queryParams["mood"] = mood.rawValue
        }

        if let tags = tags, !tags.isEmpty {
            queryParams["tags"] = tags.joined(separator: ",")
        }

        if let startDate = startDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryParams["startDate"] = dateFormatter.string(from: startDate)
        }

        if let endDate = endDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            queryParams["endDate"] = dateFormatter.string(from: endDate)
        }

        let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let endpoint = "diaries/filter?\(queryString)"

        return try await APIService.shared.request(
            endpoint: endpoint,
            method: "GET"
        )
    }

    // MARK: - 日记编辑操作

    /// 更新日记
    /// - Parameters:
    ///   - diaryId: 日记ID
    ///   - request: 更新日记请求模型
    /// - Returns: 更新后的日记对象
    func updateDiary(diaryId: UUID, request: UpdateDiaryRequest) async throws -> Diary {
        return try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)",
            method: "PUT",
            body: request
        )
    }

    /// 删除日记
    /// - Parameter diaryId: 日记ID
    func deleteDiary(diaryId: UUID) async throws {
        let _: ApiResponseEmpty = try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)",
            method: "DELETE"
        )
    }

    // MARK: - 标签管理

    /// 添加日记标签
    /// - Parameters:
    ///   - diaryId: 日记ID
    ///   - tags: 要添加的标签列表
    /// - Returns: 更新后的标签信息
    func addDiaryTags(diaryId: UUID, tags: [String]) async throws -> DiaryTagsResponse {
        let request = AddDiaryTagsRequest(tags: tags)
        return try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)/tags",
            method: "POST",
            body: request
        )
    }

    /// 删除日记标签
    /// - Parameters:
    ///   - diaryId: 日记ID
    ///   - tag: 要删除的标签名称
    /// - Returns: 更新后的标签信息
    func deleteDiaryTag(diaryId: UUID, tag: String) async throws -> DiaryTagsResponse {
        // URL编码标签名称以处理特殊字符
        let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? tag
        return try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)/tags/\(encodedTag)",
            method: "DELETE"
        )
    }

    // MARK: - 媒体文件管理

    /// 添加日记媒体文件
    /// - Parameters:
    ///   - diaryId: 日记ID
    ///   - request: 媒体文件请求模型
    /// - Returns: 创建的媒体文件对象
    func addDiaryMedia(diaryId: UUID, request: AddDiaryMediaRequest) async throws -> DiaryMedia {
        return try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)/media",
            method: "POST",
            body: request
        )
    }

    /// 删除日记媒体文件
    /// - Parameters:
    ///   - diaryId: 日记ID
    ///   - mediaId: 媒体文件ID
    func deleteDiaryMedia(diaryId: UUID, mediaId: UUID) async throws {
        let _: ApiResponseEmpty = try await APIService.shared.request(
            endpoint: "diaries/\(diaryId.uuidString)/media/\(mediaId.uuidString)",
            method: "DELETE"
        )
    }

    /// 获取用户所有标签
    /// - Returns: 标签列表
    func getUserTags() async throws -> [String] {
        let response: ApiResponse<[String]> = try await APIService.shared.request(
            endpoint: "diaries/tags",
            method: "GET"
        )
        return response.data ?? []
    }

    // MARK: - Media File Management (Updated)

    /// 直接上传媒体文件到日记
    /// - Parameters:
    ///   - diaryId: 日记ID
    ///   - mediaFile: 媒体文件对象
    ///   - description: 文件描述
    /// - Returns: 创建的媒体文件对象
    func uploadDiaryMedia(diaryId: UUID, mediaFile: MediaFile, description: String? = nil) async throws -> DiaryMedia {
        // 首先上传文件到文件服务
        let uploadResult = try await FileUploadService.shared.uploadMediaFile(
            mediaFile: mediaFile,
            folder: "diary-media"
        )

        // 然后将文件URL添加到日记
        let mediaType: MediaType
        switch mediaFile.type {
        case .Image:
            mediaType = .image
        case .Video:
            mediaType = .video
        case .Audio:
            mediaType = .audio
        }

        let request = AddDiaryMediaRequest(
            mediaType: mediaType,
            mediaUrl: uploadResult.fileUrl,
            description: description
        )

        return try await addDiaryMedia(diaryId: diaryId, request: request)
    }

}

// MARK: - Request Models
struct AddMediaFileRequest: Codable {
    let fileId: String
    let description: String?
}


