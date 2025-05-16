using System;

namespace PregnancyBattle.Application.DTOs
{
    /// <summary>
    /// 孕期信息DTO
    /// </summary>
    public class PregnancyInfoDto
    {
        /// <summary>
        /// 孕期信息ID
        /// </summary>
        public Guid Id { get; set; }
        
        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid UserId { get; set; }
        
        /// <summary>
        /// 末次月经日期
        /// </summary>
        public DateTime LmpDate { get; set; }
        
        /// <summary>
        /// 预产期
        /// </summary>
        public DateTime DueDate { get; set; }
        
        /// <summary>
        /// 预产期计算方式
        /// </summary>
        public string CalculationMethod { get; set; }
        
        /// <summary>
        /// B超日期
        /// </summary>
        public DateTime? UltrasoundDate { get; set; }
        
        /// <summary>
        /// B超孕周
        /// </summary>
        public int? UltrasoundWeeks { get; set; }
        
        /// <summary>
        /// B超孕天
        /// </summary>
        public int? UltrasoundDays { get; set; }
        
        /// <summary>
        /// 是否为多胎妊娠
        /// </summary>
        public bool IsMultiplePregnancy { get; set; }
        
        /// <summary>
        /// 胎儿数量
        /// </summary>
        public int? FetusCount { get; set; }
        
        /// <summary>
        /// 当前孕周
        /// </summary>
        public int CurrentWeek { get; set; }
        
        /// <summary>
        /// 当前孕天
        /// </summary>
        public int CurrentDay { get; set; }
        
        /// <summary>
        /// 孕期阶段 (早期/中期/晚期)
        /// </summary>
        public string PregnancyStage { get; set; }
        
        /// <summary>
        /// 距离预产期天数
        /// </summary>
        public int DaysUntilDueDate { get; set; }
    }
    
    /// <summary>
    /// 创建孕期信息请求DTO
    /// </summary>
    public class CreatePregnancyInfoDto
    {
        /// <summary>
        /// 末次月经日期
        /// </summary>
        public DateTime LmpDate { get; set; }
        
        /// <summary>
        /// 预产期计算方式
        /// </summary>
        public string CalculationMethod { get; set; } = "LMP";
        
        /// <summary>
        /// B超日期
        /// </summary>
        public DateTime? UltrasoundDate { get; set; }
        
        /// <summary>
        /// B超孕周
        /// </summary>
        public int? UltrasoundWeeks { get; set; }
        
        /// <summary>
        /// B超孕天
        /// </summary>
        public int? UltrasoundDays { get; set; }
        
        /// <summary>
        /// 是否为多胎妊娠
        /// </summary>
        public bool IsMultiplePregnancy { get; set; }
        
        /// <summary>
        /// 胎儿数量
        /// </summary>
        public int? FetusCount { get; set; }
    }
    
    /// <summary>
    /// 更新孕期信息请求DTO
    /// </summary>
    public class UpdatePregnancyInfoDto
    {
        /// <summary>
        /// 预产期
        /// </summary>
        public DateTime? DueDate { get; set; }
        
        /// <summary>
        /// 预产期计算方式
        /// </summary>
        public string CalculationMethod { get; set; }
        
        /// <summary>
        /// B超日期
        /// </summary>
        public DateTime? UltrasoundDate { get; set; }
        
        /// <summary>
        /// B超孕周
        /// </summary>
        public int? UltrasoundWeeks { get; set; }
        
        /// <summary>
        /// B超孕天
        /// </summary>
        public int? UltrasoundDays { get; set; }
        
        /// <summary>
        /// 是否为多胎妊娠
        /// </summary>
        public bool? IsMultiplePregnancy { get; set; }
        
        /// <summary>
        /// 胎儿数量
        /// </summary>
        public int? FetusCount { get; set; }
    }
}