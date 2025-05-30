import Foundation

/// 日记API测试类
/// 用于测试日记相关API接口的对接情况
class DiaryAPITests {
    
    static let shared = DiaryAPITests()
    private init() {}
    
    /// 测试创建日记API
    func testCreateDiary() async {
        print("=== 测试创建日记API ===")
        
        let request = CreateDiaryRequest(
            title: "测试日记",
            content: "这是一篇测试日记，用于验证API接口是否正常工作。今天感觉很好，宝宝很活跃。",
            mood: .happy,
            diaryDate: Date(),
            tags: ["测试", "API", "开心"],
            mediaFiles: []
        )
        
        do {
            let diary = try await DiaryService.shared.createDiary(request: request)
            print("✅ 创建日记成功:")
            print("   ID: \(diary.id)")
            print("   标题: \(diary.title)")
            print("   内容: \(diary.content)")
            print("   情绪: \(diary.mood?.displayName ?? "无")")
            print("   标签: \(diary.tags.joined(separator: ", "))")
            print("   孕周: \(diary.pregnancyWeek ?? 0)周\(diary.pregnancyDay ?? 0)天")
            
            // 测试获取日记详情
            await testGetDiary(diaryId: diary.id)
            
        } catch {
            print("❌ 创建日记失败: \(error)")
        }
    }
    
    /// 测试获取日记详情API
    func testGetDiary(diaryId: UUID) async {
        print("\n=== 测试获取日记详情API ===")
        
        do {
            let diary = try await DiaryService.shared.getDiary(diaryId: diaryId)
            print("✅ 获取日记详情成功:")
            print("   ID: \(diary.id)")
            print("   标题: \(diary.title)")
            print("   创建时间: \(diary.createdAt)")
            print("   更新时间: \(diary.updatedAt)")
            
        } catch {
            print("❌ 获取日记详情失败: \(error)")
        }
    }
    
    /// 测试获取用户所有日记API
    func testGetUserDiaries() async {
        print("\n=== 测试获取用户所有日记API ===")
        
        do {
            let pagedResult = try await DiaryService.shared.getUserDiaries(
                page: 1,
                pageSize: 10,
                sortBy: "diaryDate",
                sortDirection: "desc"
            )
            
            print("✅ 获取用户日记列表成功:")
            print("   总数量: \(pagedResult.totalCount)")
            print("   当前页: \(pagedResult.currentPage)")
            print("   总页数: \(pagedResult.pageCount)")
            print("   本页数量: \(pagedResult.items.count)")
            
            for (index, diary) in pagedResult.items.enumerated() {
                print("   [\(index + 1)] \(diary.title) - \(diary.mood?.displayName ?? "无情绪")")
            }
            
        } catch {
            print("❌ 获取用户日记列表失败: \(error)")
        }
    }
    
    /// 测试根据日期范围获取日记API
    func testGetDiariesByDateRange() async {
        print("\n=== 测试根据日期范围获取日记API ===")
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        do {
            let pagedResult = try await DiaryService.shared.getDiariesByDateRange(
                startDate: startDate,
                endDate: endDate,
                page: 1,
                pageSize: 10
            )
            
            print("✅ 根据日期范围获取日记成功:")
            print("   日期范围: \(formatDate(startDate)) 到 \(formatDate(endDate))")
            print("   找到日记数量: \(pagedResult.totalCount)")
            
            for diary in pagedResult.items {
                print("   - \(diary.title) (\(formatDate(diary.diaryDate)))")
            }
            
        } catch {
            print("❌ 根据日期范围获取日记失败: \(error)")
        }
    }
    
    /// 测试根据标签获取日记API
    func testGetDiariesByTag() async {
        print("\n=== 测试根据标签获取日记API ===")
        
        let testTag = "测试"
        
        do {
            let pagedResult = try await DiaryService.shared.getDiariesByTag(
                tag: testTag,
                page: 1,
                pageSize: 10
            )
            
            print("✅ 根据标签获取日记成功:")
            print("   标签: \(testTag)")
            print("   找到日记数量: \(pagedResult.totalCount)")
            
            for diary in pagedResult.items {
                print("   - \(diary.title) (标签: \(diary.tags.joined(separator: ", ")))")
            }
            
        } catch {
            print("❌ 根据标签获取日记失败: \(error)")
        }
    }
    
    /// 测试根据情绪获取日记API
    func testGetDiariesByMood() async {
        print("\n=== 测试根据情绪获取日记API ===")
        
        let testMood = MoodType.happy
        
        do {
            let pagedResult = try await DiaryService.shared.getDiariesByMood(
                mood: testMood,
                page: 1,
                pageSize: 10
            )
            
            print("✅ 根据情绪获取日记成功:")
            print("   情绪: \(testMood.displayName)")
            print("   找到日记数量: \(pagedResult.totalCount)")
            
            for diary in pagedResult.items {
                print("   - \(diary.title) (情绪: \(diary.mood?.displayName ?? "无"))")
            }
            
        } catch {
            print("❌ 根据情绪获取日记失败: \(error)")
        }
    }
    
    /// 运行所有测试
    func runAllTests() async {
        print("🚀 开始运行日记API测试...")
        print("测试账号：19991105，密码：123456")
        print("后端地址：http://localhost:5094")
        print("=" * 50)
        
        // 首先测试获取现有日记
        await testGetUserDiaries()
        
        // 测试创建新日记
        await testCreateDiary()
        
        // 测试日期范围筛选
        await testGetDiariesByDateRange()
        
        // 测试标签筛选
        await testGetDiariesByTag()
        
        // 测试情绪筛选
        await testGetDiariesByMood()
        
        print("\n" + "=" * 50)
        print("🏁 日记API测试完成")
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - 字符串重复扩展

extension String {
    static func * (string: String, count: Int) -> String {
        return String(repeating: string, count: count)
    }
}
