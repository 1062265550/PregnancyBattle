import Foundation

struct ConstraintUpdateResults {
    let ultrasoundDate: Date
    let ultrasoundWeeks: Int
    let ultrasoundDays: Int
    let ultrasoundDatePickerEffectiveRange: ClosedRange<Date>
    let ultrasoundWeeksPickerRange: ClosedRange<Int>
    let ultrasoundDaysPickerRange: ClosedRange<Int>
}

// Actor to serialize access to modification logic and state for B-ultrasound constraints
@MainActor // Ensure UI updates from ViewModel are on the main thread
class ConstraintUpdateActor {

    // Hardcode constants to avoid ambiguity issues - 改为40周
    private let bUltrasoundGlobalMinDateOffsetDays: Int = -(40 * 7)
    private let maxPregnancyDurationDays: Int = 40 * 7
    private let bUltrasoundMaxGestationWeeksAllowedByUI: Int = 40 // Max 40 weeks

    // Helper to safely get a date or return a fallback
    private func safeDate(byAdding component: Calendar.Component = .day, value: Int, to date: Date, fallbackDate: Date? = nil) -> Date {
        return Calendar.current.date(byAdding: component, value: value, to: date) ?? fallbackDate ?? Date.distantPast
    }

    // Called from ViewModel's init or after data load to set up initial constraints
    func initializeConstraints(currentUltrasoundDate: Date, currentUltrasoundWeeks: Int, currentUltrasoundDays: Int) async -> ConstraintUpdateResults {
        let today = Date()

        var tempUltrasoundDate = currentUltrasoundDate
        var tempWeeks = currentUltrasoundWeeks
        var tempDays = currentUltrasoundDays

        // 最早可选日期是当前日期减去40周
        let globalMinAllowableDate = safeDate(value: self.bUltrasoundGlobalMinDateOffsetDays, to: today, fallbackDate: Date.distantPast)
        // 最晚可选日期是当前日期
        let globalMaxAllowableDate = today

        // 确保超声日期在允许范围内
        if tempUltrasoundDate < globalMinAllowableDate { tempUltrasoundDate = globalMinAllowableDate }
        if tempUltrasoundDate > globalMaxAllowableDate { tempUltrasoundDate = globalMaxAllowableDate }

        // 计算从B超日期到今天已经过去的天数
        let daysPassedSinceTempDate: Int = Calendar.current.dateComponents([.day], from: tempUltrasoundDate, to: globalMaxAllowableDate).day ?? 0
        // 计算在B超日期时可能的最大孕期天数 (确保总孕期不超过40周)
        let maxPossibleGestationAtTempDate: Int = max(0, self.maxPregnancyDurationDays - daysPassedSinceTempDate)

        // 计算最大可选孕周 (不超过40周)
        let maxWeeksForPickers: Int = min(self.bUltrasoundMaxGestationWeeksAllowedByUI, max(0, Int(floor(Double(maxPossibleGestationAtTempDate) / 7.0))))
        let newWeeksRange = 0...maxWeeksForPickers

        // 确保选中的孕周在允许范围内
        if tempWeeks < 0 { tempWeeks = 0 }
        if tempWeeks > maxWeeksForPickers { tempWeeks = maxWeeksForPickers }

        // 计算最大可选孕天 (考虑已选孕周，确保总孕期不超过40周)
        let maxDaysForPickers: Int = min(6, max(0, maxPossibleGestationAtTempDate - (tempWeeks * 7)))
        let newDaysRange = 0...maxDaysForPickers

        // 确保选中的孕天在允许范围内
        if tempDays < 0 { tempDays = 0 }
        if tempDays > maxDaysForPickers { tempDays = maxDaysForPickers }

        // 为了保持一致性，始终使用全局最小日期作为日期选择器范围的下限
        let newDatePickerRange = globalMinAllowableDate...globalMaxAllowableDate

        // 最终确保超声日期在有效范围内
        if tempUltrasoundDate < globalMinAllowableDate { tempUltrasoundDate = globalMinAllowableDate }
        if tempUltrasoundDate > globalMaxAllowableDate { tempUltrasoundDate = globalMaxAllowableDate }

        return ConstraintUpdateResults(
            ultrasoundDate: tempUltrasoundDate,
            ultrasoundWeeks: tempWeeks,
            ultrasoundDays: tempDays,
            ultrasoundDatePickerEffectiveRange: newDatePickerRange,
            ultrasoundWeeksPickerRange: newWeeksRange,
            ultrasoundDaysPickerRange: newDaysRange
        )
    }

