using System;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Services
{
    /// <summary>
    /// 健康档案服务接口
    /// </summary>
    public interface IHealthProfileService
    {
        /// <summary>
        /// 创建健康档案
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="createHealthProfileDto">创建健康档案请求</param>
        /// <returns>健康档案信息</returns>
        Task<HealthProfileDto> CreateHealthProfileAsync(Guid userId, CreateHealthProfileDto createHealthProfileDto);
        
        /// <summary>
        /// 获取健康档案
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康档案信息</returns>
        Task<HealthProfileDto> GetHealthProfileAsync(Guid userId);
        
        /// <summary>
        /// 更新健康档案
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="updateHealthProfileDto">更新健康档案请求</param>
        /// <returns>健康档案信息</returns>
        Task<HealthProfileDto> UpdateHealthProfileAsync(Guid userId, UpdateHealthProfileDto updateHealthProfileDto);
        
        /// <summary>
        /// 获取体重变化趋势
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>体重变化趋势</returns>
        Task<object> GetWeightTrendAsync(Guid userId);
        
        /// <summary>
        /// 获取健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康风险评估</returns>
        Task<object> GetHealthRiskAssessmentAsync(Guid userId);
    }
}