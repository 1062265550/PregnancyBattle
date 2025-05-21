import Foundation
import SwiftUI

@MainActor
class PregnancyTrackerViewModel: ObservableObject {
    @Published var pregnancyInfo: PregnancyInfo?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showLMPInput = false

    // LMP输入表单
    @Published var lmpDate = Date()
    @Published var calculationMethod: PregnancyCalculationMethod = .lmp

    // B超交互状态控制
    @Published var ultrasoundSelectionStep = UltrasoundSelectionStep.date

    // B-ultrasound related properties with didSet for dynamic updates
    @Published var ultrasoundDate: Date = Date() {
        didSet {
            if oldValue != ultrasoundDate {
                Task {
                    let results = await constraintUpdateActor.handleUltrasoundDateChange(newDate: ultrasoundDate, currentUltrasoundWeeks: self.ultrasoundWeeks, currentUltrasoundDays: self.ultrasoundDays)

                    // 简化UI更新逻辑，移除嵌套异步调用
                    await MainActor.run {
                        self.applyConstraintUpdateResults(results)
                        // 只有当用户从日期选择步骤开始时，才自动进入孕周选择步骤
                        // 这样可以让用户在任何时候自由选择日期
                        if self.ultrasoundSelectionStep == .date {
                            self.ultrasoundSelectionStep = .weeks
                        }
                    }
                }
            }
        }
    }
    @Published var ultrasoundWeeks: Int = 0 {
        didSet {
            if oldValue != ultrasoundWeeks {
                Task {
                    let results = await constraintUpdateActor.handleUltrasoundWeeksChange(newWeeks: ultrasoundWeeks, currentUltrasoundDate: self.ultrasoundDate, currentUltrasoundDays: self.ultrasoundDays)
                    self.applyConstraintUpdateResults(results)
                    // 只有当用户从孕周选择步骤开始时，才自动进入孕天选择步骤
                    // 这样可以让用户在任何时候自由选择孕周
                    if self.ultrasoundSelectionStep == .weeks {
                        self.ultrasoundSelectionStep = .days
                    }
                }
            }
        }
    }
    @Published var ultrasoundDays: Int = 0 {
        didSet {
            if oldValue != ultrasoundDays {
                Task {
                    let results = await constraintUpdateActor.handleUltrasoundDaysChange(newDays: ultrasoundDays, currentUltrasoundDate: self.ultrasoundDate, currentUltrasoundWeeks: self.ultrasoundWeeks)
                    self.applyConstraintUpdateResults(results)
                }
            }
        }
    }

    // Dynamic ranges for B-ultrasound pickers and date picker
    @Published var ultrasoundWeeksPickerRange: ClosedRange<Int> = 0...PregnancyTrackerViewModel.bUltrasoundMaxGestationWeeksAllowedByUI
    @Published var ultrasoundDaysPickerRange: ClosedRange<Int> = 0...6
    @Published var ultrasoundDatePickerEffectiveRange: ClosedRange<Date> // Initialized in init

    @Published var isMultiplePregnancy: Bool = false
    @Published var fetusCount: Int = 2

    // IVF 输入表单 (新增)
    @Published var ivfTransferDate: Date = Date() {
        didSet {
            // 当IVF日期改变时，确保日期在允许范围内
            if oldValue != ivfTransferDate {
                validateIvfTransferDate()
            }
        }
    }
    @Published var ivfEmbryoAge: Int = 3 // Default to D3 embryo, can be changed by Picker

    // IVF日期范围计算
    private func validateIvfTransferDate() {
        let today = Date()
        let calendar = Calendar.current

        // 最早可选日期是当前日期减去约37周（259天）
        let minIvfOffset = -259
        if let minIvfDate = calendar.date(byAdding: .day, value: minIvfOffset, to: today) {
            if ivfTransferDate < minIvfDate {
                ivfTransferDate = minIvfDate
            } else if ivfTransferDate > today {
                ivfTransferDate = today
            }
        }
    }

    // Actor for handling constraint updates
    private let constraintUpdateActor = ConstraintUpdateActor()

    // 胎儿大小比喻
    var fetusSizeComparison: String {
        guard let info = pregnancyInfo else { return "未知" }
        return FetusSizeComparison.getComparison(forWeek: info.currentWeek)
    }

    // 格式化日期
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    // 格式化预产期
    var formattedDueDate: String {
        guard let info = pregnancyInfo else { return "未知" }
        return dateFormatter.string(from: info.dueDate)
    }

