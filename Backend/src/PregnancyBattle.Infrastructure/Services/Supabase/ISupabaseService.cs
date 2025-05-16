using System;
using System.Threading.Tasks;

namespace PregnancyBattle.Infrastructure.Services.Supabase
{
    /// <summary>
    /// Supabase服务接口
    /// </summary>
    public interface ISupabaseService
    {
        /// <summary>
        /// 注册用户
        /// </summary>
        /// <param name="email">电子邮件</param>
        /// <param name="password">密码</param>
        /// <param name="userData">用户数据</param>
        /// <returns>用户ID</returns>
        Task<string> SignUpAsync(string email, string password, object userData);
        
        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="email">电子邮件</param>
        /// <param name="password">密码</param>
        /// <returns>登录会话</returns>
        Task<SupabaseSession> SignInAsync(string email, string password);
        
        /// <summary>
        /// 刷新令牌
        /// </summary>
        /// <param name="refreshToken">刷新令牌</param>
        /// <returns>登录会话</returns>
        Task<SupabaseSession> RefreshTokenAsync(string refreshToken);
        
        /// <summary>
        /// 上传文件
        /// </summary>
        /// <param name="bucketName">存储桶名称</param>
        /// <param name="path">文件路径</param>
        /// <param name="fileContent">文件内容</param>
        /// <param name="contentType">内容类型</param>
        /// <returns>文件URL</returns>
        Task<string> UploadFileAsync(string bucketName, string path, byte[] fileContent, string contentType);
        
        /// <summary>
        /// 删除文件
        /// </summary>
        /// <param name="bucketName">存储桶名称</param>
        /// <param name="path">文件路径</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteFileAsync(string bucketName, string path);
        
        /// <summary>
        /// 获取文件URL
        /// </summary>
        /// <param name="bucketName">存储桶名称</param>
        /// <param name="path">文件路径</param>
        /// <returns>文件URL</returns>
        string GetFileUrl(string bucketName, string path);
    }
    
    /// <summary>
    /// Supabase会话
    /// </summary>
    public class SupabaseSession
    {
        /// <summary>
        /// 访问令牌
        /// </summary>
        public string AccessToken { get; set; }
        
        /// <summary>
        /// 刷新令牌
        /// </summary>
        public string RefreshToken { get; set; }
        
        /// <summary>
        /// 用户ID
        /// </summary>
        public string UserId { get; set; }
        
        /// <summary>
        /// 过期时间
        /// </summary>
        public DateTime ExpiresAt { get; set; }
    }
}