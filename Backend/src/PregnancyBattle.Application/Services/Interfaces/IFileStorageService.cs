

namespace PregnancyBattle.Application.Services.Interfaces
{
    /// <summary>
    /// 文件存储服务接口
    /// </summary>
    public interface IFileStorageService
    {
        /// <summary>
        /// 上传文件
        /// </summary>
        /// <param name="fileData">文件数据</param>
        /// <param name="fileName">文件名</param>
        /// <param name="contentType">文件类型</param>
        /// <param name="folder">存储文件夹，默认为"uploads"</param>
        /// <returns>文件访问URL</returns>
        Task<string> UploadFileAsync(byte[] fileData, string fileName, string contentType, string folder = "uploads");

        /// <summary>
        /// 上传文件流
        /// </summary>
        /// <param name="fileStream">文件流</param>
        /// <param name="fileName">文件名</param>
        /// <param name="contentType">文件类型</param>
        /// <param name="folder">存储文件夹，默认为"uploads"</param>
        /// <returns>文件访问URL</returns>
        Task<string> UploadFileAsync(Stream fileStream, string fileName, string contentType, string folder = "uploads");

        /// <summary>
        /// 删除文件
        /// </summary>
        /// <param name="fileUrl">文件URL</param>
        /// <returns>删除是否成功</returns>
        Task<bool> DeleteFileAsync(string fileUrl);

        /// <summary>
        /// 获取文件访问URL
        /// </summary>
        /// <param name="filePath">文件路径</param>
        /// <returns>文件访问URL</returns>
        string GetFileUrl(string filePath);

        /// <summary>
        /// 检查文件是否存在
        /// </summary>
        /// <param name="filePath">文件路径</param>
        /// <returns>文件是否存在</returns>
        Task<bool> FileExistsAsync(string filePath);
    }
}
