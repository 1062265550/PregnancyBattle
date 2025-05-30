using System;
using System.Collections.Generic;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 日记实体
    /// </summary>
    public class Diary : BaseEntity
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid UserId { get; set; }

        /// <summary>
        /// 日记标题
        /// </summary>
        public required string Title { get; set; }

        /// <summary>
        /// 日记内容
        /// </summary>
        public required string Content { get; set; }

        /// <summary>
        /// 情绪状态
        /// </summary>
        public required string Mood { get; set; }

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
        /// 标签列表
        /// </summary>
        public required List<DiaryTag> Tags { get; set; }

        /// <summary>
        /// 媒体文件列表
        /// </summary>
        public required List<DiaryMedia> MediaFiles { get; set; }
    }

    /// <summary>
    /// 日记标签实体
    /// </summary>
    public class DiaryTag : BaseEntity
    {
        /// <summary>
        /// 日记ID
        /// </summary>
        public Guid DiaryId { get; set; }

        /// <summary>
        /// 标签名称
        /// </summary>
        public required string Name { get; set; }
    }

    /// <summary>
    /// 日记媒体文件实体
    /// </summary>
    public class DiaryMedia : BaseEntity
    {
        /// <summary>
        /// 日记ID
        /// </summary>
        public Guid DiaryId { get; set; }

        /// <summary>
        /// 文件ID (关联到files表，可选)
        /// </summary>
        public Guid? FileId { get; set; }

        /// <summary>
        /// 媒体类型（图片、语音、视频）
        /// </summary>
        public required string MediaType { get; set; }

        /// <summary>
        /// 媒体URL
        /// </summary>
        public required string MediaUrl { get; set; }

        /// <summary>
        /// 媒体描述
        /// </summary>
        public string? Description { get; set; }
    }
}