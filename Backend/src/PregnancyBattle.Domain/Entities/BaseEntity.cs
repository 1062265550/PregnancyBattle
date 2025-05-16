using System;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 基础实体类，所有实体都应继承此类
    /// </summary>
    public abstract class BaseEntity
    {
        /// <summary>
        /// 实体唯一标识
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// 最后更新时间
        /// </summary>
        public DateTime UpdatedAt { get; set; }
    }
}