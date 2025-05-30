using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Services.Interfaces
{
    /// <summary>
    /// 日记服务接口
    /// </summary>
    public interface IDiaryService
    {
        /// <summary>
        /// 创建日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="createDiaryDto">创建日记请求</param>
        /// <returns>日记信息</returns>
        Task<DiaryDto> CreateDiaryAsync(Guid userId, CreateDiaryDto createDiaryDto);

        /// <summary>
        /// 获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <returns>日记信息</returns>
        Task<DiaryDto> GetDiaryAsync(Guid userId, Guid diaryId);

        /// <summary>
        /// 获取用户所有日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        Task<PagedDiaryListDto> GetUserDiariesAsync(Guid userId, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc");

        /// <summary>
        /// 根据日期范围获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        Task<PagedDiaryListDto> GetDiariesByDateRangeAsync(Guid userId, DateTime startDate, DateTime endDate, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc");

        /// <summary>
        /// 根据标签获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="tag">标签</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        Task<PagedDiaryListDto> GetDiariesByTagAsync(Guid userId, string tag, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc");

        /// <summary>
        /// 根据情绪获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪</param>
        /// <param name="page">页码</param>
        /// <param name="pageSize">每页数量</param>
        /// <param name="sortBy">排序字段</param>
        /// <param name="sortDirection">排序方向</param>
        /// <returns>分页日记列表</returns>
        Task<PagedDiaryListDto> GetDiariesByMoodAsync(Guid userId, string mood, int page = 1, int pageSize = 10, string sortBy = "diaryDate", string sortDirection = "desc");

        /// <summary>
        /// 更新日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="updateDiaryDto">更新日记请求</param>
        /// <returns>日记信息</returns>
        Task<DiaryDto> UpdateDiaryAsync(Guid userId, Guid diaryId, UpdateDiaryDto updateDiaryDto);

        /// <summary>
        /// 删除日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteDiaryAsync(Guid userId, Guid diaryId);

        /// <summary>
        /// 添加日记标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="addDiaryTagsDto">添加标签请求</param>
        /// <returns>更新后的日记信息</returns>
        Task<DiaryDto> AddDiaryTagsAsync(Guid userId, Guid diaryId, AddDiaryTagsDto addDiaryTagsDto);

        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tag">标签名称</param>
        /// <returns>更新后的日记信息</returns>
        Task<DiaryDto> DeleteDiaryTagAsync(Guid userId, Guid diaryId, string tag);

        /// <summary>
        /// 添加日记媒体文件 (使用URL)
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="addDiaryMediaDto">添加媒体文件请求</param>
        /// <returns>媒体文件信息</returns>
        Task<DiaryMediaDto> AddDiaryMediaAsync(Guid userId, Guid diaryId, AddDiaryMediaByUrlDto addDiaryMediaDto);

        /// <summary>
        /// 上传并添加日记媒体文件
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="file">媒体文件</param>
        /// <param name="mediaType">媒体类型</param>
        /// <param name="description">文件描述</param>
        /// <returns>媒体文件信息</returns>
        Task<DiaryMediaDto> UploadDiaryMediaAsync(Guid userId, Guid diaryId, Microsoft.AspNetCore.Http.IFormFile file, string mediaType, string? description);

        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteDiaryMediaAsync(Guid userId, Guid diaryId, Guid mediaId);

        /// <summary>
        /// 根据多个条件获取日记
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
        /// <returns>分页日记列表</returns>
        Task<PagedDiaryListDto> GetDiariesByMultipleFiltersAsync(
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