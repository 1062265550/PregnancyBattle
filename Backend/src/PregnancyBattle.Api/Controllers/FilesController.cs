using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Api.Models;
using PregnancyBattle.Application.Services.Interfaces;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 文件管理控制器
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FilesController : BaseApiController
    {
        private readonly IFileStorageService _fileStorageService;
        private readonly ILogger<FilesController> _logger;

        public FilesController(IFileStorageService fileStorageService, ILogger<FilesController> logger)
        {
            _fileStorageService = fileStorageService;
            _logger = logger;
        }

        /// <summary>
        /// 上传单个文件
        /// </summary>
        /// <param name="file">文件</param>
        /// <param name="folder">存储文件夹，默认为uploads</param>
        /// <returns>文件访问URL</returns>
        [HttpPost("upload")]
        [ProducesResponseType(typeof(ApiResponse<FileUploadResultDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> UploadFile(IFormFile file, [FromQuery] string folder = "uploads")
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest(ApiResponse<object>.CreateFailure("请选择要上传的文件"));
                }

                // 验证文件大小（限制为10MB）
                const long maxFileSize = 10 * 1024 * 1024; // 10MB
                if (file.Length > maxFileSize)
                {
                    return BadRequest(ApiResponse<object>.CreateFailure("文件大小不能超过10MB"));
                }

                // 验证文件类型
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".mp4", ".mov", ".avi", ".mp3", ".wav", ".pdf", ".doc", ".docx", ".txt" };
                var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();

                if (!allowedExtensions.Contains(fileExtension))
                {
                    return BadRequest(ApiResponse<object>.CreateFailure("不支持的文件类型"));
                }

                // 上传文件
                using var stream = file.OpenReadStream();
                var fileUrl = await _fileStorageService.UploadFileAsync(stream, file.FileName, file.ContentType, folder);

                var result = new FileUploadResultDto
                {
                    FileName = file.FileName,
                    FileUrl = fileUrl,
                    FileSize = file.Length,
                    ContentType = file.ContentType
                };

                _logger.LogInformation("文件上传成功：{FileName} -> {FileUrl}", file.FileName, fileUrl);
                return Ok(ApiResponse<FileUploadResultDto>.CreateSuccess(result, "文件上传成功"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "文件上传失败：{FileName}", file?.FileName);
                return StatusCode(500, ApiResponse<object>.CreateFailure("文件上传失败"));
            }
        }

        /// <summary>
        /// 上传多个文件
        /// </summary>
        /// <param name="files">文件列表</param>
        /// <param name="folder">存储文件夹，默认为uploads</param>
        /// <returns>文件访问URL列表</returns>
        [HttpPost("upload-multiple")]
        [ProducesResponseType(typeof(ApiResponse<List<FileUploadResultDto>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> UploadMultipleFiles(List<IFormFile> files, [FromQuery] string folder = "uploads")
        {
            try
            {
                if (files == null || files.Count == 0)
                {
                    return BadRequest(ApiResponse<object>.CreateFailure("请选择要上传的文件"));
                }

                // 限制文件数量
                if (files.Count > 10)
                {
                    return BadRequest(ApiResponse<object>.CreateFailure("一次最多只能上传10个文件"));
                }

                var results = new List<FileUploadResultDto>();
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".mp4", ".mov", ".avi", ".mp3", ".wav", ".pdf", ".doc", ".docx", ".txt" };
                const long maxFileSize = 10 * 1024 * 1024; // 10MB

                foreach (var file in files)
                {
                    if (file == null || file.Length == 0)
                        continue;

                    // 验证文件大小
                    if (file.Length > maxFileSize)
                    {
                        return BadRequest(ApiResponse<object>.CreateFailure($"文件 {file.FileName} 大小不能超过10MB"));
                    }

                    // 验证文件类型
                    var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
                    if (!allowedExtensions.Contains(fileExtension))
                    {
                        return BadRequest(ApiResponse<object>.CreateFailure($"文件 {file.FileName} 类型不支持"));
                    }

                    try
                    {
                        // 上传文件
                        using var stream = file.OpenReadStream();
                        var fileUrl = await _fileStorageService.UploadFileAsync(stream, file.FileName, file.ContentType, folder);

                        results.Add(new FileUploadResultDto
                        {
                            FileName = file.FileName,
                            FileUrl = fileUrl,
                            FileSize = file.Length,
                            ContentType = file.ContentType
                        });
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "文件上传失败：{FileName}", file.FileName);
                        return StatusCode(500, ApiResponse<object>.CreateFailure($"文件 {file.FileName} 上传失败"));
                    }
                }

                _logger.LogInformation("批量文件上传成功，共上传 {Count} 个文件", results.Count);
                return Ok(ApiResponse<List<FileUploadResultDto>>.CreateSuccess(results, "文件上传成功"));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "批量文件上传失败");
                return StatusCode(500, ApiResponse<object>.CreateFailure("文件上传失败"));
            }
        }

        /// <summary>
        /// 删除文件
        /// </summary>
        /// <param name="fileUrl">文件URL</param>
        /// <returns>删除结果</returns>
        [HttpDelete("delete")]
        [ProducesResponseType(typeof(ApiResponse<object>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        public async Task<IActionResult> DeleteFile([FromQuery] string fileUrl)
        {
            try
            {
                if (string.IsNullOrEmpty(fileUrl))
                {
                    return BadRequest(ApiResponse<object>.CreateFailure("文件URL不能为空"));
                }

                var result = await _fileStorageService.DeleteFileAsync(fileUrl);

                if (result)
                {
                    _logger.LogInformation("文件删除成功：{FileUrl}", fileUrl);
                    return Ok(ApiResponse<object>.CreateSuccess(null, "文件删除成功"));
                }
                else
                {
                    _logger.LogWarning("文件删除失败：{FileUrl}", fileUrl);
                    return BadRequest(ApiResponse<object>.CreateFailure("文件删除失败"));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "删除文件时发生异常：{FileUrl}", fileUrl);
                return StatusCode(500, ApiResponse<object>.CreateFailure("文件删除失败"));
            }
        }
    }

    /// <summary>
    /// 文件上传结果DTO
    /// </summary>
    public class FileUploadResultDto
    {
        /// <summary>
        /// 文件名
        /// </summary>
        public string FileName { get; set; } = string.Empty;

        /// <summary>
        /// 文件访问URL
        /// </summary>
        public string FileUrl { get; set; } = string.Empty;

        /// <summary>
        /// 文件大小（字节）
        /// </summary>
        public long FileSize { get; set; }

        /// <summary>
        /// 文件类型
        /// </summary>
        public string ContentType { get; set; } = string.Empty;
    }
}
