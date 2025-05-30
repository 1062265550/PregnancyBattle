using COSXML;
using COSXML.Auth;
using COSXML.Model.Object;
using COSXML.Model.Bucket;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using PregnancyBattle.Application.Services.Interfaces;
using System.Text;

namespace PregnancyBattle.Infrastructure.Services.FileStorage
{
    /// <summary>
    /// 腾讯云COS存储服务实现
    /// </summary>
    public class TencentCosStorageService : IFileStorageService
    {
        private readonly CosXml _cosXml;
        private readonly string _bucketName;
        private readonly string _region;
        private readonly string _baseUrl;
        private readonly ILogger<TencentCosStorageService> _logger;

        public TencentCosStorageService(IConfiguration configuration, ILogger<TencentCosStorageService> logger)
        {
            _logger = logger;

            // 从配置中读取腾讯云COS配置
            var cosConfig = configuration.GetSection("TencentCos");
            var secretId = cosConfig["SecretId"];
            var secretKey = cosConfig["SecretKey"];
            _bucketName = cosConfig["BucketName"];
            _region = cosConfig["Region"];
            _baseUrl = cosConfig["BaseUrl"];

            if (string.IsNullOrEmpty(secretId) || string.IsNullOrEmpty(secretKey) || 
                string.IsNullOrEmpty(_bucketName) || string.IsNullOrEmpty(_region))
            {
                throw new ArgumentException("腾讯云COS配置信息不完整");
            }

            // 初始化COS配置
            var config = new CosXmlConfig.Builder()
                .IsHttps(true)
                .SetRegion(_region)
                .SetDebugLog(false)
                .Build();

            // 初始化认证信息
            var qCloudCredentialProvider = new DefaultQCloudCredentialProvider(secretId, secretKey, 600);

            // 初始化COS服务
            _cosXml = new CosXmlServer(config, qCloudCredentialProvider);

            _logger.LogInformation("腾讯云COS存储服务初始化完成，存储桶：{BucketName}，区域：{Region}", _bucketName, _region);
        }

        /// <summary>
        /// 上传文件
        /// </summary>
        public async Task<string> UploadFileAsync(byte[] fileData, string fileName, string contentType, string folder = "uploads")
        {
            try
            {
                // 生成对象键（文件路径）
                var objectKey = GenerateObjectKey(fileName, folder);

                // 创建上传请求
                var putObjectRequest = new PutObjectRequest(_bucketName, objectKey, fileData);
                putObjectRequest.SetRequestHeader("Content-Type", contentType);

                // 执行上传
                var result = _cosXml.PutObject(putObjectRequest);

                if (result.IsSuccessful())
                {
                    var fileUrl = GetFileUrl(objectKey);
                    _logger.LogInformation("文件上传成功：{FileName} -> {FileUrl}", fileName, fileUrl);
                    return fileUrl;
                }
                else
                {
                    _logger.LogError("文件上传失败：{FileName}，错误码：{ErrorCode}", fileName, result.httpCode);
                    throw new Exception($"文件上传失败，错误码：{result.httpCode}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "上传文件时发生异常：{FileName}", fileName);
                throw;
            }
        }

        /// <summary>
        /// 上传文件流
        /// </summary>
        public async Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType, string folder = "uploads")
        {
            try
            {
                // 将流转换为字节数组
                using var memoryStream = new MemoryStream();
                await fileStream.CopyToAsync(memoryStream);
                var fileData = memoryStream.ToArray();

                return await UploadFileAsync(fileData, fileName, contentType, folder);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "上传文件流时发生异常：{FileName}", fileName);
                throw;
            }
        }

        /// <summary>
        /// 删除文件
        /// </summary>
        public async Task<bool> DeleteFileAsync(string fileUrl)
        {
            try
            {
                // 从URL中提取对象键
                var objectKey = ExtractObjectKeyFromUrl(fileUrl);
                if (string.IsNullOrEmpty(objectKey))
                {
                    _logger.LogWarning("无法从URL中提取对象键：{FileUrl}", fileUrl);
                    return false;
                }

                // 创建删除请求
                var deleteObjectRequest = new DeleteObjectRequest(_bucketName, objectKey);

                // 执行删除
                var result = _cosXml.DeleteObject(deleteObjectRequest);

                if (result.IsSuccessful())
                {
                    _logger.LogInformation("文件删除成功：{FileUrl}", fileUrl);
                    return true;
                }
                else
                {
                    _logger.LogError("文件删除失败：{FileUrl}，错误码：{ErrorCode}", fileUrl, result.httpCode);
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "删除文件时发生异常：{FileUrl}", fileUrl);
                return false;
            }
        }

        /// <summary>
        /// 获取文件访问URL
        /// </summary>
        public string GetFileUrl(string filePath)
        {
            if (string.IsNullOrEmpty(_baseUrl))
            {
                // 如果没有配置自定义域名，使用默认的COS域名
                return $"https://{_bucketName}.cos.{_region}.myqcloud.com/{filePath}";
            }
            else
            {
                // 使用自定义域名
                return $"{_baseUrl.TrimEnd('/')}/{filePath}";
            }
        }

        /// <summary>
        /// 检查文件是否存在
        /// </summary>
        public async Task<bool> FileExistsAsync(string filePath)
        {
            try
            {
                var headObjectRequest = new HeadObjectRequest(_bucketName, filePath);
                var result = _cosXml.HeadObject(headObjectRequest);
                return result.IsSuccessful();
            }
            catch (Exception ex)
            {
                _logger.LogDebug(ex, "检查文件是否存在时发生异常：{FilePath}", filePath);
                return false;
            }
        }

        /// <summary>
        /// 生成对象键（文件路径）
        /// </summary>
        private string GenerateObjectKey(string fileName, string folder)
        {
            // 生成时间戳前缀，避免文件名冲突
            var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            var fileExtension = Path.GetExtension(fileName);
            var fileNameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
            
            // 清理文件名，移除特殊字符
            var cleanFileName = CleanFileName(fileNameWithoutExtension);
            
            // 生成最终的文件名
            var finalFileName = $"{timestamp}_{cleanFileName}{fileExtension}";
            
            // 组合完整路径
            return $"{folder.Trim('/')}/{finalFileName}";
        }

        /// <summary>
        /// 清理文件名，移除特殊字符
        /// </summary>
        private string CleanFileName(string fileName)
        {
            if (string.IsNullOrEmpty(fileName))
                return "file";

            // 移除或替换特殊字符
            var invalidChars = Path.GetInvalidFileNameChars();
            var cleanName = new StringBuilder();

            foreach (char c in fileName)
            {
                if (!invalidChars.Contains(c) && c != ' ')
                {
                    cleanName.Append(c);
                }
                else if (c == ' ')
                {
                    cleanName.Append('_');
                }
            }

            var result = cleanName.ToString();
            return string.IsNullOrEmpty(result) ? "file" : result;
        }

        /// <summary>
        /// 从URL中提取对象键
        /// </summary>
        private string ExtractObjectKeyFromUrl(string fileUrl)
        {
            try
            {
                var uri = new Uri(fileUrl);
                return uri.AbsolutePath.TrimStart('/');
            }
            catch
            {
                return string.Empty;
            }
        }
    }
}
