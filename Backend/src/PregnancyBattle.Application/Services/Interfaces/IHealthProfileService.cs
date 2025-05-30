using System;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Models;

namespace PregnancyBattle.Application.Services.Interfaces
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
        /// <param name="dto">创建健康档案请求</param>
        /// <returns>健康档案信息</returns>
        Task<ServiceResult<HealthProfileDto>> CreateHealthProfileAsync(Guid userId, CreateHealthProfileDto dto);

        /// <summary>
        /// 获取健康档案
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康档案信息</returns>
        Task<ServiceResult<HealthProfileDto>> GetHealthProfileAsync(Guid userId);

        /// <summary>
        /// 更新健康档案
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="dto">更新健康档案请求</param>
        /// <returns>健康档案信息</returns>
        Task<ServiceResult<HealthProfileDto>> UpdateHealthProfileAsync(Guid userId, UpdateHealthProfileDto dto);

        /// <summary>
        /// 记录每日体重
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="dto">体重记录请求</param>
        /// <returns>体重记录信息</returns>
        Task<ServiceResult<WeightRecordResponseDto>> CreateWeightRecordAsync(Guid userId, CreateWeightRecordDto dto);

        /// <summary>
        /// 获取体重变化趋势
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>体重变化趋势</returns>
        Task<ServiceResult<WeightTrendDto>> GetWeightTrendAsync(Guid userId);

        /// <summary>
        /// 获取健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康风险评估</returns>
        Task<ServiceResult<RiskAssessmentDto>> GetRiskAssessmentAsync(Guid userId);

        /// <summary>
        /// 强制刷新健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康风险评估</returns>
        Task<ServiceResult<RiskAssessmentDto>> RefreshRiskAssessmentAsync(Guid userId);
    }
}