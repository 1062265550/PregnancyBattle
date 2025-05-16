using System;

namespace PregnancyBattle.Application.DTOs
{
    /// <summary>
    /// 健康档案DTO
    /// </summary>
    public class HealthProfileDto
    {
        /// <summary>
        /// 健康档案ID
        /// </summary>
        public Guid Id { get; set; }
        
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
        public string BloodType { get; set; }
        
        /// <summary>
        /// 年龄
        /// </summary>
        public int Age { get; set; }
        
        /// <summary>
        /// 个人病史
        /// </summary>
        public string MedicalHistory { get; set; }
        
        /// <summary>
        /// 家族病史
        /// </summary>
        public string FamilyHistory { get; set; }
        
        /// <summary>
        /// 过敏史
        /// </summary>
        public string AllergiesHistory { get; set; }
        
        /// <summary>
        /// 既往孕产史
        /// </summary>
        public string ObstetricHistory { get; set; }
        
        /// <summary>
        /// 是否吸烟
        /// </summary>
        public bool IsSmoking { get; set; }
        
        /// <summary>
        /// 是否饮酒
        /// </summary>
        public bool IsDrinking { get; set; }
        
        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; }
        
        /// <summary>
        /// 更新时间
        /// </summary>
        public DateTime? UpdatedAt { get; set; }
        
        /// <summary>
        /// BMI指数
        /// </summary>
        public decimal BMI => Height > 0 ? Math.Round(CurrentWeight / ((Height / 100) * (Height / 100)), 2) : 0;
    }
    
    /// <summary>
    /// 创建健康档案请求DTO
    /// </summary>
    public class CreateHealthProfileDto
    {
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
        public string BloodType { get; set; }
        
        /// <summary>
        /// 年龄
        /// </summary>
        public int Age { get; set; }
        
        /// <summary>
        /// 个人病史
        /// </summary>
        public string MedicalHistory { get; set; }
        
        /// <summary>
        /// 家族病史
        /// </summary>
        public string FamilyHistory { get; set; }
        
        /// <summary>
        /// 过敏史
        /// </summary>
        public string AllergiesHistory { get; set; }
        
        /// <summary>
        /// 既往孕产史
        /// </summary>
        public string ObstetricHistory { get; set; }
        
        /// <summary>
        /// 是否吸烟
        /// </summary>
        public bool IsSmoking { get; set; }
        
        /// <summary>
        /// 是否饮酒
        /// </summary>
        public bool IsDrinking { get; set; }
    }
    
    /// <summary>
    /// 更新健康档案请求DTO
    /// </summary>
    public class UpdateHealthProfileDto
    {
        /// <summary>
        /// 身高（厘米）
        /// </summary>
        public decimal? Height { get; set; }
        
        /// <summary>
        /// 当前体重（千克）
        /// </summary>
        public decimal? CurrentWeight { get; set; }
        
        /// <summary>
        /// 血型
        /// </summary>
        public string BloodType { get; set; }
        
        /// <summary>
        /// 个人病史
        /// </summary>
        public string MedicalHistory { get; set; }
        
        /// <summary>
        /// 家族病史
        /// </summary>
        public string FamilyHistory { get; set; }
        
        /// <summary>
        /// 过敏史
        /// </summary>
        public string AllergiesHistory { get; set; }
        
        /// <summary>
        /// 既往孕产史
        /// </summary>
        public string ObstetricHistory { get; set; }
        
        /// <summary>
        /// 是否吸烟
        /// </summary>
        public bool? IsSmoking { get; set; }
        
        /// <summary>
        /// 是否饮酒
        /// </summary>
        public bool? IsDrinking { get; set; }
    }
}