    func handleUltrasoundDateChange(newDate: Date, currentUltrasoundWeeks: Int, currentUltrasoundDays: Int) async -> ConstraintUpdateResults {
        let today = Date()
        var targetDate = newDate

        // 设置日期选择的全局限制
        let globalMinAllowableDate = safeDate(value: self.bUltrasoundGlobalMinDateOffsetDays, to: today, fallbackDate: Date.distantPast)
        let globalMaxAllowableDate = today

        // 确保日期在允许的范围内
        if targetDate < globalMinAllowableDate { targetDate = globalMinAllowableDate }
        if targetDate > globalMaxAllowableDate { targetDate = globalMaxAllowableDate }

        // 保留当前的孕周和孕天值，而不是重置为0
        var tempWeeks = currentUltrasoundWeeks
        var tempDays = currentUltrasoundDays

        // 计算从B超日期到今天的天数
        let daysPassedSinceTargetDate: Int = Calendar.current.dateComponents([.day], from: targetDate, to: globalMaxAllowableDate).day ?? 0
        // 计算在该日期时可能的最大孕期天数
        let maxPossibleGestationAtTargetDate: Int = max(0, self.maxPregnancyDurationDays - daysPassedSinceTargetDate)

        // 计算新的孕周选择范围
        let maxWeeksForPickers: Int = min(self.bUltrasoundMaxGestationWeeksAllowedByUI, max(0, Int(floor(Double(maxPossibleGestationAtTargetDate) / 7.0))))
        let newWeeksRange = 0...maxWeeksForPickers

        // 确保孕周在新范围内
        if tempWeeks < 0 { tempWeeks = 0 }
        if tempWeeks > maxWeeksForPickers { tempWeeks = maxWeeksForPickers }

        // 计算天数选择范围
        let maxDaysForPickers: Int = min(6, max(0, maxPossibleGestationAtTargetDate - (tempWeeks * 7)))
        let newDaysRange = 0...maxDaysForPickers

        // 确保孕天在新范围内
        if tempDays < 0 { tempDays = 0 }
        if tempDays > maxDaysForPickers { tempDays = maxDaysForPickers }

        // 使用统一固定的日期范围
        let newDatePickerRange = globalMinAllowableDate...globalMaxAllowableDate

        return ConstraintUpdateResults(
            ultrasoundDate: targetDate,
            ultrasoundWeeks: tempWeeks,
            ultrasoundDays: tempDays,
            ultrasoundDatePickerEffectiveRange: newDatePickerRange,
            ultrasoundWeeksPickerRange: newWeeksRange,
            ultrasoundDaysPickerRange: newDaysRange
        )
    }