    // 初始化
    init() {
        let today = Date()
        // Provide a safe initial range. Actor will refine it.
        if let initialMinDate = Calendar.current.date(byAdding: .day, value: PregnancyTrackerViewModel.bUltrasoundGlobalMinDateOffsetDays, to: today) {
            self.ultrasoundDatePickerEffectiveRange = initialMinDate...today
            // Ensure ultrasoundDate is within a reasonable initial range before actor initialization
            let clampedInitialDate = min(today, max(initialMinDate, self.ultrasoundDate))
            self.ultrasoundDate = clampedInitialDate // This will trigger didSet and initial actor call if needed
        } else {
            self.ultrasoundDatePickerEffectiveRange = today...today
            self.ultrasoundDate = today // This will trigger didSet and initial actor call if needed
        }

        // 验证IVF日期是否在有效范围内
        validateIvfTransferDate()

        Task {
            // Initial constraints setup after properties are initialized
            let initialResults = await constraintUpdateActor.initializeConstraints(currentUltrasoundDate: self.ultrasoundDate, currentUltrasoundWeeks: self.ultrasoundWeeks, currentUltrasoundDays: self.ultrasoundDays)
            self.applyConstraintUpdateResults(initialResults)

            await loadPregnancyInfo()
        }
    }

    // 重置B超输入状态，当切换到B超输入模式时调用
    func resetUltrasoundSelectionState() {
        ultrasoundSelectionStep = .date
        // 重置B超相关的值为默认值
        Task {
            let today = Date()
            if let initialMinDate = Calendar.current.date(byAdding: .day, value: PregnancyTrackerViewModel.bUltrasoundGlobalMinDateOffsetDays, to: today) {
                // 不要重置日期，保持当前选择的日期
                // 但确保日期在有效范围内
                let clampedDate = min(today, max(initialMinDate, self.ultrasoundDate))
                if clampedDate != self.ultrasoundDate {
                    self.ultrasoundDate = clampedDate
                }
            }

            // 重新初始化约束
            let results = await constraintUpdateActor.initializeConstraints(
                currentUltrasoundDate: self.ultrasoundDate,
                currentUltrasoundWeeks: self.ultrasoundWeeks,
                currentUltrasoundDays: self.ultrasoundDays
            )
            self.applyConstraintUpdateResults(results)
        }
    }

    private func applyConstraintUpdateResults(_ results: ConstraintUpdateResults) {
        if self.ultrasoundDate != results.ultrasoundDate { self.ultrasoundDate = results.ultrasoundDate }
        if self.ultrasoundWeeks != results.ultrasoundWeeks { self.ultrasoundWeeks = results.ultrasoundWeeks }
        if self.ultrasoundDays != results.ultrasoundDays { self.ultrasoundDays = results.ultrasoundDays }
        if self.ultrasoundDatePickerEffectiveRange != results.ultrasoundDatePickerEffectiveRange { self.ultrasoundDatePickerEffectiveRange = results.ultrasoundDatePickerEffectiveRange }
        if self.ultrasoundWeeksPickerRange != results.ultrasoundWeeksPickerRange { self.ultrasoundWeeksPickerRange = results.ultrasoundWeeksPickerRange }
        if self.ultrasoundDaysPickerRange != results.ultrasoundDaysPickerRange { self.ultrasoundDaysPickerRange = results.ultrasoundDaysPickerRange }
    }

    // 加载孕期信息
    func loadPregnancyInfo() async {
        guard AuthManager.shared.isAuthenticated else {
            showLMPInput = true
            // If not authenticated, ensure constraints are based on default values.
            Task {
                let results = await constraintUpdateActor.initializeConstraints(currentUltrasoundDate: self.ultrasoundDate, currentUltrasoundWeeks: self.ultrasoundWeeks, currentUltrasoundDays: self.ultrasoundDays)
                self.applyConstraintUpdateResults(results)
            }
            return
        }

        isLoading = true
        error = nil
        self.pregnancyInfo = nil // Reset before loading

        do {
            let loadedInfo = try await PregnancyInfoService.shared.getPregnancyInfo()
            // If successful, loadedInfo is a non-optional PregnancyInfo
            self.pregnancyInfo = loadedInfo // Assign to the @Published Optional property

            // Populate ViewModel properties from loadedInfo
            self.lmpDate = loadedInfo.lmpDate
            self.calculationMethod = loadedInfo.calculationMethod
            // Use loadedInfo directly for IVF fields as they are now part of PregnancyInfo
            self.ultrasoundDate = loadedInfo.ultrasoundDate ?? Date()
            self.ultrasoundWeeks = loadedInfo.ultrasoundWeeks ?? 0
            self.ultrasoundDays = loadedInfo.ultrasoundDays ?? 0
            self.isMultiplePregnancy = loadedInfo.isMultiplePregnancy
            self.fetusCount = loadedInfo.fetusCount ?? 2
            self.ivfTransferDate = loadedInfo.ivfTransferDate ?? Date()
            self.ivfEmbryoAge = loadedInfo.ivfEmbryoAge ?? 3

            // 验证IVF日期是否在有效范围内
            validateIvfTransferDate()

            // 如果是B超方式，设置选择步骤为days（表示所有步骤已完成）
            if self.calculationMethod == .ultrasound {
                self.ultrasoundSelectionStep = .days
            }

            // After setting properties from loaded data, re-initialize/re-evaluate constraints
            let results = await constraintUpdateActor.initializeConstraints(currentUltrasoundDate: self.ultrasoundDate, currentUltrasoundWeeks: self.ultrasoundWeeks, currentUltrasoundDays: self.ultrasoundDays)
            self.applyConstraintUpdateResults(results)
            showLMPInput = false // Successfully loaded, so don't show input form

        } catch let apiError as APIError {
            if case .notFound = apiError {
                showLMPInput = true
                // if not found, it's like a new entry, initialize constraints for defaults
                Task {
                    let results = await constraintUpdateActor.initializeConstraints(currentUltrasoundDate: self.ultrasoundDate, currentUltrasoundWeeks: self.ultrasoundWeeks, currentUltrasoundDays: self.ultrasoundDays)
                    self.applyConstraintUpdateResults(results)
                }
            } else {
                error = handleError(apiError)
                showLMPInput = true // Also show input if other error, so user can try to set manually
            }
        } catch {
            self.error = error.localizedDescription
            showLMPInput = true // Show input on generic error
        }

        isLoading = false
    }

