import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Photos

struct MediaPickerView: View {
    @Binding var isPresented: Bool
    let onMediaSelected: (MediaFile) -> Void

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var mediaType: MediaType = .image
    @State private var selectedFiles: [MediaFile] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isProcessingSelection = false
    @State private var showingPermissionAlert = false
    
    enum MediaType: String, CaseIterable {
        case image = "图片"
        case video = "视频"
        case audio = "音频"

        var systemImage: String {
            switch self {
            case .image: return "photo"
            case .video: return "video"
            case .audio: return "music.note"
            }
        }

        var displayName: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("添加媒体文件")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)

                Text("媒体类型")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // 媒体类型选择
                HStack(spacing: 16) {
                    ForEach(MediaType.allCases, id: \.self) { type in
                        MediaTypeButton(
                            type: type,
                            isSelected: mediaType == type
                        ) {
                            mediaType = type
                        }
                    }
                }
                .padding(.horizontal)

                // 已选择的文件列表
                if !selectedFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("已选择的文件 (\(selectedFiles.count))")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(Array(selectedFiles.enumerated()), id: \.offset) { index, file in
                                    SelectedFileRow(file: file) {
                                        selectedFiles.remove(at: index)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxHeight: 200)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    // 添加媒体文件按钮
                    Button(action: selectMedia) {
                        HStack {
                            if isProcessingSelection {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                                Text("处理中...")
                            } else {
                                Image(systemName: "plus.circle.fill")
                                Text("添加\(mediaType.rawValue)")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isProcessingSelection ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(isProcessingSelection)
                    .padding(.horizontal)

                    // 完成按钮
                    if !selectedFiles.isEmpty {
                        Button(action: confirmSelection) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("确认添加 (\(selectedFiles.count)个文件)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItems, maxSelectionCount: 10, matching: .any(of: [.images, .videos]))
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: allowedContentTypes,
            allowsMultipleSelection: true
        ) { result in
            handleDocumentSelection(result)
        }
        .onChange(of: selectedItems) { oldValue, newValue in
            handlePhotosSelection(newValue)
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var allowedContentTypes: [UTType] {
        switch mediaType {
        case .image:
            return [.image]
        case .video:
            return [.movie, .video]
        case .audio:
            return [.audio, .mp3]
        }
    }
    
    private func selectMedia() {
        switch mediaType {
        case .image, .video:
            // 检查照片库权限
            checkPhotoLibraryPermission { hasPermission in
                if hasPermission {
                    showingImagePicker = true
                } else {
                    alertMessage = "需要访问照片库权限才能选择图片和视频。请在设置中开启权限。"
                    showingAlert = true
                }
            }
        case .audio:
            showingDocumentPicker = true
        }
    }
    
    /// 检查照片库权限
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            completion(true)
        case .limited:
            // 有限访问也可以使用
            completion(true)
        case .denied, .restricted:
            completion(false)
        case .notDetermined:
            // 请求权限
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        @unknown default:
            completion(false)
        }
    }
    
    private func handlePhotosSelection(_ items: [PhotosPickerItem]) {
        guard !items.isEmpty else { return }

        isProcessingSelection = true

        Task {
            var newFiles: [MediaFile] = []
            var skippedCount = 0
            var failedCount = 0
            var oversizedCount = 0

            print("[MediaPickerView] 开始处理 \(items.count) 个选中的媒体文件")

            for (index, item) in items.enumerated() {
                print("[MediaPickerView] 第 \(index + 1) 个文件支持的类型: \(item.supportedContentTypes)")

                let result = await loadMediaItem(item, index: index)
                
                switch result {
                case .success(let mediaFile):
                    newFiles.append(mediaFile)
                    print("[MediaPickerView] 成功创建媒体文件: \(mediaFile.fileName)")
                case .failure(let error):
                    switch error {
                    case .oversized:
                        oversizedCount += 1
                    case .loadFailed:
                        failedCount += 1
                    case .unsupportedType:
                        skippedCount += 1
                    }
                }
            }

            await MainActor.run {
                // 添加所有新文件到选择列表
                selectedFiles.append(contentsOf: newFiles)

                // 生成详细的结果反馈
                var message = "成功添加 \(newFiles.count) 个文件"
                if oversizedCount > 0 || failedCount > 0 || skippedCount > 0 {
                    var details: [String] = []
                    if oversizedCount > 0 {
                        details.append("\(oversizedCount) 个文件超过10MB限制")
                    }
                    if failedCount > 0 {
                        details.append("\(failedCount) 个文件加载失败")
                    }
                    if skippedCount > 0 {
                        details.append("\(skippedCount) 个文件类型不支持")
                    }
                    message += "，跳过了 " + details.joined(separator: "，")
                    alertMessage = message
                    showingAlert = true
                }

                // 清空选择项以允许再次选择
                selectedItems.removeAll()
                isProcessingSelection = false

                print("[MediaPickerView] 处理完成：成功 \(newFiles.count)，超大 \(oversizedCount)，失败 \(failedCount)，跳过 \(skippedCount)")
            }
        }
    }
    
    // MARK: - 媒体加载错误类型
    private enum MediaLoadError: Error {
        case loadFailed
        case oversized
        case unsupportedType
    }
    
    // MARK: - 媒体加载结果
    private enum MediaLoadResult {
        case success(MediaFile)
        case failure(MediaLoadError)
    }
    
    /// 加载单个媒体项目
    private func loadMediaItem(_ item: PhotosPickerItem, index: Int) async -> MediaLoadResult {
        // 策略1: 对于图片，尝试使用Image类型加载（iOS 16+支持）
        if mediaType == .image {
            // 尝试先加载为Image，然后转换为UIImage
            do {
                // 使用Data类型加载，然后创建UIImage
                if let data = try await item.loadTransferable(type: Data.self) {
                    // 验证是否为有效图片数据
                    if let uiImage = UIImage(data: data) {
                        // 重新压缩为JPEG格式以确保兼容性
                        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                            print("[MediaPickerView] 第 \(index + 1) 个文件通过 Data->UIImage 加载成功")
                            return await createMediaFile(from: jpegData, index: index)
                        }
                    }
                    
                    // 如果无法创建UIImage，直接使用原始数据
                    print("[MediaPickerView] 第 \(index + 1) 个文件通过原始Data加载成功")
                    return await createMediaFile(from: data, index: index)
                }
            } catch {
                print("[MediaPickerView] 第 \(index + 1) 个文件 Data 加载失败: \(error.localizedDescription)")
            }
        }

        // 策略2: 使用标准内容类型加载
        for contentType in item.supportedContentTypes {
            // 跳过私有或缩略图类型，优先处理标准类型
            if contentType.identifier.contains("private") || contentType.identifier.contains("thumbnail") {
                continue
            }

            if contentType.conforms(to: .image) || contentType.conforms(to: .movie) {
                print("[MediaPickerView] 尝试加载第 \(index + 1) 个文件，类型: \(contentType)")
                
                do {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        print("[MediaPickerView] 第 \(index + 1) 个文件通过 \(contentType) 加载成功")
                        return await createMediaFile(from: data, index: index)
                    }
                } catch {
                    print("[MediaPickerView] 第 \(index + 1) 个文件类型 \(contentType) 加载失败: \(error.localizedDescription)")
                    continue
                }
            }
        }

        // 策略3: 直接尝试Data加载
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                print("[MediaPickerView] 第 \(index + 1) 个文件通过直接Data加载成功")
                return await createMediaFile(from: data, index: index)
            }
        } catch {
            print("[MediaPickerView] 第 \(index + 1) 个文件直接Data加载失败: \(error.localizedDescription)")
        }

        // 策略4: 最后尝试缩略图类型（作为降级方案）
        for contentType in item.supportedContentTypes {
            if contentType.identifier.contains("thumbnail") {
                print("[MediaPickerView] 尝试加载第 \(index + 1) 个文件缩略图，类型: \(contentType)")
                
                do {
                    if let data = try await item.loadTransferable(type: Data.self) {
                        print("[MediaPickerView] 第 \(index + 1) 个文件通过缩略图加载成功（可能质量较低）")
                        return await createMediaFile(from: data, index: index)
                    }
                } catch {
                    print("[MediaPickerView] 第 \(index + 1) 个文件缩略图加载失败: \(error.localizedDescription)")
                    continue
                }
            }
        }

        print("[MediaPickerView] 第 \(index + 1) 个文件所有加载方法都失败")
        return .failure(.loadFailed)
    }
    
