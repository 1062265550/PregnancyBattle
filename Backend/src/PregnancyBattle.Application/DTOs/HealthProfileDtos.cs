using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace PregnancyBattle.Application.DTOs
{
    // VII.1 & VII.2
    public class HealthProfileDto
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public decimal Height { get; set; }
        public decimal PrePregnancyWeight { get; set; }
        public decimal CurrentWeight { get; set; }
        public string BloodType { get; set; } = string.Empty;
        public int Age { get; set; }
        public string? MedicalHistory { get; set; }
        public string? FamilyHistory { get; set; }
        public string? AllergiesHistory { get; set; }
        public string? ObstetricHistory { get; set; }
        public bool IsSmoking { get; set; }
        public bool IsDrinking { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public decimal Bmi { get; set; }
    }

    // VII.1
    public class CreateHealthProfileDto
    {
        public decimal Height { get; set; } // 身高（厘米），必填，100-250厘米
        public decimal PrePregnancyWeight { get; set; } // 孕前体重（千克），必填，30-200千克
        public decimal CurrentWeight { get; set; } // 当前体重（千克），必填，30-200千克
        public string BloodType { get; set; } = string.Empty; // 血型，必填
        public int Age { get; set; } // 年龄，必填，18-60岁
        public string? MedicalHistory { get; set; } // 个人病史，选填
        public string? FamilyHistory { get; set; } // 家族病史，选填
        public string? AllergiesHistory { get; set; } // 过敏史，选填
        public string? ObstetricHistory { get; set; } // 既往孕产史，选填
        public bool? IsSmoking { get; set; } // 是否吸烟，选填，默认为false
        public bool? IsDrinking { get; set; } // 是否饮酒，选填，默认为false
    }

    // VII.3
    public class UpdateHealthProfileDto
    {
        public decimal? Height { get; set; } // 身高（厘米），选填，100-250厘米
        public decimal? PrePregnancyWeight { get; set; } // 孕前体重（千克），选填，30-200千克
        public decimal? CurrentWeight { get; set; } // 当前体重（千克），选填，30-200千克
        public string? BloodType { get; set; } // 血型，选填
        public string? MedicalHistory { get; set; } // 个人病史，选填
        public string? FamilyHistory { get; set; } // 家族病史，选填
        public string? AllergiesHistory { get; set; } // 过敏史，选填
        public string? ObstetricHistory { get; set; } // 既往孕产史，选填
        public bool? IsSmoking { get; set; } // 是否吸烟，选填
        public bool? IsDrinking { get; set; } // 是否饮酒，选填
    }

    // VII.4 - 记录每日体重请求
    public class CreateWeightRecordDto
    {
        [Required]
        [Range(30.0, 200.0, ErrorMessage = "体重必须在30-200千克之间")]
        public decimal Weight { get; set; } // 体重（千克）

        public DateTime? RecordDate { get; set; } // 记录日期，选填，默认为今天

        [StringLength(500, ErrorMessage = "备注不能超过500个字符")]
        public string? Note { get; set; } // 备注，选填
    }

    // VII.4 - 体重记录响应
    public class WeightRecordResponseDto
    {
        public Guid Id { get; set; } // 体重记录ID
        public Guid UserId { get; set; } // 用户ID
        public decimal Weight { get; set; } // 体重（千克）
        public DateTime RecordDate { get; set; } // 记录日期
        public int? PregnancyWeek { get; set; } // 孕周
        public int? PregnancyDay { get; set; } // 孕天
        public string? Note { get; set; } // 备注
        public DateTime CreatedAt { get; set; } // 创建时间
        public DateTime UpdatedAt { get; set; } // 更新时间
    }

    // VII.5 - 体重变化趋势中的记录
    public class WeightRecordDto
    {
        public DateTime Date { get; set; } // 记录日期
        public decimal Weight { get; set; } // 体重（千克）
        public int PregnancyWeek { get; set; } // 孕周
        public int PregnancyDay { get; set; } // 孕天
    }

    public class RecommendedWeightGainDto
    {
        public decimal Min { get; set; } // 推荐最小增重
        public decimal Max { get; set; } // 推荐最大增重
    }

    public class WeightTrendDto
    {
        public List<WeightRecordDto> WeightRecords { get; set; } = new List<WeightRecordDto>();
        public decimal StartWeight { get; set; } // 起始体重 (孕前体重)
        public decimal CurrentWeight { get; set; } // 当前体重
        public decimal WeightGain { get; set; } // 增重
        public RecommendedWeightGainDto RecommendedWeightGain { get; set; } = new RecommendedWeightGainDto();
    }

    // VII.5
    public class MedicalRiskDto
    {
        public string Type { get; set; } = string.Empty; // 风险类型
        public string Description { get; set; } = string.Empty; // 风险描述
        public string Severity { get; set; } = string.Empty; // 严重程度（低/中/高）
    }

    public class RecommendationDto
    {
        public string Category { get; set; } = string.Empty; // 建议类别
        public string Description { get; set; } = string.Empty; // 建议描述
    }

    public class RiskAssessmentDto
    {
        public string BmiCategory { get; set; } = string.Empty; // BMI分类（偏瘦/正常/超重/肥胖）
        public string BmiRisk { get; set; } = string.Empty; // BMI风险评估
        public string AgeRisk { get; set; } = string.Empty; // 年龄风险评估
        public List<MedicalRiskDto> MedicalRisks { get; set; } = new List<MedicalRiskDto>();
        public List<RecommendationDto> Recommendations { get; set; } = new List<RecommendationDto>();

        // AI增强分析结果
        public HealthRiskAnalysisDto? AiAnalysis { get; set; } // AI分析结果
        public PersonalizedRecommendationsDto? PersonalizedRecommendations { get; set; } // 个性化建议
        public bool IsAiEnhanced { get; set; } = false; // 是否使用了AI增强
    }

    /// <summary>
    /// AI健康风险分析DTO
    /// </summary>
    public class HealthRiskAnalysisDto
    {
        public string OverallAssessment { get; set; } = string.Empty; // 整体评估
        public List<DetailedAnalysisDto> DetailedAnalyses { get; set; } = new List<DetailedAnalysisDto>(); // 详细分析
        public string ComprehensiveRecommendation { get; set; } = string.Empty; // 综合建议
        public int RiskScore { get; set; } // 风险评分 (1-10)
        public string RiskLevel { get; set; } = string.Empty; // 风险等级 (低/中/高)
    }

    /// <summary>
    /// 详细分析DTO
    /// </summary>
    public class DetailedAnalysisDto
    {
        public string Category { get; set; } = string.Empty; // 分析类别 (BMI/年龄/病史/生活习惯等)
        public string DataValue { get; set; } = string.Empty; // 数据值
        public string Analysis { get; set; } = string.Empty; // 详细分析
        public string Impact { get; set; } = string.Empty; // 对孕期的影响
        public string Recommendation { get; set; } = string.Empty; // 针对性建议
        public string Severity { get; set; } = string.Empty; // 严重程度 (低/中/高)
    }

    /// <summary>
    /// 个性化建议DTO
    /// </summary>
    public class PersonalizedRecommendationsDto
    {
        public List<CategoryRecommendationDto> CategoryRecommendations { get; set; } = new List<CategoryRecommendationDto>(); // 分类建议
        public string DietPlan { get; set; } = string.Empty; // 饮食计划
        public string ExercisePlan { get; set; } = string.Empty; // 运动计划
        public string LifestyleAdjustments { get; set; } = string.Empty; // 生活方式调整
        public string MonitoringAdvice { get; set; } = string.Empty; // 监测建议
        public List<string> WarningSignsToWatch { get; set; } = new List<string>(); // 需要关注的警告信号
    }

    /// <summary>
    /// 分类建议DTO
    /// </summary>
    public class CategoryRecommendationDto
    {
        public string Category { get; set; } = string.Empty; // 建议类别
        public string Title { get; set; } = string.Empty; // 建议标题
        public string Description { get; set; } = string.Empty; // 详细描述
        public string Priority { get; set; } = string.Empty; // 优先级 (高/中/低)
        public List<string> ActionItems { get; set; } = new List<string>(); // 具体行动项
    }
}