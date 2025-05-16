using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Services
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
        /// <returns>日记列表</returns>
        Task<IEnumerable<DiaryDto>> GetUserDiariesAsync(Guid userId);
        
        /// <summary>
        /// 根据日期范围获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="startDate">开始日期</param>
        /// <param name="endDate">结束日期</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<DiaryDto>> GetDiariesByDateRangeAsync(Guid userId, DateTime startDate, DateTime endDate);
        
        /// <summary>
        /// 根据标签获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="tag">标签</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<DiaryDto>> GetDiariesByTagAsync(Guid userId, string tag);
        
        /// <summary>
        /// 根据情绪获取日记
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="mood">情绪</param>
        /// <returns>日记列表</returns>
        Task<IEnumerable<DiaryDto>> GetDiariesByMoodAsync(Guid userId, string mood);
        
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
        /// <param name="tagName">标签名称</param>
        /// <returns>标签信息</returns>
        Task<DiaryTagDto> AddDiaryTagAsync(Guid userId, Guid diaryId, string tagName);
        
        /// <summary>
        /// 删除日记标签
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="tagId">标签ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteDiaryTagAsync(Guid userId, Guid diaryId, Guid tagId);
        
        /// <summary>
        /// 添加日记媒体文件
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="addDiaryMediaDto">添加媒体文件请求</param>
        /// <returns>媒体文件信息</returns>
        Task<DiaryMediaDto> AddDiaryMediaAsync(Guid userId, Guid diaryId, AddDiaryMediaDto addDiaryMediaDto);
        
        /// <summary>
        /// 删除日记媒体文件
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="diaryId">日记ID</param>
        /// <param name="mediaId">媒体文件ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteDiaryMediaAsync(Guid userId, Guid diaryId, Guid mediaId);
    }
}