    /// 创建媒体文件对象
    private func createMediaFile(from data: Data, index: Int) async -> MediaLoadResult {
        // 验证文件大小（10MB限制）
        let maxSize = 10 * 1024 * 1024 // 10MB
        if data.count > maxSize {
            print("[MediaPickerView] 第 \(index + 1) 个文件超过大小限制: \(data.count) bytes")
            return .failure(.oversized)
        }
        
        // 验证数据完整性
        guard data.count > 0 else {
            print("[MediaPickerView] 第 \(index + 1) 个文件数据为空")
            return .failure(.loadFailed)
        }

        // 生成唯一的文件名
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileExtension = getFileExtension(for: mediaType)
        let fileName = "media_\(timestamp)_\(index)\(fileExtension)"

        let mediaFile = MediaFile(
            data: data,
            type: mediaType == .image ? .Image : .Video,
            fileName: fileName
        )

        print("[MediaPickerView] 成功加载第 \(index + 1) 个文件，大小: \(data.count) bytes")
        return .success(mediaFile)
    }
    
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard !urls.isEmpty else { return }

            isProcessingSelection = true

            Task {
                var newFiles: [MediaFile] = []

                for url in urls {
                    do {
                        let data = try Data(contentsOf: url)

                        // 验证文件大小（10MB限制）
                        let maxSize = 10 * 1024 * 1024 // 10MB
                        if data.count > maxSize {
                            await MainActor.run {
                                alertMessage = "文件 \(url.lastPathComponent) 大小超过10MB限制，已跳过"
                                showingAlert = true
                            }
                            continue
                        }

                        let fileName = url.lastPathComponent

                        let mediaFile = MediaFile(
                            data: data,
                            type: .Audio,
                            fileName: fileName
                        )

                        // 检查是否已经选择了相同的文件
                        if !selectedFiles.contains(where: { $0.fileName == mediaFile.fileName }) {
                            newFiles.append(mediaFile)
                        }
                    } catch {
                        await MainActor.run {
                            alertMessage = "读取文件 \(url.lastPathComponent) 失败: \(error.localizedDescription)"
                            showingAlert = true
                        }
                    }
                }

                await MainActor.run {
                    selectedFiles.append(contentsOf: newFiles)
                    isProcessingSelection = false
                }
            }

