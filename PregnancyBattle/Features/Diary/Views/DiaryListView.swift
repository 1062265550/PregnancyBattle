import SwiftUI

/// 日记列表视图
/// 显示日记列表，支持分页加载和下拉刷新
struct DiaryListView: View {
    @ObservedObject var viewModel: DiaryViewModel

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.diaries) { diary in
                DiaryCardView(
                    diary: diary,
                    viewModel: viewModel,
                    onTap: {
                        Task {
                            await viewModel.loadDiaryDetail(diaryId: diary.id)
                        }
                    }
                )
                .onAppear {
                    // 当显示到倒数第3个item时，加载更多
                    if diary.id == viewModel.diaries.suffix(3).first?.id {
                        Task {
                            await viewModel.loadMoreDiaries()
                        }
                    }

                    // 图片预加载功能已移除
                }
            }

            // 加载更多指示器
            if viewModel.hasMorePages {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("加载更多...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }


}

// MARK: - 日记卡片视图

struct DiaryCardView: View {
    let diary: Diary
    let viewModel: DiaryViewModel
    let onTap: () -> Void

    @State private var showingEditSheet = false
    @State private var showingActionSheet = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 头部信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(diary.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 8) {
                            Text(dateFormatter.string(from: diary.diaryDate))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let pregnancyWeek = diary.pregnancyWeek,
                               let pregnancyDay = diary.pregnancyDay {
                                Text("孕\(pregnancyWeek)周\(pregnancyDay)天")
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }

                    Spacer()

                    // 情绪显示
                    if let mood = diary.mood {
                        VStack(spacing: 2) {
                            Text(mood.emoji)
                                .font(.title2)
                            Text(mood.displayName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 内容预览
                Text(diary.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // 媒体文件预览
                if !diary.mediaFiles.isEmpty {
                    mediaPreviewSection
                }

                // 底部信息
                HStack {
                    // 标签
                    if !diary.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(diary.tags.prefix(3), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.secondary)
                                        .cornerRadius(4)
                                }

                                if diary.tags.count > 3 {
                                    Text("+\(diary.tags.count - 3)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    Spacer()

                    // 媒体文件指示器
                    if !diary.mediaFiles.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "paperclip")
                                .font(.caption)
                            Text("\(diary.mediaFiles.count)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }

                    // 创建时间
                    Text(timeFormatter.string(from: diary.createdAt))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture {
            showingActionSheet = true
        }
        .confirmationDialog("日记操作", isPresented: $showingActionSheet) {
            Button("编辑日记") {
                showingEditSheet = true
            }

            Button("删除日记", role: .destructive) {
                Task {
                    await viewModel.deleteDiary(diaryId: diary.id)
                }
            }

            Button("取消", role: .cancel) { }
        } message: {
            Text("选择要执行的操作")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDiaryView(diary: diary, viewModel: viewModel)
        }
    }

    // MARK: - 媒体文件预览部分

    private var mediaPreviewSection: some View {
        HStack(spacing: 8) {
            ForEach(diary.mediaFiles.prefix(3), id: \.id) { media in
                MediaThumbnailView(media: media)
            }

            if diary.mediaFiles.count > 3 {
                VStack {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("+\(diary.mediaFiles.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 40, height: 40)
                .background(Color(.systemGray5))
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - 媒体缩略图视图

private struct MediaThumbnailView: View {
    let media: DiaryMedia
    @State private var imageData: Data?
    @State private var isLoading = true
    @State private var hasError = false

    var body: some View {
        VStack(spacing: 2) {
            // 根据媒体类型显示不同内容
            switch media.mediaType {
            case .image:
                // 显示实际图片或错误状态
                Group {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipped()
                            .cornerRadius(6)
                    } else if hasError {
                        VStack {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                            Text("图片")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .onTapGesture {
                            // 点击重试
                            hasError = false
                            isLoading = true
                            loadImageData()
                        }
                    } else {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                    }
                }
                .onAppear {
                    loadImageData()
                }
                
            case .video:
                VStack {
                    Image(systemName: "video.fill")
                        .foregroundColor(.blue)
                }
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                
            case .audio:
                VStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.purple)
                }
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(6)
            }
            
            Text(media.mediaType.displayName)
                .font(.caption2)
                .foregroundColor(.secondary)
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
                print("[MediaThumbnailView] 图片加载失败: \(error)")
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
    DiaryListView(viewModel: DiaryViewModel())
        .background(Color(.systemGroupedBackground))
}
