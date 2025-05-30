import Foundation
import SwiftUI

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
    var currentWeek: Int
    var currentDay: Int
    var pregnancyStage: String
    var daysUntilDueDate: Int

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

        print("[PregnancyInfo] 开始解码孕期信息")

        do {
            id = try container.decode(UUID.self, forKey: .id)
            print("[PregnancyInfo] 解码ID成功: \(id)")
        } catch {
            print("[PregnancyInfo] 解码ID失败: \(error)")
            throw error
        }

        do {
            userId = try container.decode(UUID.self, forKey: .userId)
            print("[PregnancyInfo] 解码用户ID成功: \(userId)")

            // 检查用户ID是否为空UUID
            if userId == UUID(uuidString: "00000000-0000-0000-0000-000000000000") {
                print("[PregnancyInfo] 警告：用户ID为空UUID")
                // 注意：由于AuthManager是@MainActor，我们不能在这里直接访问它
                // 如果需要处理空UUID的情况，应该在调用方处理
            }
        } catch {
            print("[PregnancyInfo] 解码用户ID失败: \(error)")
            throw error
        }

        let decodedLmpDate: Date
        do {
            let tempLmpDate = try container.decode(Date.self, forKey: .lmpDate)
            print("[PregnancyInfo] 解码末次月经日期成功: \(tempLmpDate)")

            // 检查末次月经日期是否为默认值
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: tempLmpDate)
            if let year = components.year, year < 2000 {
                print("[PregnancyInfo] 警告：末次月经日期异常: \(tempLmpDate)，使用当前日期减去280天")
                decodedLmpDate = Calendar.current.date(byAdding: .day, value: -280, to: Date()) ?? Date()
            } else {
                decodedLmpDate = tempLmpDate
            }
        } catch {
            print("[PregnancyInfo] 解码末次月经日期失败: \(error)，使用当前日期减去280天")
            decodedLmpDate = Calendar.current.date(byAdding: .day, value: -280, to: Date()) ?? Date()
        }
        lmpDate = decodedLmpDate

        let decodedDueDate: Date
        do {
            let tempDueDate = try container.decode(Date.self, forKey: .dueDate)
            print("[PregnancyInfo] 解码预产期成功: \(tempDueDate)")

            // 检查预产期是否为默认值
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year], from: tempDueDate)
            if let year = components.year, year < 2000 {
                print("[PregnancyInfo] 警告：预产期异常: \(tempDueDate)，根据末次月经日期计算")
                decodedDueDate = Calendar.current.date(byAdding: .day, value: 280, to: lmpDate) ?? Date()
            } else {
                decodedDueDate = tempDueDate
            }
        } catch {
            print("[PregnancyInfo] 解码预产期失败: \(error)，根据末次月经日期计算")
            decodedDueDate = Calendar.current.date(byAdding: .day, value: 280, to: lmpDate) ?? Date()
        }
        dueDate = decodedDueDate

        do {
            let methodString = try container.decode(String.self, forKey: .calculationMethod)
            print("[PregnancyInfo] 解码计算方式成功: \(methodString)")

            switch methodString.uppercased() {
            case "LMP":
                calculationMethod = .lmp
            case "ULTRASOUND":
                calculationMethod = .ultrasound
            case "IVF":
                calculationMethod = .ivf
            default:
                print("[PregnancyInfo] 未知的计算方式: \(methodString)，使用默认值LMP")
                calculationMethod = .lmp
            }
        } catch {
            print("[PregnancyInfo] 解码计算方式失败: \(error)，使用默认值LMP")
            calculationMethod = .lmp
        }

        do {
            ultrasoundDate = try container.decodeIfPresent(Date.self, forKey: .ultrasoundDate)
            print("[PregnancyInfo] 解码B超日期成功: \(ultrasoundDate?.description ?? "无")")
        } catch {
            print("[PregnancyInfo] 解码B超日期失败: \(error)")
            ultrasoundDate = nil
        }

        do {
            ultrasoundWeeks = try container.decodeIfPresent(Int.self, forKey: .ultrasoundWeeks)
            print("[PregnancyInfo] 解码B超孕周成功: \(ultrasoundWeeks?.description ?? "无")")
        } catch {
            print("[PregnancyInfo] 解码B超孕周失败: \(error)")
            ultrasoundWeeks = nil
        }

        do {
            ultrasoundDays = try container.decodeIfPresent(Int.self, forKey: .ultrasoundDays)
            print("[PregnancyInfo] 解码B超孕天成功: \(ultrasoundDays?.description ?? "无")")
        } catch {
            print("[PregnancyInfo] 解码B超孕天失败: \(error)")
            ultrasoundDays = nil
        }

        do {
            ivfTransferDate = try container.decodeIfPresent(Date.self, forKey: .ivfTransferDate)
            print("[PregnancyInfo] 解码IVF移植日期成功: \(ivfTransferDate?.description ?? "无")")
        } catch {
            print("[PregnancyInfo] 解码IVF移植日期失败: \(error)")
            ivfTransferDate = nil
        }

        do {
            ivfEmbryoAge = try container.decodeIfPresent(Int.self, forKey: .ivfEmbryoAge)
            print("[PregnancyInfo] 解码IVF胚胎天数成功: \(ivfEmbryoAge?.description ?? "无")")
        } catch {
            print("[PregnancyInfo] 解码IVF胚胎天数失败: \(error)")
            ivfEmbryoAge = nil
        }

        do {
            isMultiplePregnancy = try container.decode(Bool.self, forKey: .isMultiplePregnancy)
            print("[PregnancyInfo] 解码是否多胎成功: \(isMultiplePregnancy)")
        } catch {
            print("[PregnancyInfo] 解码是否多胎失败: \(error)，使用默认值false")
            isMultiplePregnancy = false
        }

        do {
            fetusCount = try container.decodeIfPresent(Int.self, forKey: .fetusCount)
            print("[PregnancyInfo] 解码胎儿数量成功: \(fetusCount?.description ?? "无")")
        } catch {
            print("[PregnancyInfo] 解码胎儿数量失败: \(error)")
            fetusCount = nil
        }

        do {
            currentWeek = try container.decode(Int.self, forKey: .currentWeek)
            print("[PregnancyInfo] 解码当前孕周成功: \(currentWeek)")

            // 检查孕周是否在合理范围内
            if currentWeek < 0 || currentWeek > 45 {
                print("[PregnancyInfo] 警告：孕周值异常: \(currentWeek)，根据预产期重新计算")

                // 根据预产期重新计算当前孕周
                let calendar = Calendar.current
                let today = Date()
                let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
                let gestationDays = 280 - daysUntilDue

                if gestationDays >= 0 {
                    currentWeek = gestationDays / 7
                    print("[PregnancyInfo] 重新计算的孕周: \(currentWeek)")
                } else {
                    print("[PregnancyInfo] 无法计算孕周，使用默认值0")
                    currentWeek = 0
                }
            }
        } catch {
            print("[PregnancyInfo] 解码当前孕周失败: \(error)，根据预产期计算")

            // 根据预产期计算当前孕周
            let calendar = Calendar.current
            let today = Date()
            let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
            let gestationDays = 280 - daysUntilDue

            if gestationDays >= 0 {
                currentWeek = gestationDays / 7
                print("[PregnancyInfo] 计算的孕周: \(currentWeek)")
            } else {
                print("[PregnancyInfo] 无法计算孕周，使用默认值0")
                currentWeek = 0
            }
        }

        do {
            currentDay = try container.decode(Int.self, forKey: .currentDay)
            print("[PregnancyInfo] 解码当前孕天成功: \(currentDay)")

            // 检查孕天是否在合理范围内
            if currentDay < 0 || currentDay > 6 {
                print("[PregnancyInfo] 警告：孕天值异常: \(currentDay)，根据预产期重新计算")

                // 根据预产期重新计算当前孕天
                let calendar = Calendar.current
                let today = Date()
                let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
                let gestationDays = 280 - daysUntilDue

                if gestationDays >= 0 {
                    currentDay = gestationDays % 7
                    print("[PregnancyInfo] 重新计算的孕天: \(currentDay)")
                } else {
                    print("[PregnancyInfo] 无法计算孕天，使用默认值0")
                    currentDay = 0
                }
            }
        } catch {
            print("[PregnancyInfo] 解码当前孕天失败: \(error)，根据预产期计算")

            // 根据预产期计算当前孕天
            let calendar = Calendar.current
            let today = Date()
            let daysUntilDue = calendar.dateComponents([.day], from: today, to: dueDate).day ?? 0
            let gestationDays = 280 - daysUntilDue

            if gestationDays >= 0 {
                currentDay = gestationDays % 7
                print("[PregnancyInfo] 计算的孕天: \(currentDay)")
            } else {
                print("[PregnancyInfo] 无法计算孕天，使用默认值0")
                currentDay = 0
            }
        }

        do {
            pregnancyStage = try container.decode(String.self, forKey: .pregnancyStage)
            print("[PregnancyInfo] 解码孕期阶段成功: \(pregnancyStage)")

            // 验证孕期阶段是否与当前孕周匹配
            let expectedStage = PregnancyStage.fromWeek(currentWeek).rawValue
            if pregnancyStage != expectedStage {
                print("[PregnancyInfo] 警告：孕期阶段(\(pregnancyStage))与当前孕周(\(currentWeek))不匹配，使用计算值: \(expectedStage)")
                pregnancyStage = expectedStage
            }
        } catch {
            print("[PregnancyInfo] 解码孕期阶段失败: \(error)，根据当前孕周计算")
            pregnancyStage = PregnancyStage.fromWeek(currentWeek).rawValue
        }

        do {
            daysUntilDueDate = try container.decode(Int.self, forKey: .daysUntilDueDate)
            print("[PregnancyInfo] 解码距离预产期天数成功: \(daysUntilDueDate)")

            // 检查距离预产期天数是否在合理范围内
            // 正常情况下，这个值应该在-100到300之间
            // -100表示已经过了预产期100天，300表示距离预产期还有300天
            if daysUntilDueDate < -100 || daysUntilDueDate > 300 {
                print("[PregnancyInfo] 警告：距离预产期天数异常: \(daysUntilDueDate)，重新计算")

                // 根据dueDate重新计算
                let calendar = Calendar.current
                let today = Date()
                let components = calendar.dateComponents([.day], from: today, to: dueDate)
                let recalculatedDays = components.day ?? 0

                print("[PregnancyInfo] 重新计算的距离预产期天数: \(recalculatedDays)")
                daysUntilDueDate = recalculatedDays
            }
        } catch {
            print("[PregnancyInfo] 解码距离预产期天数失败: \(error)，使用默认值0")
            daysUntilDueDate = 0
        }

        print("[PregnancyInfo] 孕期信息解码完成")
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
