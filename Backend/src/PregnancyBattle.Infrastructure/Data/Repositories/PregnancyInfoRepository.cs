using Dapper;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Infrastructure.Data.Contexts;
using System;
using System.Data;
using System.Threading.Tasks;

namespace PregnancyBattle.Infrastructure.Data.Repositories
{
    public class PregnancyInfoRepository : IPregnancyInfoRepository
    {
        private readonly IDbContext _dbContext;

        public PregnancyInfoRepository(IDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<PregnancyInfo?> GetByUserIdAsync(Guid userId)
        {
            const string sql = @"
                SELECT
                    id AS ""Id"",
                    user_id AS ""UserId"",
                    lmp_date AS ""LmpDate"",
                    due_date AS ""DueDate"",
                    calculation_method AS ""CalculationMethod"",
                    ultrasound_date AS ""UltrasoundDate"",
                    ultrasound_weeks AS ""UltrasoundWeeks"",
                    ultrasound_days AS ""UltrasoundDays"",
                    is_multiple_pregnancy AS ""IsMultiplePregnancy"",
                    fetus_count AS ""FetusCount""
                FROM pregnancy_info
                WHERE user_id = @UserId;
            ";
            using var connection = _dbContext.GetConnection();
            return await connection.QueryFirstOrDefaultAsync<PregnancyInfo>(sql, new { UserId = userId });
        }

        public async Task AddAsync(PregnancyInfo pregnancyInfo)
        {
            const string sql = @"
                INSERT INTO pregnancy_info (
                    id,
                    user_id,
                    lmp_date,
                    due_date,
                    calculation_method,
                    ultrasound_date,
                    ultrasound_weeks,
                    ultrasound_days,
                    is_multiple_pregnancy,
                    fetus_count
                ) VALUES (
                    @Id,
                    @UserId,
                    @LmpDate,
                    @DueDate,
                    @CalculationMethodString,
                    @UltrasoundDate,
                    @UltrasoundWeeks,
                    @UltrasoundDays,
                    @IsMultiplePregnancy,
                    @FetusCount
                );
            ";
            using var connection = _dbContext.GetConnection();
            await connection.ExecuteAsync(sql, new
            {
                pregnancyInfo.Id,
                pregnancyInfo.UserId,
                pregnancyInfo.LmpDate,
                pregnancyInfo.DueDate,
                CalculationMethodString = pregnancyInfo.CalculationMethod.ToString(),
                pregnancyInfo.UltrasoundDate,
                pregnancyInfo.UltrasoundWeeks,
                pregnancyInfo.UltrasoundDays,
                pregnancyInfo.IsMultiplePregnancy,
                pregnancyInfo.FetusCount
            });
        }

        public async Task UpdateAsync(PregnancyInfo pregnancyInfo)
        {
            const string sql = @"
                UPDATE pregnancy_info SET
                    lmp_date = @LmpDate,
                    due_date = @DueDate,
                    calculation_method = @CalculationMethodString,
                    ultrasound_date = @UltrasoundDate,
                    ultrasound_weeks = @UltrasoundWeeks,
                    ultrasound_days = @UltrasoundDays,
                    is_multiple_pregnancy = @IsMultiplePregnancy,
                    fetus_count = @FetusCount
                WHERE id = @Id;
            ";
            using var connection = _dbContext.GetConnection();
            await connection.ExecuteAsync(sql, new
            {
                pregnancyInfo.Id,
                pregnancyInfo.LmpDate,
                pregnancyInfo.DueDate,
                CalculationMethodString = pregnancyInfo.CalculationMethod.ToString(),
                pregnancyInfo.UltrasoundDate,
                pregnancyInfo.UltrasoundWeeks,
                pregnancyInfo.UltrasoundDays,
                pregnancyInfo.IsMultiplePregnancy,
                pregnancyInfo.FetusCount
            });
        }

        public async Task<bool> ExistsByUserIdAsync(Guid userId)
        {
            const string sql = @"
                SELECT COUNT(1)
                FROM pregnancy_info
                WHERE user_id = @UserId;
            ";
            using var connection = _dbContext.GetConnection();
            var count = await connection.ExecuteScalarAsync<int>(sql, new { UserId = userId });
            return count > 0;
        }
    }
}