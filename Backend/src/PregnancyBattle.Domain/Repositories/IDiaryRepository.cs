using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Domain.Repositories
{
    /// <summary>
    /// 日记仓储接口
    /// </summary>
    public interface IDiaryRepository : IRepository<Diary>
    {
        /// <summary>
        /// 获取用户的所有日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<Diary>> GetByUserIdAsync(Guid userId);
        
        /// <summary>
        /// 根据日期范围获取用户日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<Diary>> GetByDateRangeAsync(Guid userId, DateTime startDate, DateTime endDate);
        
        /// <summary>
        /// 根据标签获取用户日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="tag">标签</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<Diary>> GetByTagAsync(Guid userId, string tag);
        
        /// <summary>
        /// 根据情绪获取用户日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<Diary>> GetByMoodAsync(Guid userId, string mood);
        
        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tagName">标签名称</param>
        /// <returns>添加后的标签</returns>
        Task<DiaryTag> AddTagAsync(Guid diaryId, string tagName);
        
        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="tagId">标签ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteTagAsync(Guid tagId);
        
        /// <summary>
        /// 添加日记媒体文件
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="mediaType">媒体类型</param>
        /// <param name="mediaUrl">媒体URL</param>
        /// <param name="description">媒体描述</param>
        /// <returns>添加后的媒体文件</returns>
        Task<DiaryMedia> AddMediaAsync(Guid diaryId, string mediaType, string mediaUrl, string description);
        
        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteMediaAsync(Guid mediaId);
    }
}