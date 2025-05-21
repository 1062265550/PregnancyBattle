import Foundation

// 预产期计算方式枚举
enum PregnancyCalculationMethod: String, Codable {
    case lmp = "LMP"           // 末次月经
    case ultrasound = "Ultrasound"    // B超
    case ivf = "IVF"           // 试管婴儿

    // 自定义字符串表示，用于UI显示
    var displayName: String {
        return self.rawValue
    }
}

// 创建孕期信息请求模型
struct CreatePregnancyInfoRequest: Codable {
    let lmpDate: Date
    let calculationMethod: PregnancyCalculationMethod
    let ultrasoundDate: Date?
    let ultrasoundWeeks: Int?
    let ultrasoundDays: Int?
    let isMultiplePregnancy: Bool
    let fetusCount: Int?
    let ivfTransferDate: Date?
    let ivfEmbryoAge: Int?

    enum CodingKeys: String, CodingKey {
        case lmpDate = "lmpDate"
        case calculationMethod = "calculationMethod"
        case ultrasoundDate = "ultrasoundDate"
        case ultrasoundWeeks = "ultrasoundWeeks"
        case ultrasoundDays = "ultrasoundDays"
        case isMultiplePregnancy = "isMultiplePregnancy"
        case fetusCount = "fetusCount"
        case ivfTransferDate = "ivfTransferDate"
        case ivfEmbryoAge = "ivfEmbryoAge"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let calendar = Calendar.current
        
        let lmpDateComponents = calendar.dateComponents([.year, .month, .day], from: lmpDate)
        if let lmpDateOnly = calendar.date(from: lmpDateComponents) {
            try container.encode(lmpDateOnly, forKey: .lmpDate)
        }

        try container.encode(calculationMethod, forKey: .calculationMethod)

        if let ultrasoundDate = ultrasoundDate {
            let ultrasoundDateComponents = calendar.dateComponents([.year, .month, .day], from: ultrasoundDate)
            if let ultrasoundDateOnly = calendar.date(from: ultrasoundDateComponents) {
                try container.encode(ultrasoundDateOnly, forKey: .ultrasoundDate)
            }
        }
        try container.encodeIfPresent(ultrasoundWeeks, forKey: .ultrasoundWeeks)
        try container.encodeIfPresent(ultrasoundDays, forKey: .ultrasoundDays)
        
        try container.encode(isMultiplePregnancy, forKey: .isMultiplePregnancy)
        try container.encodeIfPresent(fetusCount, forKey: .fetusCount)

        if let ivfTransferDate = ivfTransferDate {
            let ivfDateComponents = calendar.dateComponents([.year, .month, .day], from: ivfTransferDate)
            if let ivfDateOnly = calendar.date(from: ivfDateComponents) {
                try container.encode(ivfDateOnly, forKey: .ivfTransferDate)
            }
        }
        try container.encodeIfPresent(ivfEmbryoAge, forKey: .ivfEmbryoAge)
    }
}

// 更新孕期信息请求模型
struct UpdatePregnancyInfoRequest: Codable {
    let lmpDate: Date?
    let dueDate: Date?
    let calculationMethod: PregnancyCalculationMethod?
    let ultrasoundDate: Date?
    let ultrasoundWeeks: Int?
    let ultrasoundDays: Int?
    let isMultiplePregnancy: Bool?
    let fetusCount: Int?
    let ivfTransferDate: Date? //确保此字段存在
    let ivfEmbryoAge: Int?    //确保此字段存在

    enum CodingKeys: String, CodingKey {
        case lmpDate = "lmpDate"
        case dueDate = "dueDate"
        case calculationMethod = "calculationMethod"
        case ultrasoundDate = "ultrasoundDate"
        case ultrasoundWeeks = "ultrasoundWeeks"
        case ultrasoundDays = "ultrasoundDays"
        case isMultiplePregnancy = "isMultiplePregnancy"
        case fetusCount = "fetusCount"
        case ivfTransferDate = "ivfTransferDate" //确保此 CodingKey 存在
        case ivfEmbryoAge = "ivfEmbryoAge"       //确保此 CodingKey 存在
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let calendar = Calendar.current

        if let lmpDate = lmpDate {
            let lmpDateComponents = calendar.dateComponents([.year, .month, .day], from: lmpDate)
            if let lmpDateOnly = calendar.date(from: lmpDateComponents) {
                try container.encode(lmpDateOnly, forKey: .lmpDate)
            }
        }

        if let dueDate = dueDate {
            let dueDateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
            if let dueDateOnly = calendar.date(from: dueDateComponents) {
                try container.encode(dueDateOnly, forKey: .dueDate)
            }
        }

        try container.encodeIfPresent(calculationMethod, forKey: .calculationMethod)

        if let ultrasoundDate = ultrasoundDate {
            let ultrasoundDateComponents = calendar.dateComponents([.year, .month, .day], from: ultrasoundDate)
            if let ultrasoundDateOnly = calendar.date(from: ultrasoundDateComponents) {
                try container.encode(ultrasoundDateOnly, forKey: .ultrasoundDate)
            }
        }
        try container.encodeIfPresent(ultrasoundWeeks, forKey: .ultrasoundWeeks)
        try container.encodeIfPresent(ultrasoundDays, forKey: .ultrasoundDays)
        
        try container.encodeIfPresent(isMultiplePregnancy, forKey: .isMultiplePregnancy)
        try container.encodeIfPresent(fetusCount, forKey: .fetusCount)