    // 创建孕期信息
    func createPregnancyInfo() async {
        isLoading = true
        error = nil

        do {
            let request = CreatePregnancyInfoRequest(
                lmpDate: lmpDate,
                calculationMethod: calculationMethod,
                ultrasoundDate: calculationMethod == .ultrasound ? ultrasoundDate : nil,
                ultrasoundWeeks: calculationMethod == .ultrasound ? ultrasoundWeeks : nil,
                ultrasoundDays: calculationMethod == .ultrasound ? ultrasoundDays : nil,
                isMultiplePregnancy: isMultiplePregnancy,
                fetusCount: isMultiplePregnancy ? fetusCount : nil,
                ivfTransferDate: calculationMethod == .ivf ? ivfTransferDate : nil,
                ivfEmbryoAge: calculationMethod == .ivf ? ivfEmbryoAge : nil
            )

            pregnancyInfo = try await PregnancyInfoService.shared.createPregnancyInfo(request: request)
            showLMPInput = false
        } catch let apiError as APIError {
            error = handleError(apiError)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // 更新孕期信息
    func updatePregnancyInfo() async {
        isLoading = true
        error = nil

        do {
            let request = UpdatePregnancyInfoRequest(
                lmpDate: self.lmpDate,
                dueDate: nil,
                calculationMethod: calculationMethod,
                ultrasoundDate: calculationMethod == .ultrasound ? ultrasoundDate : nil,
                ultrasoundWeeks: calculationMethod == .ultrasound ? ultrasoundWeeks : nil,
                ultrasoundDays: calculationMethod == .ultrasound ? ultrasoundDays : nil,
                isMultiplePregnancy: isMultiplePregnancy,
                fetusCount: isMultiplePregnancy ? fetusCount : nil,
                ivfTransferDate: calculationMethod == .ivf ? ivfTransferDate : nil,
                ivfEmbryoAge: calculationMethod == .ivf ? ivfEmbryoAge : nil
            )

            pregnancyInfo = try await PregnancyInfoService.shared.updatePregnancyInfo(request: request)
            showLMPInput = false
        } catch let apiError as APIError {
            error = handleError(apiError)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // 刷新孕周信息
    func refreshPregnancyInfo() async {
        isLoading = true
        error = nil

        do {
            pregnancyInfo = try await PregnancyInfoService.shared.getCurrentWeekAndDay()
        } catch let apiError as APIError {
            error = handleError(apiError)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // 处理API错误
    private func handleError(_ error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .invalidData:
            return "无效的数据"
        case .requestFailed(let error):
            return "请求失败: \(error.localizedDescription)"
        case .serverError(let code):
            return "服务器错误: \(code)"
        case .decodingError(let error):
            return "解码错误: \(error.localizedDescription)"
        case .encodingError(let error):
            return "编码错误: \(error.localizedDescription)"
        case .unauthorized:
            return "未授权"
        case .notFound:
            return "未找到孕期信息"
        case .badRequest(let message):
            return "请求错误: \(message)"
        case .businessError(let message, _):
            return message
        case .unknown:
            return "未知错误"
        }
    }
}

// B超输入步骤枚举
enum UltrasoundSelectionStep {
    case date // 第一步：选择日期
    case weeks // 第二步：选择孕周
    case days // 第三步：选择孕天
}

// Extension for static constants
extension PregnancyTrackerViewModel {
    static let maxPregnancyDurationDays = 280 // 40 weeks
    static let bUltrasoundMaxGestationWeeksAllowedByUI = 40 // 改为40周，符合用户要求
    static let bUltrasoundGlobalMinDateOffsetDays = -(40 * 7) // 改为40周，符合用户要求
}