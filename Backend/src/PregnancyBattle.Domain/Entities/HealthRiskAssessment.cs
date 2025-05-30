using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 健康风险评估实体
    /// </summary>
    [Table("health_risk_assessments")]
    public class HealthRiskAssessment
    {
        /// <summary>
        /// 风险评估ID
        /// </summary>
        [Key]
        [Column("id")]
        public Guid Id { get; set; }

        /// <summary>
        /// 用户ID
        /// </summary>
        [Column("user_id")]
        [Required]
        public Guid UserId { get; set; }

        /// <summary>
        /// 健康档案ID
        /// </summary>
        [Column("health_profile_id")]
        [Required]
        public Guid HealthProfileId { get; set; }

        /// <summary>
        /// BMI分类
        /// </summary>
        [Column("bmi_category")]
        [Required]
        [MaxLength(50)]
        public string BmiCategory { get; set; } = string.Empty;

        /// <summary>
        /// BMI风险评估
        /// </summary>
        [Column("bmi_risk")]
        [Required]
        public string BmiRisk { get; set; } = string.Empty;

        /// <summary>
        /// 年龄风险评估
        /// </summary>
        [Column("age_risk")]
        [Required]
        public string AgeRisk { get; set; } = string.Empty;

        /// <summary>
        /// AI分析结果的JSON数据
        /// </summary>
        [Column("ai_analysis", TypeName = "jsonb")]
        public string? AiAnalysisJson { get; set; }

        /// <summary>
        /// 个性化建议的JSON数据
        /// </summary>
        [Column("personalized_recommendations", TypeName = "jsonb")]
        public string? PersonalizedRecommendationsJson { get; set; }

        /// <summary>
        /// 是否使用了AI增强
        /// </summary>
        [Column("is_ai_enhanced")]
        [Required]
        public bool IsAiEnhanced { get; set; } = false;

        /// <summary>
        /// 健康档案数据的哈希值，用于判断数据是否发生变化
        /// </summary>
        [Column("health_data_hash")]
        [Required]
        [MaxLength(64)]
        public string HealthDataHash { get; set; } = string.Empty;

        /// <summary>
        /// 创建时间
        /// </summary>
        [Column("created_at")]
        [Required]
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// 更新时间
        /// </summary>
        [Column("updated_at")]
        [Required]
        public DateTime UpdatedAt { get; set; }

        // 导航属性
        public virtual User? User { get; set; }
        public virtual HealthProfile? HealthProfile { get; set; }
    }
}
