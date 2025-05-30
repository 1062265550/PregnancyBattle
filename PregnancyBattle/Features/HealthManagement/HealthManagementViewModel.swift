import Foundation
import SwiftUI
import Network

public class HealthManagementViewModel: ObservableObject {
    // 健康档案数据
    @Published public var healthProfile: HealthProfile?
    @Published public var weightTrend: WeightTrend?
    @Published public var riskAssessment: RiskAssessment?

    // 表单数据
    @Published public var height: String = ""
    @Published public var prePregnancyWeight: String = ""
    @Published public var currentWeight: String = ""
    @Published public var bloodType: BloodType = .a
    @Published public var age: String = ""
    @Published public var medicalHistory: String = ""
    @Published public var familyHistory: String = ""
    @Published public var allergiesHistory: String = ""
    @Published public var obstetricHistory: String = ""
    @Published public var isSmoking: Bool = false
    @Published public var isDrinking: Bool = false

    // 状态管理
    @Published public var isLoading: Bool = false
    @Published public var error: String?
    @Published public var showingCreateForm: Bool = false
    @Published public var showingUpdateForm: Bool = false
    @Published public var showingWeightForm: Bool = false
    @Published public var showingSuccessAlert: Bool = false
    @Published public var successMessage: String = ""

    // 风险评估加载状态
    @Published public var isLoadingRiskAssessment: Bool = false

    // 体重记录专用加载状态
    @Published public var isRecordingWeight: Bool = false

    // 初始化
    public init() {
        Task {
            await loadData()
        }
    }

    // 加载所有数据
    @MainActor
    public func loadData() async {
        await loadDataWithRetry()
    }

    // 带重试机制的数据加载
    @MainActor
    private func loadDataWithRetry(retryCount: Int = 0) async {
        let maxRetries = 2
        isLoading = true
        error = nil

        do {
            // 尝试获取健康档案
            let profile = try await HealthProfileService.shared.getHealthProfile()
            self.healthProfile = profile

            // 如果获取成功，填充表单数据
            fillFormData(with: profile)

            // 获取体重趋势
            await loadWeightTrend()

            // 获取风险评估
            await loadRiskAssessment()

            isLoading = false
        } catch let apiError as APIError {
            isLoading = false

            // 如果是404错误（健康档案不存在），显示创建表单
            if case .notFound = apiError {
                print("[HealthManagementViewModel] 健康档案不存在，显示创建表单")
                self.error = nil // 确保清除任何可能的错误信息
                self.showingCreateForm = true
            } else if case .requestFailed(let urlError) = apiError {
                // 处理网络请求失败
                if let urlError = urlError as? URLError {
                    switch urlError.code {
                    case .cancelled:
                        if retryCount < maxRetries {
                            print("[HealthManagementViewModel] 请求被取消，重试中... (\(retryCount + 1)/\(maxRetries))")
                            // 等待1秒后重试
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            await loadDataWithRetry(retryCount: retryCount + 1)
                            return
                        } else {
                            self.error = "网络请求被取消，请检查网络连接后重试"
                        }
                    case .timedOut:
                        if retryCount < maxRetries {
                            print("[HealthManagementViewModel] 请求超时，重试中... (\(retryCount + 1)/\(maxRetries))")
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            await loadDataWithRetry(retryCount: retryCount + 1)
                            return
                        } else {
                            self.error = "网络请求超时，请检查网络连接后重试"
                        }
                    case .notConnectedToInternet:
                        self.error = "无网络连接，请检查网络设置"
                    case .networkConnectionLost:
                        self.error = "网络连接中断，请重试"
                    default:
                        self.error = "网络请求失败: \(urlError.localizedDescription)"
                    }
                } else {
                    self.error = handleError(apiError)
                }
            } else if case .unauthorized = apiError {
                self.error = "认证失败，请重新登录"
                // 可以在这里触发重新登录逻辑
            } else {
                self.error = handleError(apiError)
            }
        } catch {
            isLoading = false
            self.error = error.localizedDescription
        }
    }

