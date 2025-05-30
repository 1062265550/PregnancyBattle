import Foundation

// 医疗风险模型
public struct MedicalRisk: Codable, Identifiable {
    public var id: UUID { UUID() } // 本地ID，不从服务器获取
    public let type: String // 风险类型
    public let description: String // 风险描述
    public let severity: String // 严重程度（低/中/高）
}

// 健康建议模型
public struct Recommendation: Codable, Identifiable {
    public var id: UUID { UUID() } // 本地ID，不从服务器获取
    public let category: String // 建议类别
    public let description: String // 建议描述
}

// AI健康风险分析模型
public struct HealthRiskAnalysis: Codable {
    public let overallAssessment: String // 整体评估
    public let detailedAnalyses: [DetailedAnalysis] // 详细分析
    public let comprehensiveRecommendation: String // 综合建议
    public let riskScore: Int // 风险评分 (1-10)
    public let riskLevel: String // 风险等级 (低/中/高)
}

// 详细分析模型
public struct DetailedAnalysis: Codable, Identifiable {
    public var id: UUID { UUID() }
    public let category: String // 分析类别
    public let dataValue: String // 数据值
    public let analysis: String // 详细分析
    public let impact: String // 对孕期的影响
    public let recommendation: String // 针对性建议
    public let severity: String // 严重程度
}

// 个性化建议模型
public struct PersonalizedRecommendations: Codable {
    public let categoryRecommendations: [CategoryRecommendation] // 分类建议
    public let dietPlan: String // 饮食计划
    public let exercisePlan: String // 运动计划
    public let lifestyleAdjustments: String // 生活方式调整
    public let monitoringAdvice: String // 监测建议
    public let warningSignsToWatch: [String] // 需要关注的警告信号
}

// 分类建议模型
public struct CategoryRecommendation: Codable, Identifiable {
    public var id: UUID { UUID() }
    public let category: String // 建议类别
    public let title: String // 建议标题
    public let description: String // 详细描述
    public let priority: String // 优先级
    public let actionItems: [String] // 具体行动项
}

// 风险评估模型
public struct RiskAssessment: Codable {
    public let bmiCategory: String // BMI分类（偏瘦/正常/超重/肥胖）
    public let bmiRisk: String // BMI风险评估
    public let ageRisk: String // 年龄风险评估
    public let medicalRisks: [MedicalRisk] // 医疗风险列表
    public let recommendations: [Recommendation] // 建议列表

    // AI增强分析结果
    public let aiAnalysis: HealthRiskAnalysis? // AI分析结果
    public let personalizedRecommendations: PersonalizedRecommendations? // 个性化建议
    public let isAiEnhanced: Bool // 是否使用了AI增强
}

// 风险评估响应包装模型
public struct RiskAssessmentResponse: Codable {
    public let success: Bool
    public let message: String?
    public let data: RiskAssessment?
}
