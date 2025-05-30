import Foundation

class HealthProfileService {
    static let shared = HealthProfileService()

    private init() {}

    // 创建健康档案
    func createHealthProfile(request: CreateHealthProfileRequest) async throws -> HealthProfile {
        return try await APIService.shared.request(
            endpoint: "health-profiles",
            method: "POST",
            body: request
        )
    }

    // 获取健康档案
    func getHealthProfile() async throws -> HealthProfile {
        return try await APIService.shared.request(
            endpoint: "health-profiles",
            method: "GET"
        )
    }

    // 更新健康档案
    func updateHealthProfile(request: UpdateHealthProfileRequest) async throws -> HealthProfile {
        return try await APIService.shared.request(
            endpoint: "health-profiles",
            method: "PUT",
            body: request
        )
    }

    // 记录每日体重
    func createWeightRecord(request: CreateWeightRecordRequest) async throws -> WeightRecordResponse {
        return try await APIService.shared.request(
            endpoint: "health-profiles/weight-records",
            method: "POST",
            body: request
        )
    }

    // 获取体重变化趋势
    func getWeightTrend() async throws -> WeightTrend {
        return try await APIService.shared.request(
            endpoint: "health-profiles/weight-trend",
            method: "GET"
        )
    }

    // 获取健康风险评估
    func getRiskAssessment() async throws -> RiskAssessment {
        return try await APIService.shared.request(
            endpoint: "health-profiles/risk-assessment",
            method: "GET"
        )
    }
}
