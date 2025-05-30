import SwiftUI

/// 日记API测试视图
/// 用于开发阶段测试日记API接口
struct DiaryTestView: View {
    @State private var testResults: [String] = []
    @State private var isRunningTests = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 测试说明
                VStack(alignment: .leading, spacing: 8) {
                    Text("日记API测试")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("此页面用于测试日记模块的API接口对接情况")
                        .font(.body)
                        .foregroundColor(.secondary)

                    Text("测试账号：19991105，密码：123456")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)

                // 测试按钮
                VStack(spacing: 12) {
                    Button(action: {
                        runAPITests()
                    }) {
                        HStack {
                            if isRunningTests {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "play.circle.fill")
                            }
                            Text(isRunningTests ? "测试中..." : "运行API测试")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isRunningTests)

                    Button(action: {
                        testResults.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("清除结果")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    .disabled(testResults.isEmpty)
                }
                .padding(.horizontal)

                // 测试结果
                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("测试结果")
                            .font(.headline)
                            .fontWeight(.semibold)

                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(testResults.enumerated()), id: \.offset) { index, result in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(index + 1).")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 20, alignment: .leading)

                                        Text(result)
                                            .font(.caption)
                                            .foregroundColor(result.contains("✅") ? .green :
                                                           result.contains("❌") ? .red : .primary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding()
                        }
                        .frame(maxHeight: 300)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("API测试")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - 测试方法

    private func runAPITests() {
        guard !isRunningTests else { return }

        isRunningTests = true
        testResults.removeAll()

        Task {
            await performTests()

            await MainActor.run {
                isRunningTests = false
            }
        }
    }

    private func performTests() async {
        addTestResult("🚀 开始运行日记API测试...")
        addTestResult("测试账号：19991105，密码：123456")
        addTestResult("后端地址：http://localhost:5094")
        addTestResult("=" * 50)

        // 测试1：获取用户所有日记
        addTestResult("\n=== 测试获取用户所有日记API ===")
        do {
            let pagedResult = try await DiaryService.shared.getUserDiaries(
                page: 1,
                pageSize: 5,
                sortBy: "diaryDate",
                sortDirection: "desc"
            )

            addTestResult("✅ 获取用户日记列表成功:")
            addTestResult("   总数量: \(pagedResult.totalCount)")
            addTestResult("   当前页: \(pagedResult.currentPage)")
            addTestResult("   总页数: \(pagedResult.pageCount)")
            addTestResult("   本页数量: \(pagedResult.items.count)")

            for (index, diary) in pagedResult.items.enumerated() {
                addTestResult("   [\(index + 1)] \(diary.title) - \(diary.mood?.displayName ?? "无情绪")")
            }

        } catch {
            addTestResult("❌ 获取用户日记列表失败: \(error)")
        }

        // 测试2：创建新日记
        addTestResult("\n=== 测试创建日记API ===")
        let request = CreateDiaryRequest(
            title: "API测试日记 \(Date().timeIntervalSince1970)",
            content: "这是一篇通过API测试创建的日记。创建时间：\(formatDateTime(Date()))",
            mood: .happy,
            diaryDate: Date(),
            tags: ["API测试", "自动创建"],
            mediaFiles: []
        )

        do {
            let diary = try await DiaryService.shared.createDiary(request: request)
            addTestResult("✅ 创建日记成功:")
            addTestResult("   ID: \(diary.id)")
            addTestResult("   标题: \(diary.title)")
            addTestResult("   情绪: \(diary.mood?.displayName ?? "无")")
            addTestResult("   标签: \(diary.tags.joined(separator: ", "))")

            // 测试获取刚创建的日记详情
            await testGetDiaryDetail(diaryId: diary.id)

        } catch {
            addTestResult("❌ 创建日记失败: \(error)")
        }

        // 测试新增的API接口
        await testNewAPIEndpoints()

        // 测试3：根据标签获取日记
        addTestResult("\n=== 测试根据标签获取日记API ===")
        do {
            let pagedResult = try await DiaryService.shared.getDiariesByTag(
                tag: "API测试",
                page: 1,
                pageSize: 5
            )

            addTestResult("✅ 根据标签获取日记成功:")
            addTestResult("   标签: API测试")
            addTestResult("   找到日记数量: \(pagedResult.totalCount)")

        } catch {
            addTestResult("❌ 根据标签获取日记失败: \(error)")
        }

        // 测试4：根据情绪获取日记
        addTestResult("\n=== 测试根据情绪获取日记API ===")
        do {
            let pagedResult = try await DiaryService.shared.getDiariesByMood(
                mood: .happy,
                page: 1,
                pageSize: 5
            )

            addTestResult("✅ 根据情绪获取日记成功:")
            addTestResult("   情绪: 开心")
            addTestResult("   找到日记数量: \(pagedResult.totalCount)")

        } catch {
            addTestResult("❌ 根据情绪获取日记失败: \(error)")
        }

        // 测试5：根据日期范围获取日记
        addTestResult("\n=== 测试根据日期范围获取日记API ===")
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate

        do {
            let pagedResult = try await DiaryService.shared.getDiariesByDateRange(
                startDate: startDate,
                endDate: endDate,
                page: 1,
                pageSize: 5
            )

            addTestResult("✅ 根据日期范围获取日记成功:")
            addTestResult("   日期范围: 最近7天")
            addTestResult("   找到日记数量: \(pagedResult.totalCount)")

        } catch {
            addTestResult("❌ 根据日期范围获取日记失败: \(error)")
        }

        addTestResult("\n" + "=" * 50)
        addTestResult("🏁 日记API测试完成")
    }

    private func testGetDiaryDetail(diaryId: UUID) async {
        addTestResult("\n--- 测试获取日记详情 ---")
        do {
            let diary = try await DiaryService.shared.getDiary(diaryId: diaryId)
            addTestResult("✅ 获取日记详情成功: \(diary.title)")

        } catch {
            addTestResult("❌ 获取日记详情失败: \(error)")
        }
    }

    // MARK: - Helper Methods

    private func addTestResult(_ result: String) {
        Task { @MainActor in
            testResults.append(result)
        }
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }

    // MARK: - 新增API接口测试

    private func testNewAPIEndpoints() async {
        addTestResult("\n=== 测试新增API接口 ===")

        // 首先获取一个现有的日记用于测试
        do {
            let pagedResult = try await DiaryService.shared.getUserDiaries(page: 1, pageSize: 1)

            if let testDiary = pagedResult.items.first {
                addTestResult("📝 使用日记进行测试: \(testDiary.title)")

                // 测试更新日记
                await testUpdateDiary(diaryId: testDiary.id)

                // 测试标签管理
                await testTagManagement(diaryId: testDiary.id)

                // 测试媒体文件管理
                await testMediaManagement(diaryId: testDiary.id)

                // 注意：删除日记测试放在最后，因为会删除测试数据
                // await testDeleteDiary(diaryId: testDiary.id)

            } else {
                addTestResult("⚠️ 没有找到可用于测试的日记，跳过新增API测试")
            }

        } catch {
            addTestResult("❌ 获取测试日记失败: \(error)")
        }
    }

    private func testUpdateDiary(diaryId: UUID) async {
        addTestResult("\n--- 测试更新日记API ---")

        let updateRequest = UpdateDiaryRequest(
            title: "更新后的标题 \(Date().timeIntervalSince1970)",
            content: "这是更新后的内容，测试时间：\(formatDateTime(Date()))",
            mood: .excited,
            diaryDate: Date()
        )

        do {
            let updatedDiary = try await DiaryService.shared.updateDiary(diaryId: diaryId, request: updateRequest)
            addTestResult("✅ 更新日记成功:")
            addTestResult("   新标题: \(updatedDiary.title)")
            addTestResult("   新情绪: \(updatedDiary.mood?.displayName ?? "无")")

        } catch {
            addTestResult("❌ 更新日记失败: \(error)")
        }
    }

    private func testTagManagement(diaryId: UUID) async {
        addTestResult("\n--- 测试标签管理API ---")

        // 测试添加标签
        do {
            let response = try await DiaryService.shared.addDiaryTags(
                diaryId: diaryId,
                tags: ["新标签1", "新标签2", "测试标签"]
            )
            addTestResult("✅ 添加标签成功:")
            addTestResult("   标签列表: \(response.tags.joined(separator: ", "))")

            // 测试删除标签
            let tagToDelete = "新标签1"
            let deleteResponse = try await DiaryService.shared.deleteDiaryTag(
                diaryId: diaryId,
                tag: tagToDelete
            )
            addTestResult("✅ 删除标签成功:")
            addTestResult("   删除标签: \(tagToDelete)")
            addTestResult("   剩余标签: \(deleteResponse.tags.joined(separator: ", "))")

        } catch {
            addTestResult("❌ 标签管理测试失败: \(error)")
        }
    }

    private func testMediaManagement(diaryId: UUID) async {
        addTestResult("\n--- 测试媒体文件管理API ---")

        // 测试添加多种类型的媒体文件
        let mediaRequests = [
            AddDiaryMediaRequest(
                mediaType: .image,
                mediaUrl: "https://example.com/test-image.jpg",
                description: "测试图片描述"
            ),
            AddDiaryMediaRequest(
                mediaType: .video,
                mediaUrl: "https://example.com/test-video.mp4",
                description: "测试视频描述"
            ),
            AddDiaryMediaRequest(
                mediaType: .audio,
                mediaUrl: "https://example.com/test-audio.mp3",
                description: "测试音频描述"
            )
        ]

        var addedMediaIds: [UUID] = []

        // 测试添加媒体文件
        for (index, mediaRequest) in mediaRequests.enumerated() {
            do {
                let newMedia = try await DiaryService.shared.addDiaryMedia(
                    diaryId: diaryId,
                    request: mediaRequest
                )
                addTestResult("✅ 添加媒体文件 \(index + 1) 成功:")
                addTestResult("   媒体ID: \(newMedia.id)")
                addTestResult("   媒体类型: \(newMedia.mediaType.displayName)")
                addTestResult("   媒体URL: \(newMedia.mediaUrl)")
                addTestResult("   描述: \(newMedia.description ?? "无")")
                addTestResult("   创建时间: \(formatDateTime(newMedia.createdAt ?? Date()))")

                addedMediaIds.append(newMedia.id)

            } catch {
                addTestResult("❌ 添加媒体文件 \(index + 1) 失败: \(error)")
            }
        }

        // 等待一秒，确保媒体文件已添加
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 重新获取日记详情，验证媒体文件是否已添加
        do {
            let updatedDiary = try await DiaryService.shared.getDiary(diaryId: diaryId)
            addTestResult("\n--- 验证媒体文件添加结果 ---")
            addTestResult("✅ 重新获取日记成功，媒体文件数量: \(updatedDiary.mediaFiles.count)")

            for (index, media) in updatedDiary.mediaFiles.enumerated() {
                addTestResult("   媒体文件 \(index + 1):")
                addTestResult("     ID: \(media.id)")
                addTestResult("     类型: \(media.mediaType.displayName)")
                addTestResult("     URL: \(media.mediaUrl)")
                addTestResult("     描述: \(media.description ?? "无")")
            }
        } catch {
            addTestResult("❌ 重新获取日记失败: \(error)")
        }

        // 测试删除媒体文件
        addTestResult("\n--- 测试删除媒体文件 ---")
        for (index, mediaId) in addedMediaIds.enumerated() {
            do {
                try await DiaryService.shared.deleteDiaryMedia(
                    diaryId: diaryId,
                    mediaId: mediaId
                )
                addTestResult("✅ 删除媒体文件 \(index + 1) 成功 (ID: \(mediaId))")

            } catch {
                addTestResult("❌ 删除媒体文件 \(index + 1) 失败: \(error)")
            }
        }

        // 再次验证删除结果
        do {
            let finalDiary = try await DiaryService.shared.getDiary(diaryId: diaryId)
            addTestResult("\n--- 验证媒体文件删除结果 ---")
            addTestResult("✅ 最终验证：日记媒体文件数量: \(finalDiary.mediaFiles.count)")

            if finalDiary.mediaFiles.isEmpty {
                addTestResult("✅ 所有媒体文件已成功删除")
            } else {
                addTestResult("⚠️ 仍有 \(finalDiary.mediaFiles.count) 个媒体文件未删除")
                for media in finalDiary.mediaFiles {
                    addTestResult("   剩余媒体文件: \(media.mediaType.displayName) - \(media.id)")
                }
            }
        } catch {
            addTestResult("❌ 最终验证失败: \(error)")
        }
    }

    private func testDeleteDiary(diaryId: UUID) async {
        addTestResult("\n--- 测试删除日记API ---")

        do {
            try await DiaryService.shared.deleteDiary(diaryId: diaryId)
            addTestResult("✅ 删除日记成功")

        } catch {
            addTestResult("❌ 删除日记失败: \(error)")
        }
    }
}

// MARK: - 预览

#Preview {
    DiaryTestView()
}
