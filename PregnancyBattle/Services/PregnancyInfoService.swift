import Foundation

class PregnancyInfoService {
    static let shared = PregnancyInfoService()

    private init() {}

    // 创建孕期信息
    func createPregnancyInfo(request: CreatePregnancyInfoRequest) async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "pregnancy-info", // 使用统一的小写连字符命名规范
            method: "POST",
            body: request
        )
    }

    // 获取孕期信息
    func getPregnancyInfo() async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "pregnancy-info", // 使用统一的小写连字符命名规范
            method: "GET"
        )
    }

    // 更新孕期信息
    func updatePregnancyInfo(request: UpdatePregnancyInfoRequest) async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "pregnancy-info", // 使用统一的小写连字符命名规范
            method: "PUT",
            body: request
        )
    }

    // 计算当前孕周和孕天
    func getCurrentWeekAndDay() async throws -> PregnancyInfo {
        return try await APIService.shared.request(
            endpoint: "pregnancy-info/current-week", // 使用统一的小写连字符命名规范
            method: "GET"
        )
    }
}