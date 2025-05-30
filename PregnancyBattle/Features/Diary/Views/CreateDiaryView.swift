import SwiftUI

/// 创建日记视图
/// 提供创建新日记的表单界面
struct CreateDiaryView: View {
    @ObservedObject var viewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss

    // 表单状态
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: DiaryMood = .neutral
    @State private var diaryDate = Date()
    @State private var tags: Set<String> = []
    @State private var newTag = ""
    @State private var pendingMediaFiles: [PendingMediaFile] = []

    // 媒体选择相关状态
    @State private var showingMediaPicker = false
    @State private var isUploadingMedia = false
    @State private var uploadProgress: Double = 0.0
    @State private var showingDatePicker = false

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
                        Text("写下你的感受...")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }

                // 情绪选择部分
                Section("心情") {
                    moodSelector
                }

                // 标签部分
                Section("标签") {
                    tagSection
                }

                // 媒体文件部分
                Section("媒体文件") {
                    mediaSection
                }
            }
            .navigationTitle("新建日记")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await saveDiary()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty || isUploadingMedia)
                }
            }
            .sheet(isPresented: $showingMediaPicker) {
                MediaPickerView(isPresented: $showingMediaPicker) { mediaFile in
                    addPendingMediaFile(mediaFile)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerSheet(selectedDate: $diaryDate)
            }
        }
    }

    // MARK: - Components

    private var moodSelector: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            ForEach(DiaryMood.allCases, id: \.self) { mood in
                VStack(spacing: 4) {
                    Text(mood.emoji)
                        .font(.largeTitle)
                    Text(mood.displayName)
                        .font(.caption)
                        .foregroundColor(selectedMood == mood ? .white : .primary)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(selectedMood == mood ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(12)
                .onTapGesture {
                    selectedMood = mood
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 添加标签输入框
            HStack {
                TextField("添加标签", text: $newTag)
                Button("添加") {
                    addTag()
                }
                .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            // 已添加的标签
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(tags), id: \.self) { tag in
                            HStack(spacing: 4) {
                                Text("#\(tag)")
                                    .font(.caption)
                                Button(action: {
                                    tags.remove(tag)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }

    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 添加媒体文件按钮
            Button(action: {
                showingMediaPicker = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("添加媒体文件")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(8)
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
            }

            // 待上传的媒体文件列表
            if !pendingMediaFiles.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("待上传的媒体文件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    LazyVStack(spacing: 8) {
                        ForEach(pendingMediaFiles) { pendingFile in
                            PendingMediaFileRow(pendingFile: pendingFile) {
                                removePendingMediaFile(pendingFile)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }

    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.insert(trimmedTag)
            newTag = ""
        }
    }

    private func removeTag(_ tag: String) {
        tags.remove(tag)
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
        print("[CreateDiaryView] 添加待上传媒体文件: \(mediaFile.fileName)")
    }

    private func removePendingMediaFile(_ pendingFile: PendingMediaFile) {
        pendingMediaFiles.removeAll { $0.id == pendingFile.id }
        print("[CreateDiaryView] 移除待上传媒体文件: \(pendingFile.displayName)")
    }

    private func saveDiary() async {
        print("[CreateDiaryView] 开始保存日记")
        print("[CreateDiaryView] 待上传媒体文件数量: \(pendingMediaFiles.count)")

        isUploadingMedia = true
        uploadProgress = 0.0

        var uploadedMediaFiles: [CreateDiaryMediaRequest] = []

        // 上传媒体文件
        if !pendingMediaFiles.isEmpty {
            do {
                print("[CreateDiaryView] 开始上传媒体文件")

                let totalFiles = pendingMediaFiles.count
                for (index, pendingFile) in pendingMediaFiles.enumerated() {
                    print("[CreateDiaryView] 上传文件 \(index + 1)/\(totalFiles): \(pendingFile.mediaFile.fileName)")

                    // 验证文件大小和类型
                    guard FileUploadService.shared.validateFileSize(pendingFile.mediaFile.data) else {
                        throw APIError.businessError(message: "文件 \(pendingFile.mediaFile.fileName) 大小超过10MB限制", code: "FILE_TOO_LARGE")
                    }

                    guard FileUploadService.shared.validateFileType(pendingFile.mediaFile.fileName) else {
                        throw APIError.businessError(message: "文件 \(pendingFile.mediaFile.fileName) 类型不支持", code: "UNSUPPORTED_FILE_TYPE")
                    }

                    // 上传文件
                    let uploadResult = try await FileUploadService.shared.uploadMediaFile(
                        mediaFile: pendingFile.mediaFile,
                        folder: "diary-media"
                    )

                    // 转换为日记媒体请求格式
                    let mediaType: MediaType
                    switch pendingFile.mediaFile.type {
                    case .Image:
                        mediaType = .image
                    case .Video:
                        mediaType = .video
                    case .Audio:
                        mediaType = .audio
                    }

                    let diaryMediaRequest = CreateDiaryMediaRequest(
                        mediaType: mediaType,
                        mediaUrl: uploadResult.fileUrl,
                        description: pendingFile.description
                    )

                    uploadedMediaFiles.append(diaryMediaRequest)

                    // 更新进度
                    let progress = Double(index + 1) / Double(totalFiles)
                    await MainActor.run {
                        uploadProgress = progress
                    }

                    print("[CreateDiaryView] 文件上传成功: \(uploadResult.fileName) -> \(uploadResult.fileUrl)")
                }

                print("[CreateDiaryView] 所有媒体文件上传完成，共 \(uploadedMediaFiles.count) 个文件")

            } catch {
                print("[CreateDiaryView] 媒体文件上传失败: \(error)")

                await MainActor.run {
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

        // 创建日记数据
        let diary = CreateDiaryRequest(
            title: title,
            content: content,
            mood: MoodType(rawValue: selectedMood.rawValue) ?? .happy,
            diaryDate: diaryDate,
            tags: Array(tags),
            mediaFiles: uploadedMediaFiles
        )

        print("[CreateDiaryView] 创建的请求媒体文件数量: \(diary.mediaFiles.count)")

        // 调用ViewModel保存日记
        await viewModel.createDiary(request: diary)

        await MainActor.run {
            isUploadingMedia = false
            uploadProgress = 0.0
        }

        // 关闭视图
        dismiss()
    }
}

// MARK: - Supporting Views

struct PendingMediaFileRow: View {
    let pendingFile: PendingMediaFile
    let onRemove: () -> Void
    @State private var showingMediaPreview = false

    var body: some View {
        HStack {
            // 媒体类型图标
            Image(systemName: iconForMediaType(pendingFile.mediaType))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(pendingFile.displayName)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(pendingFile.typeDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if pendingFile.mediaType == .image || pendingFile.mediaType == .video {
                    Button("点击预览") {
                        showingMediaPreview = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .sheet(isPresented: $showingMediaPreview) {
            LocalMediaPreviewView(mediaFile: pendingFile.mediaFile)
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

struct MediaFileRow: View {
    let mediaFile: DiaryMedia
    let onRemove: () -> Void

    var body: some View {
        HStack {
            // 媒体类型图标
            Image(systemName: iconForMediaType(mediaFile.mediaType.rawValue))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(displayFileName)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(mediaFile.mediaType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }

    // 计算显示的文件名
    private var displayFileName: String {
        // 从URL中提取文件名作为后备选项
        let urlFileName = mediaFile.mediaUrl.components(separatedBy: "/").last ?? "未知文件"
        return urlFileName
    }

    private func iconForMediaType(_ type: String) -> String {
        switch type.lowercased() {
        case "image":
            return "photo"
        case "video":
            return "video"
        case "audio":
            return "music.note"
        default:
            return "doc"
        }
    }
}

// MARK: - Data Models

enum DiaryMood: String, CaseIterable {
    case happy = "Happy"
    case sad = "Sad"
    case angry = "Angry"
    case anxious = "Anxious"
    case excited = "Excited"
    case tired = "Tired"
    case neutral = "Neutral"

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .anxious: return "😰"
        case .excited: return "🤗"
        case .tired: return "😴"
        case .neutral: return "😐"
        }
    }

    var displayName: String {
        switch self {
        case .happy: return "开心"
        case .sad: return "难过"
        case .angry: return "生气"
        case .anxious: return "焦虑"
        case .excited: return "兴奋"
        case .tired: return "疲惫"
        case .neutral: return "平静"
        }
    }
}

// MARK: - 日期选择器

private struct DatePickerSheet: View {
    @Binding var selectedDate: Date
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

// MARK: - 本地媒体文件预览视图

struct LocalMediaPreviewView: View {
    let mediaFile: MediaFile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                switch mediaFile.type {
                case .Image:
                    if let uiImage = UIImage(data: mediaFile.data) {
                        LocalImagePreviewView(image: uiImage)
                    } else {
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            Text("无法显示图片")
                                .foregroundColor(.white)
                        }
                    }
                case .Video:
                    VStack {
                        Image(systemName: "video")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("视频预览")
                            .foregroundColor(.white)
                        Text("本地视频文件")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                case .Audio:
                    VStack {
                        Image(systemName: "music.note")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        Text("音频文件")
                            .foregroundColor(.white)
                        Text(mediaFile.fileName)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(mediaFile.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - 本地图片预览视图

private struct LocalImagePreviewView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = max(1.0, min(value, 5.0))
                            },
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        if scale > 1.0 {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
        }
    }
}

// MARK: - Preview

#Preview {
    CreateDiaryView(viewModel: DiaryViewModel())
}