    // 加载体重趋势
    @MainActor
    public func loadWeightTrend() async {
        do {
            let trend = try await HealthProfileService.shared.getWeightTrend()
            self.weightTrend = trend
        } catch {
            // 体重趋势加载失败不影响主流程，只记录错误
            print("加载体重趋势失败: \(error.localizedDescription)")
        }
    }

    // 加载风险评估
    @MainActor
    public func loadRiskAssessment() async {
        isLoadingRiskAssessment = true
        do {
            print("[HealthManagementViewModel] 开始加载风险评估...")
            let assessment = try await HealthProfileService.shared.getRiskAssessment()

            // 确保在主线程上更新UI状态
            await MainActor.run {
                self.riskAssessment = assessment
                self.isLoadingRiskAssessment = false
                print("[HealthManagementViewModel] 风险评估加载成功，isAiEnhanced: \(assessment.isAiEnhanced)")

                // 强制触发UI更新
                self.objectWillChange.send()
            }
        } catch {
            // 风险评估加载失败不影响主流程，只记录错误
            await MainActor.run {
                self.isLoadingRiskAssessment = false
                print("[HealthManagementViewModel] 加载风险评估失败: \(error)")
                if let apiError = error as? APIError {
                    print("[HealthManagementViewModel] API错误详情: \(apiError)")
                }
            }
        }
    }

    // 只加载健康档案和体重趋势（用于体重记录后的数据刷新，避免重新触发风险评估）
    @MainActor
    public func loadHealthProfileAndWeightTrend() async {
        do {
            // 重新获取健康档案以更新当前体重
            let profile = try await HealthProfileService.shared.getHealthProfile()
            self.healthProfile = profile
            fillFormData(with: profile)

            // 重新加载体重趋势
            await loadWeightTrend()

            print("[HealthManagementViewModel] 健康档案和体重趋势加载完成，避免重新加载风险评估")
        } catch {
            print("[HealthManagementViewModel] 加载健康档案和体重趋势失败: \(error)")
            // 如果加载失败，设置错误信息
            self.error = "更新数据失败: \(error.localizedDescription)"
        }
    }

    // 创建健康档案
    @MainActor
    public func createHealthProfile() async {
        guard validateForm() else { return }

        isLoading = true
        error = nil

        do {
            let request = CreateHealthProfileRequest(
                height: Double(height) ?? 0,
                prePregnancyWeight: Double(prePregnancyWeight) ?? 0,
                currentWeight: Double(currentWeight) ?? 0,
                bloodType: bloodType.rawValue,
                age: Int(age) ?? 0,
                medicalHistory: medicalHistory.isEmpty ? nil : medicalHistory,
                familyHistory: familyHistory.isEmpty ? nil : familyHistory,
                allergiesHistory: allergiesHistory.isEmpty ? nil : allergiesHistory,
                obstetricHistory: obstetricHistory.isEmpty ? nil : obstetricHistory,
                isSmoking: isSmoking,
                isDrinking: isDrinking
            )

            let profile = try await HealthProfileService.shared.createHealthProfile(request: request)
            self.healthProfile = profile
            self.showingCreateForm = false
            self.successMessage = "健康档案创建成功"
            self.showingSuccessAlert = true

            // 重新加载相关数据
            await loadWeightTrend()
            await loadRiskAssessment()

            isLoading = false
        } catch let apiError as APIError {
            isLoading = false

            // 如果是409冲突错误（用户已有健康档案），重新加载数据
            switch apiError {
            case .serverError(409):
                print("[HealthManagementViewModel] 用户已有健康档案（serverError），重新加载数据")
                self.showingCreateForm = false
                await loadData()
            case .businessError(let message, let code):
                if code == "Conflict" {
                    print("[HealthManagementViewModel] 用户已有健康档案（businessError），重新加载数据")
                    self.showingCreateForm = false
                    await loadData()
                } else {
                    self.error = message
                }
            default:
                self.error = handleError(apiError)
            }
        } catch {
            isLoading = false
            self.error = error.localizedDescription
        }
    }

