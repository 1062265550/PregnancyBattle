import SwiftUI

/// 日记详情视图
/// 显示日记的完整内容，支持编辑和删除操作
struct DiaryDetailView: View {
    let diary: Diary
    @ObservedObject var viewModel: DiaryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditView = false
    @State private var showingDeleteAlert = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter
    }()

    // 使用计算属性来获取当前显示的日记数据
    // 优先使用从API重新获取的数据，如果没有则使用传入的数据
    private var currentDiary: Diary {
        return viewModel.selectedDiary ?? diary
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 头部信息
                    headerSection

                    // 内容部分
                    contentSection

                    // 标签部分
                    if !currentDiary.tags.isEmpty {
                        tagsSection
                    }

                    // 媒体文件部分
                    if !currentDiary.mediaFiles.isEmpty {
                        mediaSection
                    }

                    // 元数据部分
                    metadataSection
                }
                .padding()
            }
            .navigationTitle("日记详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("编辑") {
                            showingEditView = true
                        }

                        Button("删除", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditDiaryView(diary: currentDiary, viewModel: viewModel)
            }
            .alert("删除日记", isPresented: $showingDeleteAlert) {
                Button("删除", role: .destructive) {
                    Task {
                        await viewModel.deleteDiary(diaryId: currentDiary.id)
                        dismiss()
                    }
                }
                Button("取消", role: .cancel) { }
            } message: {
                Text("确定要删除这篇日记吗？此操作无法撤销。")
            }
        }
    }

    // MARK: - 头部信息

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(currentDiary.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // 日期和孕周信息
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateFormatter.string(from: currentDiary.diaryDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let pregnancyWeek = currentDiary.pregnancyWeek,
                       let pregnancyDay = currentDiary.pregnancyDay {
                        Text("孕\(pregnancyWeek)周\(pregnancyDay)天")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }

                Spacer()

                // 情绪显示
                if let mood = currentDiary.mood {
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.largeTitle)
                        Text(mood.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - 内容部分

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("内容")
                .font(.headline)
                .fontWeight(.semibold)

            Text(currentDiary.content)
                .font(.body)
                .lineSpacing(4)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - 标签部分

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("标签")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(currentDiary.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - 媒体文件部分

    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("附件")
                .font(.headline)
                .fontWeight(.semibold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(currentDiary.mediaFiles) { media in
                    MediaFileCard(media: media)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    // MARK: - 元数据部分

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("创建信息")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("创建时间:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(dateFormatter.string(from: currentDiary.createdAt))
                        .font(.caption)
                        .foregroundColor(.primary)
                }

                HStack {
                    Text("最后修改:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(dateFormatter.string(from: currentDiary.updatedAt))
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 媒体文件卡片

private struct MediaFileCard: View {
    let media: DiaryMedia
    @State private var showingMediaPreview = false
    @State private var imageData: Data?
    @State private var isLoading = true
    @State private var hasError = false

    var body: some View {
        Button(action: {
            showingMediaPreview = true
        }) {
            VStack(spacing: 8) {
                // 根据媒体类型显示不同内容
                switch media.mediaType {
                case .image:
                    // 显示实际图片或错误状态
                    Group {
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 120)
                                .clipped()
                                .cornerRadius(8)
                        } else if hasError {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("图片暂时无法显示")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("点击重试")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        } else {
                            VStack {
                                ProgressView()
                                Text("加载中...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .onAppear {
                        loadImageData()
                    }
                    .onTapGesture {
                        if hasError {
                            // 重试加载
                            hasError = false
                            isLoading = true
                            loadImageData()
                        }
                    }
                    
                case .video:
                    VStack {
                        Image(systemName: "video.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text("视频文件")
                            .font(.caption)
                        Text("点击播放")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                case .audio:
                    VStack {
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                            .foregroundColor(.purple)
                        Text("音频文件")
                            .font(.caption)
                        Text("点击播放")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }

                // 文件描述
                if let description = media.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                } else {
                    Text(media.mediaType.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingMediaPreview) {
            MediaPreviewView(media: media)
        }
    }
    
    private func loadImageData() {
        guard media.mediaType == .image else { return }

        Task {
            do {
                guard let url = URL(string: media.mediaUrl) else {
                    throw URLError(.badURL)
                }

                let (data, _) = try await URLSession.shared.data(from: url)

                await MainActor.run {
                    self.imageData = data
                    self.isLoading = false
                    self.hasError = false
                }

            } catch {
                print("[MediaFileCard] 图片加载失败: \(error)")
                await MainActor.run {
                    hasError = true
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - 预览

#Preview {
    let sampleDiary = Diary(
        id: UUID(),
        userId: UUID(),
        title: "今天的心情",
        content: "今天感觉很好，宝宝踢得很活跃。去医院做了产检，一切正常。医生说宝宝发育得很健康，我很开心。",
        mood: .happy,
        diaryDate: Date(),
        pregnancyWeek: 20,
        pregnancyDay: 3,
        createdAt: Date(),
        updatedAt: Date(),
        tags: ["产检", "胎动", "开心"],
        mediaFiles: []
    )

    DiaryDetailView(diary: sampleDiary, viewModel: DiaryViewModel())
}
