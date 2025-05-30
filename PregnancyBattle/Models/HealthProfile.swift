import Foundation

// 血型枚举
public enum BloodType: String, Codable, CaseIterable {
    case a = "A"
    case b = "B"
    case ab = "AB"
    case o = "O"
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    case oPositive = "O+"
    case oNegative = "O-"

    public var displayName: String {
        return self.rawValue
    }
}

// 创建健康档案请求模型
public struct CreateHealthProfileRequest: Codable {
    public let height: Double // 身高（厘米），必填，100-250厘米
    public let prePregnancyWeight: Double // 孕前体重（千克），必填，30-200千克
    public let currentWeight: Double // 当前体重（千克），必填，30-200千克
    public let bloodType: String // 血型，必填
    public let age: Int // 年龄，必填，18-60岁
    public let medicalHistory: String? // 个人病史，选填
    public let familyHistory: String? // 家族病史，选填
    public let allergiesHistory: String? // 过敏史，选填
    public let obstetricHistory: String? // 既往孕产史，选填
    public let isSmoking: Bool? // 是否吸烟，选填，默认为false
    public let isDrinking: Bool? // 是否饮酒，选填，默认为false

    public init(
        height: Double,
        prePregnancyWeight: Double,
        currentWeight: Double,
        bloodType: String,
        age: Int,
        medicalHistory: String? = nil,
        familyHistory: String? = nil,
        allergiesHistory: String? = nil,
        obstetricHistory: String? = nil,
        isSmoking: Bool? = nil,
        isDrinking: Bool? = nil
    ) {
        self.height = height
        self.prePregnancyWeight = prePregnancyWeight
        self.currentWeight = currentWeight
        self.bloodType = bloodType
        self.age = age
        self.medicalHistory = medicalHistory
        self.familyHistory = familyHistory
        self.allergiesHistory = allergiesHistory
        self.obstetricHistory = obstetricHistory
        self.isSmoking = isSmoking
        self.isDrinking = isDrinking
    }
}

// 更新健康档案请求模型
public struct UpdateHealthProfileRequest: Codable {
    public let height: Double? // 身高（厘米），选填，100-250厘米
    public let prePregnancyWeight: Double? // 孕前体重（千克），选填，30-200千克
    public let currentWeight: Double? // 当前体重（千克），选填，30-200千克
    public let bloodType: String? // 血型，选填
    public let medicalHistory: String? // 个人病史，选填
    public let familyHistory: String? // 家族病史，选填
    public let allergiesHistory: String? // 过敏史，选填
    public let obstetricHistory: String? // 既往孕产史，选填
    public let isSmoking: Bool? // 是否吸烟，选填
    public let isDrinking: Bool? // 是否饮酒，选填

    public init(
        height: Double? = nil,
        prePregnancyWeight: Double? = nil,
        currentWeight: Double? = nil,
        bloodType: String? = nil,
        medicalHistory: String? = nil,
        familyHistory: String? = nil,
        allergiesHistory: String? = nil,
        obstetricHistory: String? = nil,
        isSmoking: Bool? = nil,
        isDrinking: Bool? = nil
    ) {
        self.height = height
        self.prePregnancyWeight = prePregnancyWeight
        self.currentWeight = currentWeight
        self.bloodType = bloodType
        self.medicalHistory = medicalHistory
        self.familyHistory = familyHistory
        self.allergiesHistory = allergiesHistory
        self.obstetricHistory = obstetricHistory
        self.isSmoking = isSmoking
        self.isDrinking = isDrinking
    }
}

// 健康档案响应模型
public struct HealthProfile: Codable, Identifiable {
    public let id: UUID
    public let userId: UUID
    public let height: Double // 身高（厘米）
    public let prePregnancyWeight: Double // 孕前体重（千克）
    public let currentWeight: Double // 当前体重（千克）
    public let bloodType: String // 血型
    public let age: Int // 年龄
    public let medicalHistory: String? // 个人病史
    public let familyHistory: String? // 家族病史
    public let allergiesHistory: String? // 过敏史
    public let obstetricHistory: String? // 既往孕产史
    public let isSmoking: Bool // 是否吸烟
    public let isDrinking: Bool // 是否饮酒
    public let createdAt: Date // 创建时间
    public let updatedAt: Date // 更新时间
    public let bmi: Double // BMI指数

    // 计算属性：体重增长
    public var weightGain: Double {
        return currentWeight - prePregnancyWeight
    }
}

// 健康档案响应包装模型
public struct HealthProfileResponse: Codable {
    public let success: Bool
    public let message: String?
    public let data: HealthProfile?
}