    // 更新健康档案
    @MainActor
    public func updateHealthProfile() async {
        guard validateUpdateForm() else { return }

        isLoading = true
        error = nil

        do {
            // 将字符串转换为可选的Double
            let heightValue: Double? = height.isEmpty ? nil : Double(height)
            let prePregnancyWeightValue: Double? = prePregnancyWeight.isEmpty ? nil : Double(prePregnancyWeight)
            let currentWeightValue: Double? = currentWeight.isEmpty ? nil : Double(currentWeight)

            let request = UpdateHealthProfileRequest(
                height: heightValue,
                prePregnancyWeight: prePregnancyWeightValue,
                currentWeight: currentWeightValue,
                bloodType: bloodType.rawValue,
                medicalHistory: medicalHistory.isEmpty ? nil : medicalHistory,
                familyHistory: familyHistory.isEmpty ? nil : familyHistory,
                allergiesHistory: allergiesHistory.isEmpty ? nil : allergiesHistory,
                obstetricHistory: obstetricHistory.isEmpty ? nil : obstetricHistory,
                isSmoking: isSmoking,
                isDrinking: isDrinking
            )

            let profile = try await HealthProfileService.shared.updateHealthProfile(request: request)
            self.healthProfile = profile
            self.showingUpdateForm = false
            self.successMessage = "健康档案更新成功"
            self.showingSuccessAlert = true

            // 重新加载相关数据
            await loadWeightTrend()
            await loadRiskAssessment()

            isLoading = false
        } catch let apiError as APIError {
            isLoading = false
            self.error = handleError(apiError)
        } catch {
            isLoading = false
            self.error = error.localizedDescription
        }
    }

    // 记录每日体重
    @MainActor
    public func recordDailyWeight() async {
        guard let weightValue = Double(currentWeight), weightValue >= 30, weightValue <= 200 else {
            self.error = "请输入有效的体重（30-200千克）"
            return
        }

        isRecordingWeight = true
        error = nil

        do {
            // 创建体重记录请求
            let request = CreateWeightRecordRequest(
                weight: weightValue,
                recordDate: Date(), // 记录今天的体重
                note: "每日体重记录"
            )

            _ = try await HealthProfileService.shared.createWeightRecord(request: request)
            self.showingWeightForm = false
            self.successMessage = "体重记录成功"
            self.showingSuccessAlert = true

            // 只重新加载健康档案和体重趋势，不重新加载风险评估
            await loadHealthProfileAndWeightTrend()

            isRecordingWeight = false
        } catch let apiError as APIError {
            isRecordingWeight = false
            self.error = handleError(apiError)
        } catch {
            isRecordingWeight = false
            self.error = error.localizedDescription
        }
    }

    // 更新当前体重
    @MainActor
    public func updateCurrentWeight() async {
        guard let weightValue = Double(currentWeight), weightValue >= 30, weightValue <= 200 else {
            self.error = "请输入有效的体重（30-200千克）"
            return
        }

        isLoading = true
        error = nil

        do {
            // 创建一个只包含当前体重的更新请求
            let request = UpdateHealthProfileRequest(
                height: nil,
                prePregnancyWeight: nil,
                currentWeight: weightValue,
                bloodType: nil,
                medicalHistory: nil,
                familyHistory: nil,
                allergiesHistory: nil,
                obstetricHistory: nil,
                isSmoking: nil,
                isDrinking: nil
            )

            let profile = try await HealthProfileService.shared.updateHealthProfile(request: request)
            self.healthProfile = profile
            self.showingWeightForm = false
            self.successMessage = "体重记录成功"
            self.showingSuccessAlert = true

            // 重新加载相关数据
            await loadWeightTrend()
            await loadRiskAssessment()

            isLoading = false
        } catch let apiError as APIError {
            isLoading = false
            self.error = handleError(apiError)
        } catch {
            isLoading = false
            self.error = error.localizedDescription
        }
    }

