import SwiftUI
import AVKit

/// 媒体文件预览视图
/// 支持图片、视频、音频的预览和播放
struct MediaPreviewView: View {
    let media: DiaryMedia
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var loadError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if let error = loadError {
                    errorView(error)
                } else {
                    contentView
                }
            }
            .navigationTitle(media.mediaType.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("分享") {
                        shareMedia()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            loadMedia()
        }
    }
    
    // MARK: - 内容视图
    
    @ViewBuilder
    private var contentView: some View {
        switch media.mediaType {
        case .image:
            ImagePreviewView(imageUrl: media.mediaUrl)
        case .video:
            VideoPreviewView(videoUrl: media.mediaUrl)
        case .audio:
            AudioPreviewView(audioUrl: media.mediaUrl, description: media.description)
        }
    }
    
    // MARK: - 加载视图
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("加载中...")
                .foregroundColor(.white)
                .font(.headline)
        }
    }
    
    // MARK: - 错误视图
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("加载失败")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(error)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("重试") {
                loadMedia()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    // MARK: - 私有方法
    
    private func loadMedia() {
        isLoading = true
        loadError = nil
        
        // 验证URL
        guard URL(string: media.mediaUrl) != nil else {
            isLoading = false
            loadError = "无效的媒体文件链接"
            return
        }
        
        // 模拟加载延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
    }
    
    private func shareMedia() {
        guard let url = URL(string: media.mediaUrl) else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
}

// MARK: - 图片预览视图

private struct ImagePreviewView: View {
    let imageUrl: String
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageData: Data?
    @State private var isLoading = true
    @State private var hasError = false
    
    var body: some View {
        Group {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
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
            } else if hasError {
                VStack(spacing: 16) {
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("图片加载失败")
                        .font(.headline)
                        .foregroundColor(.white)
                    Button("重试") {
                        loadImageData()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            loadImageData()
        }
    }
    
    private func loadImageData() {
        isLoading = true
        hasError = false
        
        Task {
            do {
                print("[ImagePreviewView] 开始加载图片: \(imageUrl)")
                
                guard let url = URL(string: imageUrl) else {
                    print("[ImagePreviewView] 无效的URL: \(imageUrl)")
                    await MainActor.run {
                        hasError = true
                        isLoading = false
                    }
                    return
                }
                
                // 创建配置了超时的URLSession
                let config = URLSessionConfiguration.default
                config.timeoutIntervalForRequest = 30.0
                config.timeoutIntervalForResource = 60.0
                config.waitsForConnectivity = true
                let session = URLSession(configuration: config)
                
                let (data, response) = try await session.data(from: url)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[ImagePreviewView] 无效的响应类型")
                    await MainActor.run {
                        hasError = true
                        isLoading = false
                    }
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    print("[ImagePreviewView] HTTP错误: \(httpResponse.statusCode)")
                    await MainActor.run {
                        hasError = true
                        isLoading = false
                    }
                    return
                }
                
                print("[ImagePreviewView] 图片加载成功，数据大小: \(data.count) bytes")
                
                await MainActor.run {
                    self.imageData = data
                    self.isLoading = false
                    self.hasError = false
                }
                
            } catch {
                print("[ImagePreviewView] 图片加载失败: \(error)")
                await MainActor.run {
                    hasError = true
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - 视频预览视图

private struct VideoPreviewView: View {
    let videoUrl: String
    
    var body: some View {
        if let url = URL(string: videoUrl) {
            VideoPlayer(player: AVPlayer(url: url))
                .aspectRatio(16/9, contentMode: .fit)
        } else {
            Text("无法加载视频")
                .foregroundColor(.white)
        }
    }
}

// MARK: - 音频预览视图

private struct AudioPreviewView: View {
    let audioUrl: String
    let description: String?
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 32) {
            // 音频图标
            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundColor(.white)
            
            // 描述
            if let description = description, !description.isEmpty {
                Text(description)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // 进度条
            VStack(spacing: 8) {
                Slider(value: $currentTime, in: 0...max(duration, 1)) { editing in
                    if !editing {
                        player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1))
                    }
                }
                .tint(.white)
                
                HStack {
                    Text(timeString(currentTime))
                        .foregroundColor(.gray)
                    Spacer()
                    Text(timeString(duration))
                        .foregroundColor(.gray)
                }
                .font(.caption)
            }
            .padding(.horizontal, 32)
            
            // 播放控制
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: audioUrl) else { return }
        
        player = AVPlayer(url: url)
        
        // 获取音频时长
        if let player = player {
            let asset = AVAsset(url: url)
            Task {
                do {
                    let duration = try await asset.load(.duration)
                    await MainActor.run {
                        self.duration = CMTimeGetSeconds(duration)
                    }
                } catch {
                    print("Failed to load audio duration: \(error)")
                }
            }
        }
        
        startTimer()
    }
    
    private func togglePlayback() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = player else { return }
            currentTime = CMTimeGetSeconds(player.currentTime())
        }
    }
    
    private func cleanup() {
        timer?.invalidate()
        timer = nil
        player?.pause()
        player = nil
    }
    
    private func timeString(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - 预览

#Preview {
    let sampleMedia = DiaryMedia(
        id: UUID(),
        mediaType: .image,
        mediaUrl: "https://example.com/image.jpg",
        description: "示例图片",
        createdAt: Date()
    )
    
    MediaPreviewView(media: sampleMedia)
}
