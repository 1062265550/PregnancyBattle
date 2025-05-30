import SwiftUI

/// 编辑日记视图
/// 提供编辑现有日记的表单界面
struct EditDiaryView: View {
    let diary: Diary
    @ObservedObject var viewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss

    // 表单状态
    @State private var title: String
    @State private var content: String
    @State private var selectedMood: MoodType?
    @State private var diaryDate: Date
    @State private var tags: [String]
    @State private var newTag = ""
    @FocusState private var isTagInputFocused: Bool

    // UI状态
    @State private var isSubmitting = false
    @State private var showingDatePicker = false
    @State private var hasChanges = false
    @State private var showingDeleteAlert = false
    @State private var showingMediaPicker = false

    // 媒体文件上传状态
    @State private var isUploadingMedia = false
    @State private var uploadProgress: Double = 0.0
    @State private var pendingMediaFiles: [PendingMediaFile] = []
    
    // 媒体文件删除跟踪
    @State private var deletedMediaIds: Set<UUID> = []
    @State private var hasMediaChanges = false

    // 初始化
    init(diary: Diary, viewModel: DiaryViewModel) {
        self.diary = diary
        self.viewModel = viewModel

        // 初始化状态
        _title = State(initialValue: diary.title)
        _content = State(initialValue: diary.content)
        _selectedMood = State(initialValue: diary.mood)
        _diaryDate = State(initialValue: diary.diaryDate)
        _tags = State(initialValue: diary.tags)
    }

    var body: some View {
        NavigationView {
            Form {
                // 基本信息部分
                Section("基本信息") {
                    // 标题输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        TextField("给这篇日记起个标题...", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: title) { _ in
                                checkForChanges()
                            }
                    }

                    // 日期选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("日期")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Button(action: {
                            showingDatePicker = true
                        }) {
                            HStack {
                                Text("选择日期")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatDate(diaryDate))
                                    .foregroundColor(.primary)
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }

                // 内容部分
                Section("内容") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("内容")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: content) { _ in
                                checkForChanges()
                            }
                    }
                }

                // 情绪选择部分
                Section("心情") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今天的心情如何？")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(MoodType.allCases, id: \.self) { mood in
                                MoodSelectionButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood
                                ) {
                                    selectedMood = mood
                                    checkForChanges()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // 标签部分
                Section("标签") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("标签")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Spacer()

                            Button("添加标签") {
                                isTagInputFocused = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }

                        // 标签输入框（内联方式）
                        HStack {
                            TextField("输入标签名称", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($isTagInputFocused)
                                .onSubmit {
                                    addNewTag()
                                }

                            Button("添加") {
                                addNewTag()
                            }
                            .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }

                        // 已添加的标签
                        if !tags.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    TagChip(tag: tag) {
                                        // 使用 removeAll 来删除指定标签，避免索引问题
                                        tags.removeAll { $0 == tag }
                                        checkForChanges()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle()) // 确保整个区域有明确的形状
                    .onTapGesture {
                        // 阻止点击事件向上传播到Section
                        // 这里不做任何操作，只是为了捕获点击事件
                    }
                }

                // 媒体文件部分
                Section("媒体文件") {
                    // 添加媒体文件按钮
                    Button(action: {
                        showingMediaPicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("添加媒体文件")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(isUploadingMedia)

                    // 上传进度
                    if isUploadingMedia {
                        VStack(alignment: .leading, spacing: 4) {
                            if pendingMediaFiles.isEmpty {
                                Text("正在保存日记...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("正在上传媒体文件... (\(Int(uploadProgress * 100))%)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            ProgressView(value: uploadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .padding(.vertical, 4)
                    }

                    // 待上传的媒体文件列表
                    if !pendingMediaFiles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("待上传的媒体文件")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)

                            ForEach(pendingMediaFiles) { pendingFile in
                                PendingMediaFileRow(pendingFile: pendingFile) {
                                    removePendingMediaFile(pendingFile)
                                }
                            }
                        }
                    }

                    // 显示现有的媒体文件
                    let visibleMediaFiles = diary.mediaFiles.filter { !deletedMediaIds.contains($0.id) }
                    if !visibleMediaFiles.isEmpty {
                        ForEach(visibleMediaFiles, id: \.id) { mediaFile in
                            ExistingMediaFileRow(mediaFile: mediaFile) {
                                Task {
                                    await deleteMediaFile(mediaFile.id)
                                }
                            }
                        }
                        .disabled(isSubmitting || isUploadingMedia)
                    }
                }

                // 删除日记部分
                Section {
                    Button("删除日记", role: .destructive) {
                        showingDeleteAlert = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle("编辑日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        if hasChanges {
                            // 可以添加确认对话框
                        }
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await submitChanges()
                        }
                    }
                    .disabled((!hasChanges && !hasMediaChanges) || title.isEmpty || content.isEmpty || isSubmitting || isUploadingMedia)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $diaryDate) {
                    checkForChanges()
                }
            }
            .sheet(isPresented: $showingMediaPicker) {
                MediaPickerView(isPresented: $showingMediaPicker) { mediaFile in
                    addPendingMediaFile(mediaFile)
                }
            }
            .alert("删除日记", isPresented: $showingDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("删除", role: .destructive) {
                    Task {
                        await deleteDiary()
                    }
                }
            } message: {
                Text("确定要删除这篇日记吗？此操作无法撤销。")
            }
            .disabled(isSubmitting)
        }
        .onAppear {
            checkForChanges()
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func checkForChanges() {
        hasChanges = title != diary.title ||
                    content != diary.content ||
                    selectedMood != diary.mood ||
                    !Calendar.current.isDate(diaryDate, inSameDayAs: diary.diaryDate) ||
                    tags != diary.tags
        
        // 检查媒体文件变化
        hasMediaChanges = !pendingMediaFiles.isEmpty || !deletedMediaIds.isEmpty
        
        print("[EditDiaryView] 检查变化 - 基本字段变化: \(hasChanges), 媒体变化: \(hasMediaChanges)")
    }

    private func addNewTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
            checkForChanges()
        }
    }

    private func addPendingMediaFile(_ mediaFile: MediaFile) {
        let mediaType: MediaType
        switch mediaFile.type {
        case .Image:
            mediaType = .image
        case .Video:
            mediaType = .video
        case .Audio:
            mediaType = .audio
        }

        let pendingFile = PendingMediaFile(
            mediaFile: mediaFile,
            mediaType: mediaType
        )

        pendingMediaFiles.append(pendingFile)
        checkForChanges()
        print("[EditDiaryView] 添加待上传媒体文件: \(mediaFile.fileName)")
    }

    private func removePendingMediaFile(_ pendingFile: PendingMediaFile) {
        pendingMediaFiles.removeAll { $0.id == pendingFile.id }
        checkForChanges()
        print("[EditDiaryView] 移除待上传媒体文件: \(pendingFile.displayName)")
    }

    private func submitChanges() async {
        guard (hasChanges || hasMediaChanges) && !title.isEmpty && !content.isEmpty else { return }

        isSubmitting = true
        isUploadingMedia = true
        uploadProgress = 0.0

        // 先上传待上传的媒体文件
        if !pendingMediaFiles.isEmpty {
            do {
                print("[EditDiaryView] 开始上传媒体文件，共 \(pendingMediaFiles.count) 个文件")

                let totalFiles = pendingMediaFiles.count
                for (index, pendingFile) in pendingMediaFiles.enumerated() {
                    print("[EditDiaryView] 上传文件 \(index + 1)/\(totalFiles): \(pendingFile.mediaFile.fileName)")

                    // 验证文件大小和类型
                    guard FileUploadService.shared.validateFileSize(pendingFile.mediaFile.data) else {
                        throw APIError.businessError(message: "文件 \(pendingFile.mediaFile.fileName) 大小超过10MB限制", code: "FILE_TOO_LARGE")
                    }

                    guard FileUploadService.shared.validateFileType(pendingFile.mediaFile.fileName) else {
                        throw APIError.businessError(message: "文件 \(pendingFile.mediaFile.fileName) 类型不支持", code: "UNSUPPORTED_FILE_TYPE")
                    }

                    // 上传媒体文件到日记
                    await viewModel.uploadDiaryMedia(diaryId: diary.id, mediaFile: pendingFile.mediaFile)

                    // 更新进度
                    let progress = Double(index + 1) / Double(totalFiles)
                    await MainActor.run {
                        uploadProgress = progress
                    }

                    print("[EditDiaryView] 文件上传成功: \(pendingFile.mediaFile.fileName)")
                }

                print("[EditDiaryView] 所有媒体文件上传完成")

                // 清空待上传文件列表
                await MainActor.run {
                    pendingMediaFiles.removeAll()
                }

            } catch {
                print("[EditDiaryView] 媒体文件上传失败: \(error)")

                await MainActor.run {
                    isSubmitting = false
                    isUploadingMedia = false
                    uploadProgress = 0.0

                    // 显示错误消息
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .businessError(let message, _):
                            viewModel.error = message
                        default:
                            viewModel.error = "媒体文件上传失败: \(error.localizedDescription)"
                        }
                    } else {
                        viewModel.error = "媒体文件上传失败: \(error.localizedDescription)"
                    }
                }
                return
            }
        }

        // 更新日记基本信息
        if title != diary.title || content != diary.content || selectedMood != diary.mood || !Calendar.current.isDate(diaryDate, inSameDayAs: diary.diaryDate) {
            let request = UpdateDiaryRequest(
                title: title != diary.title ? title : nil,
                content: content != diary.content ? content : nil,
                mood: selectedMood != diary.mood ? selectedMood : nil,
                diaryDate: !Calendar.current.isDate(diaryDate, inSameDayAs: diary.diaryDate) ? diaryDate : nil
            )

            await viewModel.updateDiary(diaryId: diary.id, request: request)
        }

        // 处理标签变化
        if tags != diary.tags {
            await handleTagChanges()
        }

        await MainActor.run {
            isSubmitting = false
            isUploadingMedia = false
            uploadProgress = 0.0
            
            // 清理状态
            deletedMediaIds.removeAll()
            hasMediaChanges = false
        }

        // 如果更新成功，关闭视图
        if viewModel.error == nil {
            dismiss()
        }
    }

    private func handleTagChanges() async {
        let oldTags = Set(diary.tags)
        let newTags = Set(tags)

        // 删除不再存在的标签
        let tagsToRemove = oldTags.subtracting(newTags)
        for tag in tagsToRemove {
            await viewModel.deleteDiaryTag(diaryId: diary.id, tag: tag)
        }

        // 添加新标签
        let tagsToAdd = newTags.subtracting(oldTags)
        if !tagsToAdd.isEmpty {
            await viewModel.addDiaryTags(diaryId: diary.id, tags: Array(tagsToAdd))
        }
    }

    private func deleteDiary() async {
        isSubmitting = true
        await viewModel.deleteDiary(diaryId: diary.id)
        isSubmitting = false

        if viewModel.error == nil {
            dismiss()
        }
    }

    private func deleteMediaFile(_ mediaId: UUID) async {
        print("[EditDiaryView] 开始删除媒体文件: \(mediaId)")
        
        // 先添加到删除列表
        deletedMediaIds.insert(mediaId)
        checkForChanges()
        
        // 调用删除API
        await viewModel.deleteDiaryMedia(diaryId: diary.id, mediaId: mediaId)
        
        print("[EditDiaryView] 媒体文件删除完成: \(mediaId)")
    }


}

