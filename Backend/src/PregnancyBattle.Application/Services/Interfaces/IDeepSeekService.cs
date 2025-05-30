using System;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Models;

namespace PregnancyBattle.Application.Services.Interfaces
{
    /// <summary>
    /// DeepSeek AI服务接口
    /// </summary>
    public interface IDeepSeekService
    {
        /// <summary>
        /// 生成健康风险评估分析
        /// </summary>
        /// <param name="healthProfile">健康档案信息</param>
        /// <param name="pregnancyInfo">孕期信息</param>
        /// <returns>AI分析结果</returns>
        Task<ServiceResult<HealthRiskAnalysisDto>> GenerateHealthRiskAnalysisAsync(
            HealthProfileDto healthProfile, 
            PregnancyInfoDto? pregnancyInfo = null);

        /// <summary>
        /// 生成个性化健康建议
        /// </summary>
        /// <param name="healthProfile">健康档案信息</param>
        /// <param name="pregnancyInfo">孕期信息</param>
        /// <param name="riskFactors">识别的风险因素</param>
        /// <returns>个性化建议</returns>
        Task<ServiceResult<PersonalizedRecommendationsDto>> GeneratePersonalizedRecommendationsAsync(
            HealthProfileDto healthProfile,
            PregnancyInfoDto? pregnancyInfo,
            List<string> riskFactors);

        /// <summary>
        /// 检查服务可用性
        /// </summary>
        /// <returns>服务是否可用</returns>
        Task<bool> IsServiceAvailableAsync();
    }
}
