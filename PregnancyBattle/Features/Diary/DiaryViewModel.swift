import Foundation
import SwiftUI

/// 日记视图模型
/// 负责管理日记相关的业务逻辑和状态
@MainActor
class DiaryViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 日记列表
    @Published var diaries: [Diary] = []

    /// 当前选中的日记
    @Published var selectedDiary: Diary?

    /// 加载状态
    @Published var isLoading = false

    /// 错误信息
    @Published var error: String?

    /// 是否显示创建日记视图
    @Published var showingCreateDiary = false

    /// 是否显示日记详情
    @Published var showingDiaryDetail = false

    /// 分页信息
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var totalCount = 0
    @Published var hasMorePages = false

    /// 筛选和排序选项
    @Published var selectedMoodFilter: MoodType?
    @Published var selectedTagFilters: Set<String> = []
    @Published var startDateFilter: Date?
    @Published var endDateFilter: Date?
    @Published var sortBy: String = "diaryDate"
    @Published var sortDirection: String = "desc"

    /// 用户所有可用标签（用于筛选面板显示）
    @Published var availableTags: [String] = []

    // MARK: - Private Properties

    /// 防止重复请求的标志
    private var isRequestInProgress = false

    /// 当前请求的Task，用于取消重复请求
    private var currentLoadTask: Task<Void, Never>?

    // MARK: - Constants

    private let pageSize = 10

    // MARK: - Initialization

    init() {
        // 延迟加载，避免初始化时的重复请求
        Task {
            // 添加小延迟，确保视图完全初始化
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            await loadDiariesSafely()
            await loadAvailableTags()
        }
    }

    // MARK: - Public Methods

    /// 安全加载日记列表（带防重复机制）
    func loadDiariesSafely(page: Int = 1, clearExisting: Bool = true) async {
        // 防止重复请求
        guard !isRequestInProgress else {
            print("[DiaryViewModel] 请求正在进行中，跳过重复请求")
            return
        }

        // 取消之前的请求
        currentLoadTask?.cancel()

        // 创建新的请求任务
        currentLoadTask = Task {
            await loadDiaries(page: page, clearExisting: clearExisting)
        }

        await currentLoadTask?.value
    }

    /// 加载日记列表（内部方法）
    private func loadDiaries(page: Int = 1, clearExisting: Bool = true) async {
        // 设置请求进行中标志
        isRequestInProgress = true
        isLoading = true
        error = nil

        if clearExisting {
            diaries = []
            currentPage = 1
        }

        do {
            let pagedResult: PagedDiaryList

            // 检查是否有任何筛选条件
            let hasFilters = selectedMoodFilter != nil || !selectedTagFilters.isEmpty ||
                           startDateFilter != nil || endDateFilter != nil

            if hasFilters {
                // 使用多条件筛选API
                pagedResult = try await DiaryService.shared.getDiariesByMultipleFilters(
                    mood: selectedMoodFilter,
                    tags: selectedTagFilters.isEmpty ? nil : Array(selectedTagFilters),
                    startDate: startDateFilter,
                    endDate: endDateFilter,
                    page: page,
                    pageSize: pageSize,
                    sortBy: sortBy,
                    sortDirection: sortDirection
                )
            } else {
                // 没有筛选条件，获取所有日记
                pagedResult = try await DiaryService.shared.getUserDiaries(
                    page: page,
                    pageSize: pageSize,
                    sortBy: sortBy,
                    sortDirection: sortDirection
                )
            }

            // 更新数据
            if clearExisting {
                diaries = pagedResult.items
            } else {
                // 去重处理：只添加不存在的日记
                let existingIds = Set(diaries.map { $0.id })
                let newDiaries = pagedResult.items.filter { !existingIds.contains($0.id) }
                diaries.append(contentsOf: newDiaries)
                print("[DiaryViewModel] 去重后添加 \(newDiaries.count) 条新日记，跳过 \(pagedResult.items.count - newDiaries.count) 条重复日记")
            }

            currentPage = pagedResult.currentPage
            totalPages = pagedResult.pageCount
            totalCount = pagedResult.totalCount
            hasMorePages = currentPage < totalPages

            print("[DiaryViewModel] 成功加载日记列表: \(pagedResult.items.count) 条记录")

        } catch {
            // 检查是否是取消错误
            if Task.isCancelled || error is CancellationError {
                print("[DiaryViewModel] 请求被取消")
                return
            }

            // 检查是否是URLError的取消错误
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("[DiaryViewModel] URLSession请求被取消")
                return
            }

            // 检查是否是认证错误
            if let apiError = error as? APIError, case .unauthorized = apiError {
                self.error = "登录已过期，请重新登录"
                print("[DiaryViewModel] 认证失败，用户需要重新登录")
            } else {
                self.error = "加载日记失败: \(error.localizedDescription)"
                print("[DiaryViewModel] 加载日记失败: \(error)")
            }
        }

        // 重置状态标志
        isLoading = false
        isRequestInProgress = false
    }

    /// 加载更多日记（分页加载）
    func loadMoreDiaries() async {
        guard hasMorePages && !isLoading && !isRequestInProgress else { return }
        await loadDiariesSafely(page: currentPage + 1, clearExisting: false)
    }

    /// 刷新日记列表
    func refreshDiaries() async {
        await loadDiariesSafely(page: 1, clearExisting: true)
    }

    /// 初始加载日记列表（供视图调用）
    func initialLoad() async {
        // 如果已经有数据或正在加载，则跳过
        guard diaries.isEmpty && !isLoading && !isRequestInProgress else {
            print("[DiaryViewModel] 跳过初始加载：已有数据或正在加载")
            return
        }

        await loadDiariesSafely(page: 1, clearExisting: true)
    }

    /// 创建新日记
    func createDiary(request: CreateDiaryRequest) async {
        isLoading = true
        error = nil

        do {
            let newDiary = try await DiaryService.shared.createDiary(request: request)

            // 将新日记添加到列表顶部
            diaries.insert(newDiary, at: 0)
            totalCount += 1

            showingCreateDiary = false
            print("[DiaryViewModel] 成功创建日记: \(newDiary.title)")

        } catch {
            self.error = "创建日记失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 创建日记失败: \(error)")
        }

        isLoading = false
    }

    /// 获取指定日记详情
    func loadDiaryDetail(diaryId: UUID) async {
        isLoading = true
        error = nil

        do {
            let diary = try await DiaryService.shared.getDiary(diaryId: diaryId)
            selectedDiary = diary
            showingDiaryDetail = true
            print("[DiaryViewModel] 成功加载日记详情: \(diary.title)")

        } catch {
            self.error = "加载日记详情失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 加载日记详情失败: \(error)")
        }

        isLoading = false
    }

    /// 更新日记
    func updateDiary(diaryId: UUID, request: UpdateDiaryRequest) async {
        isLoading = true
        error = nil

        do {
            let updatedDiary = try await DiaryService.shared.updateDiary(diaryId: diaryId, request: request)

            // 更新列表中的日记
            if let index = diaries.firstIndex(where: { $0.id == diaryId }) {
                diaries[index] = updatedDiary
            }

            // 更新选中的日记
            if selectedDiary?.id == diaryId {
                selectedDiary = updatedDiary
            }

            print("[DiaryViewModel] 成功更新日记: \(updatedDiary.title)")

        } catch {
            self.error = "更新日记失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 更新日记失败: \(error)")
        }

        isLoading = false
    }

    /// 删除日记
    func deleteDiary(diaryId: UUID) async {
        isLoading = true
        error = nil

        do {
            try await DiaryService.shared.deleteDiary(diaryId: diaryId)

            // 从列表中移除日记
            diaries.removeAll { $0.id == diaryId }
            totalCount = max(0, totalCount - 1)

            // 如果删除的是当前选中的日记，清空选中状态
            if selectedDiary?.id == diaryId {
                selectedDiary = nil
                showingDiaryDetail = false
            }

            print("[DiaryViewModel] 成功删除日记")

        } catch {
            self.error = "删除日记失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 删除日记失败: \(error)")
        }

        isLoading = false
    }

    // MARK: - Filter Methods

    /// 设置情绪筛选
    func setMoodFilter(_ mood: MoodType?) async {
        selectedMoodFilter = mood
        await refreshDiaries()
    }

    /// 设置标签筛选（多选）
    func setTagFilters(_ tags: Set<String>) async {
        selectedTagFilters = tags
        await refreshDiaries()
    }

    /// 添加标签筛选
    func addTagFilter(_ tag: String) async {
        selectedTagFilters.insert(tag)
        await refreshDiaries()
    }

    /// 移除标签筛选
    func removeTagFilter(_ tag: String) async {
        selectedTagFilters.remove(tag)
        await refreshDiaries()
    }

    /// 切换标签筛选状态
    func toggleTagFilter(_ tag: String) async {
        if selectedTagFilters.contains(tag) {
            selectedTagFilters.remove(tag)
        } else {
            selectedTagFilters.insert(tag)
        }
        await refreshDiaries()
    }

    /// 设置日期范围筛选
    func setDateRangeFilter(startDate: Date?, endDate: Date?) async {
        startDateFilter = startDate
        endDateFilter = endDate
        await refreshDiaries()
    }

    /// 设置多个筛选条件
    func setMultipleFilters(mood: MoodType?, tags: Set<String>?, startDate: Date?, endDate: Date?) async {
        selectedMoodFilter = mood
        selectedTagFilters = tags ?? []
        startDateFilter = startDate
        endDateFilter = endDate
        await refreshDiaries()
    }

    /// 清除所有筛选
    func clearFilters() async {
        selectedMoodFilter = nil
        selectedTagFilters.removeAll()
        startDateFilter = nil
        endDateFilter = nil
        await refreshDiaries()
    }

    /// 设置排序方式
    func setSorting(sortBy: String, sortDirection: String) async {
        self.sortBy = sortBy
        self.sortDirection = sortDirection
        await refreshDiaries()
    }

    // MARK: - Helper Methods

    /// 清除错误信息
    func clearError() {
        error = nil
    }

    /// 获取所有标签（用于筛选面板显示）
    var allTags: [String] {
        return availableTags
    }

    /// 获取情绪统计
    var moodStatistics: [MoodType: Int] {
        var stats: [MoodType: Int] = [:]
        for diary in diaries {
            if let mood = diary.mood {
                stats[mood, default: 0] += 1
            }
        }
        return stats
    }



    // MARK: - 标签管理

    /// 添加日记标签
    func addDiaryTags(diaryId: UUID, tags: [String]) async {
        isLoading = true
        error = nil

        do {
            let response = try await DiaryService.shared.addDiaryTags(diaryId: diaryId, tags: tags)

            // 更新列表中的日记标签
            if let index = diaries.firstIndex(where: { $0.id == diaryId }) {
                let updatedDiary = diaries[index]
                // 创建新的日记对象，更新标签
                diaries[index] = Diary(
                    id: updatedDiary.id,
                    userId: updatedDiary.userId,
                    title: updatedDiary.title,
                    content: updatedDiary.content,
                    mood: updatedDiary.mood,
                    diaryDate: updatedDiary.diaryDate,
                    pregnancyWeek: updatedDiary.pregnancyWeek,
                    pregnancyDay: updatedDiary.pregnancyDay,
                    createdAt: updatedDiary.createdAt,
                    updatedAt: updatedDiary.updatedAt,
                    tags: response.tags,
                    mediaFiles: updatedDiary.mediaFiles
                )
            }

            // 如果当前选中的是这个日记，也要更新
            if let selectedDiary = selectedDiary, selectedDiary.id == diaryId {
                self.selectedDiary = Diary(
                    id: selectedDiary.id,
                    userId: selectedDiary.userId,
                    title: selectedDiary.title,
                    content: selectedDiary.content,
                    mood: selectedDiary.mood,
                    diaryDate: selectedDiary.diaryDate,
                    pregnancyWeek: selectedDiary.pregnancyWeek,
                    pregnancyDay: selectedDiary.pregnancyDay,
                    createdAt: selectedDiary.createdAt,
                    updatedAt: selectedDiary.updatedAt,
                    tags: response.tags,
                    mediaFiles: selectedDiary.mediaFiles
                )
            }

            print("[DiaryViewModel] 成功添加标签: \(tags.joined(separator: ", "))")

            // 重新加载可用标签列表
            await loadAvailableTags()

        } catch {
            self.error = "添加标签失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 添加标签失败: \(error)")
            
            // 提供更详细的错误信息
            if let apiError = error as? APIError {
                switch apiError {
                case .requestFailed(let urlError):
                    if let urlError = urlError as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            self.error = "网络连接失败，请检查网络设置"
                        case .timedOut:
                            self.error = "请求超时，请重试"
                        case .networkConnectionLost:
                            self.error = "网络连接中断，请重试"
                        default:
                            self.error = "网络请求失败: \(urlError.localizedDescription)"
                        }
                    } else {
                        self.error = "添加标签失败: \(error.localizedDescription)"
                    }
                case .businessError(let message, _):
                    self.error = message
                case .unauthorized:
                    self.error = "登录已过期，请重新登录"
                default:
                    self.error = "添加标签失败: \(error.localizedDescription)"
                }
            }
        }

        isLoading = false
    }

    /// 删除日记标签
    func deleteDiaryTag(diaryId: UUID, tag: String) async {
        isLoading = true
        error = nil

        do {
            let response = try await DiaryService.shared.deleteDiaryTag(diaryId: diaryId, tag: tag)

            // 更新列表中的日记标签
            if let index = diaries.firstIndex(where: { $0.id == diaryId }) {
                let updatedDiary = diaries[index]
                diaries[index] = Diary(
                    id: updatedDiary.id,
                    userId: updatedDiary.userId,
                    title: updatedDiary.title,
                    content: updatedDiary.content,
                    mood: updatedDiary.mood,
                    diaryDate: updatedDiary.diaryDate,
                    pregnancyWeek: updatedDiary.pregnancyWeek,
                    pregnancyDay: updatedDiary.pregnancyDay,
                    createdAt: updatedDiary.createdAt,
                    updatedAt: updatedDiary.updatedAt,
                    tags: response.tags,
                    mediaFiles: updatedDiary.mediaFiles
                )
            }

            // 如果当前选中的是这个日记，也要更新
            if let selectedDiary = selectedDiary, selectedDiary.id == diaryId {
                self.selectedDiary = Diary(
                    id: selectedDiary.id,
                    userId: selectedDiary.userId,
                    title: selectedDiary.title,
                    content: selectedDiary.content,
                    mood: selectedDiary.mood,
                    diaryDate: selectedDiary.diaryDate,
                    pregnancyWeek: selectedDiary.pregnancyWeek,
                    pregnancyDay: selectedDiary.pregnancyDay,
                    createdAt: selectedDiary.createdAt,
                    updatedAt: selectedDiary.updatedAt,
                    tags: response.tags,
                    mediaFiles: selectedDiary.mediaFiles
                )
            }

            print("[DiaryViewModel] 成功删除标签: \(tag)")

            // 重新加载可用标签列表
            await loadAvailableTags()

        } catch {
            self.error = "删除标签失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 删除标签失败: \(error)")
        }

        isLoading = false
    }

    // MARK: - 媒体文件管理

    /// 添加日记媒体文件
    func addDiaryMedia(diaryId: UUID, request: AddDiaryMediaRequest) async {
        isLoading = true
        error = nil

        do {
            let newMedia = try await DiaryService.shared.addDiaryMedia(diaryId: diaryId, request: request)

            // 更新列表中的日记媒体文件
            if let index = diaries.firstIndex(where: { $0.id == diaryId }) {
                let updatedDiary = diaries[index]
                var updatedMediaFiles = updatedDiary.mediaFiles
                updatedMediaFiles.append(newMedia)

                diaries[index] = Diary(
                    id: updatedDiary.id,
                    userId: updatedDiary.userId,
                    title: updatedDiary.title,
                    content: updatedDiary.content,
                    mood: updatedDiary.mood,
                    diaryDate: updatedDiary.diaryDate,
                    pregnancyWeek: updatedDiary.pregnancyWeek,
                    pregnancyDay: updatedDiary.pregnancyDay,
                    createdAt: updatedDiary.createdAt,
                    updatedAt: updatedDiary.updatedAt,
                    tags: updatedDiary.tags,
                    mediaFiles: updatedMediaFiles
                )
            }

            // 如果当前选中的是这个日记，也要更新
            if let selectedDiary = selectedDiary, selectedDiary.id == diaryId {
                var updatedMediaFiles = selectedDiary.mediaFiles
                updatedMediaFiles.append(newMedia)

                self.selectedDiary = Diary(
                    id: selectedDiary.id,
                    userId: selectedDiary.userId,
                    title: selectedDiary.title,
                    content: selectedDiary.content,
                    mood: selectedDiary.mood,
                    diaryDate: selectedDiary.diaryDate,
                    pregnancyWeek: selectedDiary.pregnancyWeek,
                    pregnancyDay: selectedDiary.pregnancyDay,
                    createdAt: selectedDiary.createdAt,
                    updatedAt: selectedDiary.updatedAt,
                    tags: selectedDiary.tags,
                    mediaFiles: updatedMediaFiles
                )
            }

            print("[DiaryViewModel] 成功添加媒体文件: \(newMedia.mediaType.rawValue)")

        } catch {
            self.error = "添加媒体文件失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 添加媒体文件失败: \(error)")
        }

        isLoading = false
    }

    /// 删除日记媒体文件
    func deleteDiaryMedia(diaryId: UUID, mediaId: UUID) async {
        isLoading = true
        error = nil

        do {
            try await DiaryService.shared.deleteDiaryMedia(diaryId: diaryId, mediaId: mediaId)

            // 更新列表中的日记媒体文件
            if let index = diaries.firstIndex(where: { $0.id == diaryId }) {
                let updatedDiary = diaries[index]
                let updatedMediaFiles = updatedDiary.mediaFiles.filter { $0.id != mediaId }

                diaries[index] = Diary(
                    id: updatedDiary.id,
                    userId: updatedDiary.userId,
                    title: updatedDiary.title,
                    content: updatedDiary.content,
                    mood: updatedDiary.mood,
                    diaryDate: updatedDiary.diaryDate,
                    pregnancyWeek: updatedDiary.pregnancyWeek,
                    pregnancyDay: updatedDiary.pregnancyDay,
                    createdAt: updatedDiary.createdAt,
                    updatedAt: updatedDiary.updatedAt,
                    tags: updatedDiary.tags,
                    mediaFiles: updatedMediaFiles
                )
            }

            // 如果当前选中的是这个日记，也要更新
            if let selectedDiary = selectedDiary, selectedDiary.id == diaryId {
                let updatedMediaFiles = selectedDiary.mediaFiles.filter { $0.id != mediaId }

                self.selectedDiary = Diary(
                    id: selectedDiary.id,
                    userId: selectedDiary.userId,
                    title: selectedDiary.title,
                    content: selectedDiary.content,
                    mood: selectedDiary.mood,
                    diaryDate: selectedDiary.diaryDate,
                    pregnancyWeek: selectedDiary.pregnancyWeek,
                    pregnancyDay: selectedDiary.pregnancyDay,
                    createdAt: selectedDiary.createdAt,
                    updatedAt: selectedDiary.updatedAt,
                    tags: selectedDiary.tags,
                    mediaFiles: updatedMediaFiles
                )
            }

            print("[DiaryViewModel] 成功删除媒体文件")

        } catch {
            self.error = "删除媒体文件失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 删除媒体文件失败: \(error)")
        }

        isLoading = false
    }

    /// 直接上传媒体文件到日记
    func uploadDiaryMedia(diaryId: UUID, mediaFile: MediaFile, description: String? = nil) async {
        isLoading = true
        error = nil

        do {
            let newMedia = try await DiaryService.shared.uploadDiaryMedia(diaryId: diaryId, mediaFile: mediaFile, description: description)

            // 更新列表中的日记媒体文件
            if let index = diaries.firstIndex(where: { $0.id == diaryId }) {
                let updatedDiary = diaries[index]
                var updatedMediaFiles = updatedDiary.mediaFiles
                updatedMediaFiles.append(newMedia)

                diaries[index] = Diary(
                    id: updatedDiary.id,
                    userId: updatedDiary.userId,
                    title: updatedDiary.title,
                    content: updatedDiary.content,
                    mood: updatedDiary.mood,
                    diaryDate: updatedDiary.diaryDate,
                    pregnancyWeek: updatedDiary.pregnancyWeek,
                    pregnancyDay: updatedDiary.pregnancyDay,
                    createdAt: updatedDiary.createdAt,
                    updatedAt: updatedDiary.updatedAt,
                    tags: updatedDiary.tags,
                    mediaFiles: updatedMediaFiles
                )
            }

            // 如果当前选中的是这个日记，也要更新
            if let selectedDiary = selectedDiary, selectedDiary.id == diaryId {
                var updatedMediaFiles = selectedDiary.mediaFiles
                updatedMediaFiles.append(newMedia)

                self.selectedDiary = Diary(
                    id: selectedDiary.id,
                    userId: selectedDiary.userId,
                    title: selectedDiary.title,
                    content: selectedDiary.content,
                    mood: selectedDiary.mood,
                    diaryDate: selectedDiary.diaryDate,
                    pregnancyWeek: selectedDiary.pregnancyWeek,
                    pregnancyDay: selectedDiary.pregnancyDay,
                    createdAt: selectedDiary.createdAt,
                    updatedAt: selectedDiary.updatedAt,
                    tags: selectedDiary.tags,
                    mediaFiles: updatedMediaFiles
                )
            }

            print("[DiaryViewModel] 成功上传媒体文件: \(newMedia.mediaType.rawValue)")

        } catch {
            self.error = "上传媒体文件失败: \(error.localizedDescription)"
            print("[DiaryViewModel] 上传媒体文件失败: \(error)")
            
            // 提供更详细的错误信息
            if let apiError = error as? APIError {
                switch apiError {
                case .requestFailed(let urlError):
                    if let urlError = urlError as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet:
                            self.error = "网络连接失败，请检查网络设置"
                        case .timedOut:
                            self.error = "文件上传超时，请重试"
                        case .networkConnectionLost:
                            self.error = "网络连接中断，请重试"
                        default:
                            self.error = "网络请求失败: \(urlError.localizedDescription)"
                        }
                    } else {
                        self.error = "上传媒体文件失败: \(error.localizedDescription)"
                    }
                case .businessError(let message, _):
                    self.error = message
                case .unauthorized:
                    self.error = "登录已过期，请重新登录"
                default:
                    self.error = "上传媒体文件失败: \(error.localizedDescription)"
                }
            }
        }

        isLoading = false
    }

    // MARK: - 标签管理

    /// 加载用户所有可用标签
    func loadAvailableTags() async {
        do {
            let tags = try await DiaryService.shared.getUserTags()
            await MainActor.run {
                self.availableTags = tags
            }
            print("[DiaryViewModel] 成功加载用户标签: \(tags.count)个")
        } catch {
            print("[DiaryViewModel] 加载用户标签失败: \(error)")

            // 检查是否是认证错误
            if let apiError = error as? APIError, case .unauthorized = apiError {
                await MainActor.run {
                    self.error = "登录已过期，请重新登录"
                }
                print("[DiaryViewModel] 标签加载认证失败，用户需要重新登录")
            }
            // 其他错误不影响主要功能，所以不设置error
        }
    }
}
