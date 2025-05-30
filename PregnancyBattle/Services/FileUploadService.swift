import Foundation

/// 文件上传服务
/// 负责处理文件上传到腾讯云COS的相关操作
class FileUploadService {
    static let shared = FileUploadService()
    
    private init() {}
    
    // MARK: - 文件上传方法
    
    /// 上传单个文件
    /// - Parameters:
    ///   - fileData: 文件数据
    ///   - fileName: 文件名
    ///   - contentType: 文件类型
    ///   - folder: 存储文件夹，默认为diary-media
    /// - Returns: 文件上传结果
    func uploadFile(
        fileData: Data,
        fileName: String,
        contentType: String,
        folder: String = "diary-media"
    ) async throws -> FileUploadResult {
        print("[FileUploadService] 开始上传文件: \(fileName), 大小: \(fileData.count) bytes")
        
        let result: FileUploadResult = try await APIService.shared.uploadFile(
            endpoint: "files/upload",
            fileData: fileData,
            fileName: fileName,
            contentType: contentType,
            folder: folder
        )
        
        print("[FileUploadService] 文件上传成功: \(result.fileName) -> \(result.fileUrl)")
        return result
    }
    
    /// 上传多个文件
    /// - Parameters:
    ///   - files: 文件列表
    ///   - folder: 存储文件夹，默认为diary-media
    ///   - progressCallback: 进度回调
    /// - Returns: 文件上传结果列表
    func uploadMultipleFiles(
        files: [(data: Data, fileName: String, contentType: String)],
        folder: String = "diary-media",
        progressCallback: @escaping (Double) -> Void = { _ in }
    ) async throws -> [FileUploadResult] {
        print("[FileUploadService] 开始批量上传文件，数量: \(files.count)")
        
        var results: [FileUploadResult] = []
        let totalFiles = files.count
        
        for (index, file) in files.enumerated() {
            do {
                let result = try await uploadFile(
                    fileData: file.data,
                    fileName: file.fileName,
                    contentType: file.contentType,
                    folder: folder
                )
                results.append(result)
                
                // 更新进度
                let progress = Double(index + 1) / Double(totalFiles)
                await MainActor.run {
                    progressCallback(progress)
                }
                
                print("[FileUploadService] 文件 \(index + 1)/\(totalFiles) 上传成功: \(file.fileName)")
                
            } catch {
                print("[FileUploadService] 文件上传失败: \(file.fileName), 错误: \(error)")
                throw error
            }
        }
        
        print("[FileUploadService] 批量上传完成，成功上传 \(results.count) 个文件")
        return results
    }
    
    /// 根据MediaFile上传文件
    /// - Parameters:
    ///   - mediaFile: 媒体文件对象
    ///   - folder: 存储文件夹
    /// - Returns: 文件上传结果
    func uploadMediaFile(
        mediaFile: MediaFile,
        folder: String = "diary-media"
    ) async throws -> FileUploadResult {
        // 根据文件类型确定Content-Type
        let contentType = getContentType(for: mediaFile.fileName, mediaType: mediaFile.type)
        
        return try await uploadFile(
            fileData: mediaFile.data,
            fileName: mediaFile.fileName,
            contentType: contentType,
            folder: folder
        )
    }
    
    // MARK: - 辅助方法
    
    /// 根据文件名和媒体类型获取Content-Type
    /// - Parameters:
    ///   - fileName: 文件名
    ///   - mediaType: 媒体类型
    /// - Returns: Content-Type字符串
    private func getContentType(for fileName: String, mediaType: MediaFile.MediaFileType) -> String {
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        
        switch mediaType {
        case .Image:
            switch fileExtension {
            case "jpg", "jpeg":
                return "image/jpeg"
            case "png":
                return "image/png"
            case "gif":
                return "image/gif"
            case "bmp":
                return "image/bmp"
            case "webp":
                return "image/webp"
            default:
                return "image/jpeg" // 默认为JPEG
            }
        case .Video:
            switch fileExtension {
            case "mp4":
                return "video/mp4"
            case "mov":
                return "video/quicktime"
            case "avi":
                return "video/x-msvideo"
            default:
                return "video/mp4" // 默认为MP4
            }
        case .Audio:
            switch fileExtension {
            case "mp3":
                return "audio/mpeg"
            case "wav":
                return "audio/wav"
            case "m4a":
                return "audio/mp4"
            default:
                return "audio/mpeg" // 默认为MP3
            }
        }
    }
    
    /// 验证文件大小
    /// - Parameter fileData: 文件数据
    /// - Returns: 是否符合大小限制
    func validateFileSize(_ fileData: Data) -> Bool {
        let maxSize = 10 * 1024 * 1024 // 10MB
        return fileData.count <= maxSize
    }
    
    /// 验证文件类型
    /// - Parameter fileName: 文件名
    /// - Returns: 是否为支持的文件类型
    func validateFileType(_ fileName: String) -> Bool {
        let allowedExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp", "mp4", "mov", "avi", "mp3", "wav"]
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        return allowedExtensions.contains(fileExtension)
    }
    
    /// 格式化文件大小
    /// - Parameter bytes: 字节数
    /// - Returns: 格式化的文件大小字符串
    func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