        if let ivfTransferDate = ivfTransferDate { //确保编码逻辑存在
            let ivfDateComponents = calendar.dateComponents([.year, .month, .day], from: ivfTransferDate)
            if let ivfDateOnly = calendar.date(from: ivfDateComponents) {
                try container.encode(ivfDateOnly, forKey: .ivfTransferDate)
            }
        }
        try container.encodeIfPresent(ivfEmbryoAge, forKey: .ivfEmbryoAge) //确保编码逻辑存在
    }
}

// 孕期信息响应模型 (假设这个结构体定义没有问题，保持不变)
struct PregnancyInfo: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let lmpDate: Date
    let dueDate: Date
    let calculationMethod: PregnancyCalculationMethod
    let ultrasoundDate: Date?
    let ultrasoundWeeks: Int?
    let ultrasoundDays: Int?
    let ivfTransferDate: Date?
    let ivfEmbryoAge: Int?
    let isMultiplePregnancy: Bool
    let fetusCount: Int?
    let currentWeek: Int
    let currentDay: Int
    let pregnancyStage: String
    let daysUntilDueDate: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "userId"
        case lmpDate = "lmpDate"
        case dueDate = "dueDate"
        case calculationMethod = "calculationMethod"
        case ultrasoundDate = "ultrasoundDate"
        case ultrasoundWeeks = "ultrasoundWeeks"
        case ultrasoundDays = "ultrasoundDays"
        case ivfTransferDate = "ivfTransferDate"
        case ivfEmbryoAge = "ivfEmbryoAge"
        case isMultiplePregnancy = "isMultiplePregnancy"
        case fetusCount = "fetusCount"
        case currentWeek = "currentWeek"
        case currentDay = "currentDay"
        case pregnancyStage = "pregnancyStage"
        case daysUntilDueDate = "daysUntilDueDate"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        lmpDate = try container.decode(Date.self, forKey: .lmpDate)
        dueDate = try container.decode(Date.self, forKey: .dueDate)

        let methodString = try container.decode(String.self, forKey: .calculationMethod)
        switch methodString.uppercased() {
        case "LMP":
            calculationMethod = .lmp
        case "ULTRASOUND":
            calculationMethod = .ultrasound
        case "IVF":
            calculationMethod = .ivf
        default:
            calculationMethod = .lmp
        }

        ultrasoundDate = try container.decodeIfPresent(Date.self, forKey: .ultrasoundDate)
        ultrasoundWeeks = try container.decodeIfPresent(Int.self, forKey: .ultrasoundWeeks)
        ultrasoundDays = try container.decodeIfPresent(Int.self, forKey: .ultrasoundDays)
        ivfTransferDate = try container.decodeIfPresent(Date.self, forKey: .ivfTransferDate)
        ivfEmbryoAge = try container.decodeIfPresent(Int.self, forKey: .ivfEmbryoAge)
        isMultiplePregnancy = try container.decode(Bool.self, forKey: .isMultiplePregnancy)
        fetusCount = try container.decodeIfPresent(Int.self, forKey: .fetusCount)
        currentWeek = try container.decode(Int.self, forKey: .currentWeek)
        currentDay = try container.decode(Int.self, forKey: .currentDay)
        pregnancyStage = try container.decode(String.self, forKey: .pregnancyStage)
        daysUntilDueDate = try container.decode(Int.self, forKey: .daysUntilDueDate)
    }
}

// 孕期阶段枚举 (保持不变)
enum PregnancyStage: String {
    case early = "早期"
    case middle = "中期"
    case late = "晚期"

    static func fromWeek(_ week: Int) -> PregnancyStage {
        if week <= 13 {
            return .early
        } else if week <= 27 {
            return .middle
        } else {
            return .late
        }
    }
}

// 胎儿大小比喻 (保持不变)
struct FetusSizeComparison {
    static func getComparison(forWeek week: Int) -> String {
        switch week {
        case 1...4:
            return "一粒西瓜籽"
        case 5:
            return "一粒芝麻"
        case 6:
            return "一粒扁豆"
        case 7:
            return "一颗蓝莓"
        case 8:
            return "一颗树莓"
        case 9:
            return "一颗葡萄"
        case 10:
            return "一颗草莓"
        case 11:
            return "一个青柠"
        case 12:
            return "一个柠檬"
        case 13:
            return "一个桃子"
        case 14:
            return "一个梨"
        case 15:
            return "一个苹果"
        case 16:
            return "一个牛油果"
        case 17:
            return "一个甜瓜"
        case 18:
            return "一个甜椒"
        case 19:
            return "一个芒果"
        case 20:
            return "一个香蕉"
        case 21:
            return "一个胡萝卜"
        case 22:
            return "一个茄子"
        case 23:
            return "一个玉米"
        case 24:
            return "一个西葫芦"
        case 25:
            return "一个花椰菜"
        case 26:
            return "一个莴苣"
        case 27:
            return "一个白菜"
        case 28:
            return "一个小南瓜"
        case 29:
            return "一个菠萝"
        case 30:
            return "一个大南瓜"
        case 31:
            return "一个椰子"
        case 32:
            return "一个哈密瓜"
        case 33:
            return "一个菠萝蜜"
        case 34:
            return "一个蜜瓜"
        case 35:
            return "一个小西瓜"
        case 36:
            return "一个中等大小的西瓜"
        case 37...42:
            return "一个大西瓜"
        default:
            return "未知"
        }
    }
}