// MARK: - 情绪选择按钮

private struct MoodSelectionButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.title2)

                Text(mood.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(PlainButtonStyle()) // 添加这行来确保按钮样式正确
    }
}

// MARK: - 标签芯片

private struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle()) // 确保按钮有明确的点击区域
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(12)
    }
}

// MARK: - 日期选择器

private struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let onDateChanged: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(WheelDatePickerStyle())
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .padding()
                .onChange(of: selectedDate) { _ in
                    onDateChanged()
                }

                Spacer()
            }
            .navigationTitle("选择日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}



// MARK: - 现有媒体文件行

private struct ExistingMediaFileRow: View {
    let mediaFile: DiaryMedia
    let onDelete: () -> Void
    @State private var showingMediaPreview = false

    var body: some View {
        HStack {
            // 媒体类型图标
            Image(systemName: iconForMediaType(mediaFile.mediaType))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(mediaFile.mediaType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let description = mediaFile.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Button("点击查看") {
                    showingMediaPreview = true
                }
                .font(.caption)
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
            }

            Spacer()

            Button("删除", role: .destructive) {
                onDelete()
            }
            .font(.caption)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingMediaPreview) {
            MediaPreviewView(media: mediaFile)
        }
    }

    private func iconForMediaType(_ type: MediaType) -> String {
        switch type {
        case .image:
            return "photo"
        case .video:
            return "video"
        case .audio:
            return "music.note"
        }
    }
}



// MARK: - 预览

#Preview {
    let sampleDiary = Diary(
        id: UUID(),
        userId: UUID(),
        title: "今天的心情",
        content: "今天感觉很好，宝宝踢得很活跃。",
        mood: .happy,
        diaryDate: Date(),
        pregnancyWeek: 20,
        pregnancyDay: 3,
        createdAt: Date(),
        updatedAt: Date(),
        tags: ["产检", "胎动"],
        mediaFiles: []
    )

    EditDiaryView(diary: sampleDiary, viewModel: DiaryViewModel())
}