        case .failure(let error):
            alertMessage = "选择文件失败: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func confirmSelection() {
        // 将所有选择的文件添加到日记中
        for file in selectedFiles {
            onMediaSelected(file)
        }
        isPresented = false
    }

    // MARK: - Helper Methods
    private func getFileExtension(for mediaType: MediaType) -> String {
        switch mediaType {
        case .image:
            return ".jpg"
        case .video:
            return ".mp4"
        case .audio:
            return ".mp3"
        }
    }
}

struct MediaTypeButton: View {
    let type: MediaPickerView.MediaType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.systemImage)
                    .font(.title2)
                Text(type.rawValue)
                    .font(.caption)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// 媒体文件数据模型
struct MediaFile {
    let data: Data
    let type: MediaFileType
    let fileName: String

    enum MediaFileType: String {
        case Image = "Image"
        case Video = "Video"
        case Audio = "Audio"
    }
}

// 待上传的媒体文件模型
struct PendingMediaFile: Identifiable {
    let id = UUID()
    let mediaFile: MediaFile
    let mediaType: MediaType
    var description: String?
    var isUploading: Bool = false
    var uploadProgress: Double = 0.0
    var uploadedFileId: String?
    var uploadedFileUrl: String?

    var displayName: String {
        return mediaFile.fileName
    }

    var typeDisplayName: String {
        return mediaType.displayName
    }
}

struct SelectedFileRow: View {
    let file: MediaFile
    let onRemove: () -> Void

    var body: some View {
        HStack {
            // 文件类型图标
            Image(systemName: iconForFileType(file.type))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(file.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private func iconForFileType(_ type: MediaFile.MediaFileType) -> String {
        switch type {
        case .Image:
            return "photo"
        case .Video:
            return "video"
        case .Audio:
            return "music.note"
        }
    }
}

#Preview {
    MediaPickerView(isPresented: .constant(true)) { _ in }
}