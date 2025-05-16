using System;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 孕期信息实体
    /// </summary>
    public class PregnancyInfo : BaseEntity
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid UserId { get; set; }
        
        /// <summary>
        /// 末次月经日期 (Last Menstrual Period)
        /// </summary>
        public DateTime LmpDate { get; set; }
        
        /// <summary>
        /// 预产期
        /// </summary>
        public DateTime DueDate { get; set; }
        
        /// <summary>
        /// 预产期计算方式
        /// </summary>
        public string CalculationMethod { get; set; } // LMP, B超, IVF
        
        /// <summary>
        /// B超日期（如果有）
        /// </summary>
        public DateTime? UltrasoundDate { get; set; }
        
        /// <summary>
        /// B超孕周（如果有）
        /// </summary>
        public int? UltrasoundWeeks { get; set; }
        
        /// <summary>
        /// B超孕天（如果有）
        /// </summary>
        public int? UltrasoundDays { get; set; }
        
        /// <summary>
        /// 是否为多胎妊娠
        /// </summary>
        public bool IsMultiplePregnancy { get; set; }
        
        /// <summary>
        /// 胎儿数量（如果是多胎）
        /// </summary>
        public int? FetusCount { get; set; }
    }
}