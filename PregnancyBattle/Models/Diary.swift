import Foundation

// MARK: - 日记相关数据模型

/// 情绪状态枚举
public enum MoodType: String, CaseIterable, Codable {
    case happy = "Happy"
    case sad = "Sad"
    case angry = "Angry"
    case anxious = "Anxious"
    case excited = "Excited"
    case tired = "Tired"
    case neutral = "Neutral"

    /// 情绪显示名称
    public var displayName: String {
        switch self {
        case .happy: return "开心"
        case .sad: return "难过"
        case .angry: return "生气"
        case .anxious: return "焦虑"
        case .excited: return "兴奋"
        case .tired: return "疲惫"
        case .neutral: return "平静"
        }
    }

    /// 情绪对应的emoji
    public var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .anxious: return "😰"
        case .excited: return "🤗"
        case .tired: return "😴"
        case .neutral: return "😐"
        }
    }
}

/// 媒体类型枚举
public enum MediaType: String, CaseIterable, Codable {
    case image = "Image"
    case video = "Video"
    case audio = "Audio"

    public var displayName: String {
        switch self {
        case .image: return "图片"
        case .video: return "视频"
        case .audio: return "音频"
        }
    }
}

// MARK: - 日记媒体文件模型

/// 日记媒体文件模型
public struct DiaryMedia: Codable, Identifiable {
    public let id: UUID
    public let mediaType: MediaType
    public let mediaUrl: String
    public let description: String?
    public let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case mediaType
        case mediaUrl
        case description
        case createdAt
    }
}

/// 创建日记媒体文件请求模型
public struct CreateDiaryMediaRequest: Codable {
    public let mediaType: MediaType
    public let mediaUrl: String
    public let description: String?

    public init(mediaType: MediaType, mediaUrl: String, description: String? = nil) {
        self.mediaType = mediaType
        self.mediaUrl = mediaUrl
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case mediaType
        case mediaUrl
        case description
    }
}

// MARK: - 文件上传结果模型

/// 文件上传结果模型
public struct FileUploadResult: Codable {
    public let fileName: String
    public let fileUrl: String
    public let fileSize: Int64
    public let contentType: String

    public init(fileName: String, fileUrl: String, fileSize: Int64, contentType: String) {
        self.fileName = fileName
        self.fileUrl = fileUrl
        self.fileSize = fileSize
        self.contentType = contentType
    }

    enum CodingKeys: String, CodingKey {
        case fileName
        case fileUrl
        case fileSize
        case contentType
    }
}

// MARK: - 日记主模型

/// 日记模型
public struct Diary: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let title: String
    public let content: String
    public let mood: MoodType?
    public let diaryDate: Date
    public let pregnancyWeek: Int?
    public let pregnancyDay: Int?
    public let createdAt: Date
    public let updatedAt: Date
    public let tags: [String]
    public let mediaFiles: [DiaryMedia]

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case content
        case mood
        case diaryDate
        case pregnancyWeek
        case pregnancyDay
        case createdAt
        case updatedAt
        case tags
        case mediaFiles
    }
}

// MARK: - 请求模型

/// 创建日记请求模型
public struct CreateDiaryRequest: Codable {
    public let title: String
    public let content: String
    public let mood: MoodType?
    public let diaryDate: Date
    public let tags: [String]
    public let mediaFiles: [CreateDiaryMediaRequest]

    public init(title: String, content: String, mood: MoodType? = nil, diaryDate: Date, tags: [String] = [], mediaFiles: [CreateDiaryMediaRequest] = []) {
        self.title = title
        self.content = content
        self.mood = mood
        self.diaryDate = diaryDate
        self.tags = tags
        self.mediaFiles = mediaFiles
    }

    enum CodingKeys: String, CodingKey {
        case title
        case content
        case mood
        case diaryDate
        case tags
        case mediaFiles
    }
}

/// 更新日记请求模型
public struct UpdateDiaryRequest: Codable {
    public let title: String?
    public let content: String?
    public let mood: MoodType?
    public let diaryDate: Date?
    public let tags: [String]?

    public init(title: String? = nil, content: String? = nil, mood: MoodType? = nil, diaryDate: Date? = nil, tags: [String]? = nil) {
        self.title = title
        self.content = content
        self.mood = mood
        self.diaryDate = diaryDate
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case title
        case content
        case mood
        case diaryDate
        case tags
    }
}

// MARK: - 分页响应模型

/// 分页日记列表模型
public struct PagedDiaryList: Codable {
    public let items: [Diary]
    public let totalCount: Int
    public let pageCount: Int
    public let currentPage: Int
    public let pageSize: Int

    enum CodingKeys: String, CodingKey {
        case items
        case totalCount
        case pageCount
        case currentPage
        case pageSize
    }
}

// MARK: - 添加标签请求模型

/// 添加日记标签请求模型
public struct AddDiaryTagsRequest: Codable {
    public let tags: [String]

    public init(tags: [String]) {
        self.tags = tags
    }
}

/// 日记标签响应模型（统一命名）
public struct DiaryTagsResponse: Codable {
    public let id: UUID
    public let tags: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case tags
    }
}

/// 添加日记标签响应模型（类型别名，保持向后兼容）
public typealias AddDiaryTagsResponse = DiaryTagsResponse

// MARK: - 媒体文件管理模型

/// 添加日记媒体文件请求模型
public struct AddDiaryMediaRequest: Codable {
    public let mediaType: MediaType
    public let mediaUrl: String
    public let description: String?

    public init(mediaType: MediaType, mediaUrl: String, description: String? = nil) {
        self.mediaType = mediaType
        self.mediaUrl = mediaUrl
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case mediaType
        case mediaUrl
        case description
    }
}

// MARK: - 通用响应模型

/// 空响应模型（用于删除操作等只返回成功状态的API）
public struct EmptyResponse: Codable {
    // 空结构体，用于处理只返回成功状态的API响应
}