    func handleUltrasoundWeeksChange(newWeeks: Int, currentUltrasoundDate: Date, currentUltrasoundDays: Int) async -> ConstraintUpdateResults {
        let today = Date()
        var targetWeeks = newWeeks

        let globalMinAllowableDate = safeDate(value: self.bUltrasoundGlobalMinDateOffsetDays, to: today, fallbackDate: Date.distantPast)
        let globalMaxAllowableDate = today

        var tempUltrasoundDate = currentUltrasoundDate
        var tempDays = 0 // 当孕周变化时，重置孕天为0

        let daysPassedSinceTempDate: Int = Calendar.current.dateComponents([.day], from: tempUltrasoundDate, to: globalMaxAllowableDate).day ?? 0
        let maxPossibleGestationAtTempDate: Int = max(0, self.maxPregnancyDurationDays - daysPassedSinceTempDate)
        let maxWeeksPossibleForDate: Int = min(self.bUltrasoundMaxGestationWeeksAllowedByUI, max(0, Int(floor(Double(maxPossibleGestationAtTempDate) / 7.0))))

        if targetWeeks < 0 { targetWeeks = 0 }
        if targetWeeks > maxWeeksPossibleForDate { targetWeeks = maxWeeksPossibleForDate }
        let newWeeksRange = 0...maxWeeksPossibleForDate

        // 计算新的孕天范围
        let maxDaysForPickers: Int = min(6, max(0, maxPossibleGestationAtTempDate - (targetWeeks * 7)))
        let newDaysRange = 0...maxDaysForPickers

        // 确保孕天在新范围内
        if tempDays < 0 { tempDays = 0 }
        if tempDays > maxDaysForPickers { tempDays = maxDaysForPickers }

        // 为了保持一致性，始终使用全局最小日期作为日期选择器范围的下限
        let newDatePickerRange = globalMinAllowableDate...globalMaxAllowableDate

        // 确保日期在允许范围内
        if tempUltrasoundDate < globalMinAllowableDate { tempUltrasoundDate = globalMinAllowableDate }
        if tempUltrasoundDate > globalMaxAllowableDate { tempUltrasoundDate = globalMaxAllowableDate }

        return ConstraintUpdateResults(
            ultrasoundDate: tempUltrasoundDate,
            ultrasoundWeeks: targetWeeks,
            ultrasoundDays: tempDays,
            ultrasoundDatePickerEffectiveRange: newDatePickerRange,
            ultrasoundWeeksPickerRange: newWeeksRange,
            ultrasoundDaysPickerRange: newDaysRange
        )
    }

    func handleUltrasoundDaysChange(newDays: Int, currentUltrasoundDate: Date, currentUltrasoundWeeks: Int) async -> ConstraintUpdateResults {
        let today = Date()
        var targetDays = newDays

        let globalMinAllowableDate = safeDate(value: self.bUltrasoundGlobalMinDateOffsetDays, to: today, fallbackDate: Date.distantPast)
        let globalMaxAllowableDate = today

        var tempUltrasoundDate = currentUltrasoundDate
        let tempWeeks = currentUltrasoundWeeks

        // 确保日期在允许范围内
        if tempUltrasoundDate < globalMinAllowableDate { tempUltrasoundDate = globalMinAllowableDate }
        if tempUltrasoundDate > globalMaxAllowableDate { tempUltrasoundDate = globalMaxAllowableDate }

        let daysPassedSinceTempDate: Int = Calendar.current.dateComponents([.day], from: tempUltrasoundDate, to: globalMaxAllowableDate).day ?? 0
        let maxPossibleGestationAtTempDate: Int = max(0, self.maxPregnancyDurationDays - daysPassedSinceTempDate)
        let maxDaysPossibleForDateAndWeek: Int = min(6, max(0, maxPossibleGestationAtTempDate - (tempWeeks * 7)))

        if targetDays < 0 { targetDays = 0 }
        if targetDays > maxDaysPossibleForDateAndWeek { targetDays = maxDaysPossibleForDateAndWeek }
        let newDaysRange = 0...maxDaysPossibleForDateAndWeek

        // 计算可能的最大孕周
        let maxPossibleGestationAfterDateClamp = max(0, self.maxPregnancyDurationDays - daysPassedSinceTempDate)
        let maxWeeksPossibleForFinalDate = min(self.bUltrasoundMaxGestationWeeksAllowedByUI, max(0, Int(floor(Double(maxPossibleGestationAfterDateClamp) / 7.0))))
        let newWeeksRange = 0...maxWeeksPossibleForFinalDate

        // 使用统一固定的日期范围
        let newDatePickerRange = globalMinAllowableDate...globalMaxAllowableDate

        return ConstraintUpdateResults(
            ultrasoundDate: tempUltrasoundDate,
            ultrasoundWeeks: tempWeeks,
            ultrasoundDays: targetDays,
            ultrasoundDatePickerEffectiveRange: newDatePickerRange,
            ultrasoundWeeksPickerRange: newWeeksRange,
            ultrasoundDaysPickerRange: newDaysRange
        )
    }
}