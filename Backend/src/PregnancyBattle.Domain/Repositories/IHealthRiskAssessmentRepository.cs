using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Domain.Repositories
{
    /// <summary>
    /// 健康风险评估仓储接口
    /// </summary>
    public interface IHealthRiskAssessmentRepository
    {
        /// <summary>
        /// 根据用户ID获取健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康风险评估</returns>
        Task<HealthRiskAssessment?> GetByUserIdAsync(Guid userId);

        /// <summary>
        /// 根据健康档案ID获取健康风险评估
        /// </summary>
        /// <param name="healthProfileId">健康档案ID</param>
        /// <returns>健康风险评估</returns>
        Task<HealthRiskAssessment?> GetByHealthProfileIdAsync(Guid healthProfileId);

        /// <summary>
        /// 创建健康风险评估
        /// </summary>
        /// <param name="assessment">健康风险评估</param>
        /// <returns>创建的健康风险评估</returns>
        Task<HealthRiskAssessment> CreateAsync(HealthRiskAssessment assessment);

        /// <summary>
        /// 更新健康风险评估
        /// </summary>
        /// <param name="assessment">健康风险评估</param>
        /// <returns>更新的健康风险评估</returns>
        Task<HealthRiskAssessment> UpdateAsync(HealthRiskAssessment assessment);

        /// <summary>
        /// 删除健康风险评估
        /// </summary>
        /// <param name="id">风险评估ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteAsync(Guid id);

        /// <summary>
        /// 根据用户ID和健康档案ID获取健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="healthProfileId">健康档案ID</param>
        /// <returns>健康风险评估</returns>
        Task<HealthRiskAssessment?> GetByUserIdAndHealthProfileIdAsync(Guid userId, Guid healthProfileId);
    }
}
