using System;
using System.Collections.Generic;

namespace PregnancyBattle.Application.DTOs
{
    /// <summary>
    /// 日记DTO
    /// </summary>
    public class DiaryDto
    {
        /// <summary>
        /// 日记ID
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// 日记标题
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// 日记内容
        /// </summary>
        public string Content { get; set; }

        /// <summary>
        /// 情绪状态
        /// </summary>
        public string Mood { get; set; }

        /// <summary>
        /// 日记日期
        /// </summary>
        public DateTime DiaryDate { get; set; }

        /// <summary>
        /// 孕周
        /// </summary>
        public int? PregnancyWeek { get; set; }

        /// <summary>
        /// 孕天
        /// </summary>
        public int? PregnancyDay { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// 更新时间
        /// </summary>
        public DateTime? UpdatedAt { get; set; }

        /// <summary>
        /// 标签列表
        /// </summary>
        public List<string> Tags { get; set; } = new List<string>();

        /// <summary>
        /// 媒体文件列表
        /// </summary>
        public List<DiaryMediaDto> MediaFiles { get; set; } = new List<DiaryMediaDto>();
    }

    /// <summary>
    /// 日记标签DTO
    /// </summary>
    public class DiaryTagDto
    {
        /// <summary>
        /// 标签ID
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// 日记ID
        /// </summary>
        public Guid DiaryId { get; set; }

        /// <summary>
        /// 标签名称
        /// </summary>
        public string Name { get; set; }
    }

    /// <summary>
    /// 日记媒体文件DTO
    /// </summary>
    public class DiaryMediaDto
    {
        /// <summary>
        /// 媒体文件ID
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// 日记ID
        /// </summary>
        public Guid DiaryId { get; set; }

        /// <summary>
        /// 文件ID (关联到files表)
        /// </summary>
        public Guid? FileId { get; set; }

        /// <summary>
        /// 媒体类型
        /// </summary>
        public string MediaType { get; set; }

        /// <summary>
        /// 媒体URL
        /// </summary>
        public string MediaUrl { get; set; }

        /// <summary>
        /// 文件名称
        /// </summary>
        public string? FileName { get; set; }

        /// <summary>
        /// 文件大小（字节）
        /// </summary>
        public long? FileSize { get; set; }

        /// <summary>
        /// 媒体描述
        /// </summary>
        public string? Description { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>
    /// 创建日记请求DTO
    /// </summary>
    public class CreateDiaryDto
    {
        /// <summary>
        /// 日记标题
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// 日记内容
        /// </summary>
        public string Content { get; set; }

        /// <summary>
        /// 情绪状态
        /// </summary>
        public string Mood { get; set; }

        /// <summary>
        /// 日记日期
        /// </summary>
        public DateTime DiaryDate { get; set; }

        /// <summary>
        /// 标签列表
        /// </summary>
        public List<string> Tags { get; set; } = new List<string>();

        /// <summary>
        /// 媒体文件列表
        /// </summary>
        public List<CreateDiaryMediaDto> MediaFiles { get; set; } = new List<CreateDiaryMediaDto>();
    }

    /// <summary>
    /// 创建日记媒体文件DTO
    /// </summary>
    public class CreateDiaryMediaDto
    {
        /// <summary>
        /// 媒体类型
        /// </summary>
        public string MediaType { get; set; }

        /// <summary>
        /// 媒体URL
        /// </summary>
        public string MediaUrl { get; set; }

        /// <summary>
        /// 媒体描述
        /// </summary>
        public string? Description { get; set; }
    }

    /// <summary>
    /// 更新日记请求DTO
    /// </summary>
    public class UpdateDiaryDto
    {
        /// <summary>
        /// 日记标题
        /// </summary>
        public string? Title { get; set; }

        /// <summary>
        /// 日记内容
        /// </summary>
        public string? Content { get; set; }

        /// <summary>
        /// 情绪状态
        /// </summary>
        public string? Mood { get; set; }

        /// <summary>
        /// 日记日期
        /// </summary>
        public DateTime? DiaryDate { get; set; }
    }

    /// <summary>
    /// 添加日记媒体文件请求DTO
    /// </summary>
    public class AddDiaryMediaByUrlDto
    {
        /// <summary>
        /// 媒体类型
        /// </summary>
        public string MediaType { get; set; }

        /// <summary>
        /// 媒体URL
        /// </summary>
        public string MediaUrl { get; set; }

        /// <summary>
        /// 媒体描述
        /// </summary>
        public string? Description { get; set; }
    }

    /// <summary>
    /// 分页日记列表DTO
    /// </summary>
    public class PagedDiaryListDto
    {
        /// <summary>
        /// 日记列表
        /// </summary>
        public List<DiaryDto> Items { get; set; } = new List<DiaryDto>();

        /// <summary>
        /// 总数量
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// 总页数
        /// </summary>
        public int PageCount { get; set; }

        /// <summary>
        /// 当前页码
        /// </summary>
        public int CurrentPage { get; set; }

        /// <summary>
        /// 每页数量
        /// </summary>
        public int PageSize { get; set; }
    }

    /// <summary>
    /// 添加日记标签请求DTO
    /// </summary>
    public class AddDiaryTagsDto
    {
        /// <summary>
        /// 标签列表
        /// </summary>
        public List<string> Tags { get; set; } = new List<string>();
    }
}