    // 填充表单数据
    public func fillFormData(with profile: HealthProfile) {
        self.height = String(format: "%.1f", profile.height)
        self.prePregnancyWeight = String(format: "%.1f", profile.prePregnancyWeight)
        self.currentWeight = String(format: "%.1f", profile.currentWeight)

        // 尝试将字符串转换为BloodType枚举
        if let bloodTypeEnum = BloodType(rawValue: profile.bloodType) {
            self.bloodType = bloodTypeEnum
        }

        self.age = String(profile.age)
        self.medicalHistory = profile.medicalHistory ?? ""
        self.familyHistory = profile.familyHistory ?? ""
        self.allergiesHistory = profile.allergiesHistory ?? ""
        self.obstetricHistory = profile.obstetricHistory ?? ""
        self.isSmoking = profile.isSmoking
        self.isDrinking = profile.isDrinking
    }

    // 验证表单
    public func validateForm() -> Bool {
        // 验证身高
        guard let heightValue = Double(height), heightValue >= 100, heightValue <= 250 else {
            self.error = "请输入有效的身高（100-250厘米）"
            return false
        }

        // 验证孕前体重
        guard let preWeightValue = Double(prePregnancyWeight), preWeightValue >= 30, preWeightValue <= 200 else {
            self.error = "请输入有效的孕前体重（30-200千克）"
            return false
        }

        // 验证当前体重
        guard let currentWeightValue = Double(currentWeight), currentWeightValue >= 30, currentWeightValue <= 200 else {
            self.error = "请输入有效的当前体重（30-200千克）"
            return false
        }

        // 验证年龄
        guard let ageValue = Int(age), ageValue >= 18, ageValue <= 60 else {
            self.error = "请输入有效的年龄（18-60岁）"
            return false
        }

        return true
    }

    // 验证更新表单
    public func validateUpdateForm() -> Bool {
        // 验证身高（如果有）
        if !height.isEmpty {
            guard let heightValue = Double(height), heightValue >= 100, heightValue <= 250 else {
                self.error = "请输入有效的身高（100-250厘米）"
                return false
            }
        }

        // 验证孕前体重（如果有）
        if !prePregnancyWeight.isEmpty {
            guard let preWeightValue = Double(prePregnancyWeight), preWeightValue >= 30, preWeightValue <= 200 else {
                self.error = "请输入有效的孕前体重（30-200千克）"
                return false
            }
        }

        // 验证当前体重（如果有）
        if !currentWeight.isEmpty {
            guard let currentWeightValue = Double(currentWeight), currentWeightValue >= 30, currentWeightValue <= 200 else {
                self.error = "请输入有效的当前体重（30-200千克）"
                return false
            }
        }

        return true
    }

    // 处理API错误
    public func handleError(_ error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "无效的请求地址"
        case .invalidResponse:
            return "服务器响应无效"
        case .invalidData:
            return "数据格式错误"
        case .requestFailed(let err):
            return "网络请求失败: \(err.localizedDescription)"
        case .serverError(let statusCode):
            if statusCode == 409 {
                return "您已有健康档案，正在为您加载..."
            }
            return "服务器错误 (状态码: \(statusCode))"
        case .decodingError(let err):
            return "数据解析失败: \(err.localizedDescription)"
        case .encodingError(_):
            return "请求数据编码失败"
        case .businessError(let message, _):
            return message
        case .unauthorized:
            return "认证失败，请重新登录"
        case .notFound:
            return "健康档案不存在，请先创建"
        case .badRequest(let message):
            return message
        case .unknown:
            return "未知错误"
        }
    }
}
