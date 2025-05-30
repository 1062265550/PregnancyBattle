using Dapper;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Infrastructure.Data.Contexts;

namespace PregnancyBattle.Infrastructure.Repositories
{
    /// <summary>
    /// 健康风险评估仓储实现
    /// </summary>
    public class HealthRiskAssessmentRepository : IHealthRiskAssessmentRepository
    {
        private readonly IDbContext _dbContext;

        public HealthRiskAssessmentRepository(IDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// 根据用户ID获取健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>健康风险评估</returns>
        public async Task<HealthRiskAssessment?> GetByUserIdAsync(Guid userId)
        {
            const string sql = @"
                SELECT id, user_id, health_profile_id, bmi_category, bmi_risk, age_risk,
                       ai_analysis, personalized_recommendations, is_ai_enhanced,
                       health_data_hash, created_at, updated_at
                FROM health_risk_assessments
                WHERE user_id = @UserId";

            using var connection = _dbContext.GetConnection();
            return await connection.QueryFirstOrDefaultAsync<HealthRiskAssessment>(sql, new { UserId = userId });
        }

        /// <summary>
        /// 根据健康档案ID获取健康风险评估
        /// </summary>
        /// <param name="healthProfileId">健康档案ID</param>
        /// <returns>健康风险评估</returns>
        public async Task<HealthRiskAssessment?> GetByHealthProfileIdAsync(Guid healthProfileId)
        {
            const string sql = @"
                SELECT id, user_id, health_profile_id, bmi_category, bmi_risk, age_risk,
                       ai_analysis, personalized_recommendations, is_ai_enhanced,
                       health_data_hash, created_at, updated_at
                FROM health_risk_assessments
                WHERE health_profile_id = @HealthProfileId";

            using var connection = _dbContext.GetConnection();
            return await connection.QueryFirstOrDefaultAsync<HealthRiskAssessment>(sql, new { HealthProfileId = healthProfileId });
        }

        /// <summary>
        /// 创建健康风险评估
        /// </summary>
        /// <param name="assessment">健康风险评估</param>
        /// <returns>创建的健康风险评估</returns>
        public async Task<HealthRiskAssessment> CreateAsync(HealthRiskAssessment assessment)
        {
            assessment.Id = Guid.NewGuid();
            assessment.CreatedAt = DateTime.UtcNow;
            assessment.UpdatedAt = DateTime.UtcNow;

            const string sql = @"
                INSERT INTO health_risk_assessments
                (id, user_id, health_profile_id, bmi_category, bmi_risk, age_risk,
                 ai_analysis, personalized_recommendations, is_ai_enhanced,
                 health_data_hash, created_at, updated_at)
                VALUES
                (@Id, @UserId, @HealthProfileId, @BmiCategory, @BmiRisk, @AgeRisk,
                 @AiAnalysisJson::jsonb, @PersonalizedRecommendationsJson::jsonb, @IsAiEnhanced,
                 @HealthDataHash, @CreatedAt, @UpdatedAt)";

            using var connection = _dbContext.GetConnection();
            await connection.ExecuteAsync(sql, assessment);
            return assessment;
        }

        /// <summary>
        /// 更新健康风险评估
        /// </summary>
        /// <param name="assessment">健康风险评估</param>
        /// <returns>更新的健康风险评估</returns>
        public async Task<HealthRiskAssessment> UpdateAsync(HealthRiskAssessment assessment)
        {
            assessment.UpdatedAt = DateTime.UtcNow;

            const string sql = @"
                UPDATE health_risk_assessments
                SET bmi_category = @BmiCategory, bmi_risk = @BmiRisk, age_risk = @AgeRisk,
                    ai_analysis = @AiAnalysisJson::jsonb,
                    personalized_recommendations = @PersonalizedRecommendationsJson::jsonb,
                    is_ai_enhanced = @IsAiEnhanced, health_data_hash = @HealthDataHash,
                    updated_at = @UpdatedAt
                WHERE id = @Id";

            using var connection = _dbContext.GetConnection();
            await connection.ExecuteAsync(sql, assessment);
            return assessment;
        }

        /// <summary>
        /// 删除健康风险评估
        /// </summary>
        /// <param name="id">风险评估ID</param>
        /// <returns>是否删除成功</returns>
        public async Task<bool> DeleteAsync(Guid id)
        {
            const string sql = "DELETE FROM health_risk_assessments WHERE id = @Id";

            using var connection = _dbContext.GetConnection();
            var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
            return rowsAffected > 0;
        }

        /// <summary>
        /// 根据用户ID和健康档案ID获取健康风险评估
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="healthProfileId">健康档案ID</param>
        /// <returns>健康风险评估</returns>
        public async Task<HealthRiskAssessment?> GetByUserIdAndHealthProfileIdAsync(Guid userId, Guid healthProfileId)
        {
            const string sql = @"
                SELECT id, user_id, health_profile_id, bmi_category, bmi_risk, age_risk,
                       ai_analysis, personalized_recommendations, is_ai_enhanced,
                       health_data_hash, created_at, updated_at
                FROM health_risk_assessments
                WHERE user_id = @UserId AND health_profile_id = @HealthProfileId";

            using var connection = _dbContext.GetConnection();
            return await connection.QueryFirstOrDefaultAsync<HealthRiskAssessment>(sql,
                new { UserId = userId, HealthProfileId = healthProfileId });
        }
    }
}
