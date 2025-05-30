import Foundation

// 创建体重记录请求模型
public struct CreateWeightRecordRequest: Codable {
    public let weight: Double // 体重（千克）
    public let recordDate: Date? // 记录日期，选填
    public let note: String? // 备注，选填

    public init(weight: Double, recordDate: Date? = nil, note: String? = nil) {
        self.weight = weight
        self.recordDate = recordDate
        self.note = note
    }
}

// 体重记录响应模型
public struct WeightRecordResponse: Codable, Identifiable {
    public let id: UUID // 体重记录ID
    public let userId: UUID // 用户ID
    public let weight: Double // 体重（千克）
    public let recordDate: Date // 记录日期
    public let pregnancyWeek: Int? // 孕周
    public let pregnancyDay: Int? // 孕天
    public let note: String? // 备注
    public let createdAt: Date // 创建时间
    public let updatedAt: Date // 更新时间
}

// 体重记录模型（用于趋势图表）
public struct WeightRecord: Codable, Identifiable {
    public var id: UUID { UUID() } // 本地ID，不从服务器获取
    public let date: Date // 记录日期
    public let weight: Double // 体重（千克）
    public let pregnancyWeek: Int // 孕周
    public let pregnancyDay: Int // 孕天
}

// 推荐体重增长范围模型
public struct RecommendedWeightGain: Codable {
    public let min: Double // 推荐最小增重
    public let max: Double // 推荐最大增重
}

// 体重趋势模型
public struct WeightTrend: Codable {
    public let weightRecords: [WeightRecord] // 体重记录列表
    public let startWeight: Double // 起始体重
    public let currentWeight: Double // 当前体重
    public let weightGain: Double // 增重
    public let recommendedWeightGain: RecommendedWeightGain // 推荐增重范围
}

// 体重趋势响应包装模型
public struct WeightTrendResponse: Codable {
    public let success: Bool
    public let message: String?
    public let data: WeightTrend?
}
