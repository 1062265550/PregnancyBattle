import Foundation

class PregnancyInfoService {
    static let shared = PregnancyInfoService()

    private init() {}

    // 创建孕期信息
    func createPregnancyInfo(request: CreatePregnancyInfoRequest) async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "PregnancyInfo",
            method: "POST",
            body: request
        )
    }

    // 获取孕期信息
    func getPregnancyInfo() async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "PregnancyInfo",
            method: "GET"
        )
    }

    // 更新孕期信息
    func updatePregnancyInfo(request: UpdatePregnancyInfoRequest) async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "PregnancyInfo",
            method: "PUT",
            body: request
        )
    }

    // 计算当前孕周和孕天
    func getCurrentWeekAndDay() async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "PregnancyInfo/current-week",
            method: "GET"
        )
    }
}