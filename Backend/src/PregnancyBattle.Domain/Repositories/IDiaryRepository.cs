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
        /// 获取用户的所有日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        Task<(IEnumerable<Diary> Items, int TotalCount)> GetByUserIdAsync(Guid userId, int page, int pageSize, string sortBy, string sortDirection);

        /// <summary>
        /// 根据日期范围获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        Task<(IEnumerable<Diary> Items, int TotalCount)> GetByDateRangeAsync(Guid userId, DateTime startDate, DateTime endDate, int page, int pageSize, string sortBy, string sortDirection);

        /// <summary>
        /// 根据标签获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="tag">标签</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        Task<(IEnumerable<Diary> Items, int TotalCount)> GetByTagAsync(Guid userId, string tag, int page, int pageSize, string sortBy, string sortDirection);

        /// <summary>
        /// 根据情绪获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        Task<(IEnumerable<Diary> Items, int TotalCount)> GetByMoodAsync(Guid userId, string mood, int page, int pageSize, string sortBy, string sortDirection);

        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tagNames">标签名称列表</param>
        /// <returns>添加后的标签列表</returns>
        Task<IEnumerable<DiaryTag>> AddTagsAsync(Guid diaryId, IEnumerable<string> tagNames);

        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tagName">标签名称</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteTagAsync(Guid diaryId, string tagName);

        /// <summary>
        /// 添加日记媒体文件
        /// </summary>
        /// <param name="diaryId">日记ID</param>
        /// <param name="mediaType">媒体类型</param>
        /// <param name="mediaUrl">媒体URL</param>
        /// <param name="description">媒体描述</param>
        /// <returns>添加后的媒体文件</returns>
        Task<DiaryMedia> AddMediaAsync(Guid diaryId, string mediaType, string mediaUrl, string? description);

        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteMediaAsync(Guid mediaId);

        /// <summary>
        /// 根据多个条件获取用户日记（分页）
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪（可选）</param>
        /// <param name="tags">标签列表（可选）</param>
        /// <param name="startDate">开始日期（可选）</param>
        /// <param name="endDate">结束日期（可选）</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表和总数</returns>
        Task<(IEnumerable<Diary> Items, int TotalCount)> GetByMultipleFiltersAsync(
            Guid userId,
            string? mood = null,
            IEnumerable<string>? tags = null,
            DateTime? startDate = null,
            DateTime? endDate = null,
            int page = 1,
            int pageSize = 10,
            string sortBy = "diaryDate",
            string sortDirection = "desc");

        /// <summary>
        /// 获取用户所有标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>标签列表</returns>
        Task<List<string>> GetUserTagsAsync(Guid userId);
    }
}