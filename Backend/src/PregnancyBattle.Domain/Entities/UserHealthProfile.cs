using System;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 用户健康档案实体
    /// </summary>
    public class UserHealthProfile : BaseEntity
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid UserId { get; set; }
        
        /// <summary>
        /// 身高（厘米）
        /// </summary>
        public decimal Height { get; set; }
        
        /// <summary>
        /// 孕前体重（千克）
        /// </summary>
        public decimal PrePregnancyWeight { get; set; }
        
        /// <summary>
        /// 当前体重（千克）
        /// </summary>
        public decimal CurrentWeight { get; set; }
        
        /// <summary>
        /// 血型
        /// </summary>
        public required string BloodType { get; set; }
        
        /// <summary>
        /// 年龄
        /// </summary>
        public int Age { get; set; }
        
        /// <summary>
        /// 个人病史
        /// </summary>
        public required string MedicalHistory { get; set; }
        
        /// <summary>
        /// 家族病史
        /// </summary>
        public required string FamilyHistory { get; set; }
        
        /// <summary>
        /// 过敏史
        /// </summary>
        public required string AllergiesHistory { get; set; }
        
        /// <summary>
        /// 既往孕产史
        /// </summary>
        public required string ObstetricHistory { get; set; }
        
        /// <summary>
        /// 是否吸烟
        /// </summary>
        public bool IsSmoking { get; set; }
        
        /// <summary>
        /// 是否饮酒
        /// </summary>
        public bool IsDrinking { get; set; }
    }
}