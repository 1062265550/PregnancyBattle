using Dapper;
using Microsoft.Extensions.Configuration;
using Npgsql;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PregnancyBattle.Infrastructure.Data.Repositories
{
    public class HealthProfileRepository : IHealthProfileRepository
    {
        private readonly string _connectionString;

        public HealthProfileRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("DefaultConnection string is not configured.");
        }

        public async Task<HealthProfile?> GetHealthProfileByUserIdAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT * FROM user_health_profiles WHERE user_id = @UserId";
            return await connection.QuerySingleOrDefaultAsync<HealthProfile>(sql, new { UserId = userId });
        }

        public async Task CreateHealthProfileAsync(HealthProfile healthProfile)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                INSERT INTO user_health_profiles
                (id, user_id, height, pre_pregnancy_weight, current_weight, blood_type, age, medical_history, family_history, allergies_history, obstetric_history, is_smoking, is_drinking, created_at, updated_at)
                VALUES
                (@Id, @UserId, @Height, @PrePregnancyWeight, @CurrentWeight, @BloodType, @Age, @MedicalHistory, @FamilyHistory, @AllergiesHistory, @ObstetricHistory, @IsSmoking, @IsDrinking, @CreatedAt, @UpdatedAt)";
            await connection.ExecuteAsync(sql, healthProfile);
        }

        public async Task UpdateHealthProfileAsync(HealthProfile healthProfile)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                UPDATE user_health_profiles SET
                height = @Height,
                pre_pregnancy_weight = @PrePregnancyWeight,
                current_weight = @CurrentWeight,
                blood_type = @BloodType,
                medical_history = @MedicalHistory,
                family_history = @FamilyHistory,
                allergies_history = @AllergiesHistory,
                obstetric_history = @ObstetricHistory,
                is_smoking = @IsSmoking,
                is_drinking = @IsDrinking,
                updated_at = @UpdatedAt
                WHERE id = @Id AND user_id = @UserId";
            await connection.ExecuteAsync(sql, healthProfile);
        }

        public async Task<bool> HealthProfileExistsAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT COUNT(1) FROM user_health_profiles WHERE user_id = @UserId";
            var count = await connection.ExecuteScalarAsync<int>(sql, new { UserId = userId });
            return count > 0;
        }

        // WeightLog methods
        public async Task AddWeightLogAsync(WeightLog weightLog)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                INSERT INTO weight_records
                (id, user_id, record_date, weight, pregnancy_week, pregnancy_day, note, created_at, updated_at)
                VALUES
                (@Id, @UserId, @Date, @Weight, @PregnancyWeek, @PregnancyDay, @Note, @CreatedAt, @UpdatedAt)";
            await connection.ExecuteAsync(sql, weightLog);
        }

        public async Task<IEnumerable<WeightLog>> GetWeightLogsByUserIdAsync(Guid userId, DateTime? startDate, DateTime? endDate)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            // 构建基本SQL查询
            var sql = "SELECT * FROM weight_records WHERE user_id = @UserId";
            var parameters = new DynamicParameters();
            parameters.Add("@UserId", userId);

            // 添加日期过滤条件
            if (startDate.HasValue)
            {
                sql += " AND record_date >= @StartDate";
                parameters.Add("@StartDate", startDate.Value);
            }
            if (endDate.HasValue)
            {
                sql += " AND record_date <= @EndDate";
                parameters.Add("@EndDate", endDate.Value);
            }

            // 添加排序
            sql += " ORDER BY record_date ASC";

            return await connection.QueryAsync<WeightLog>(sql, parameters);
        }

        public async Task<WeightLog?> GetLatestWeightLogByUserIdAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT * FROM weight_records WHERE user_id = @UserId ORDER BY record_date DESC LIMIT 1";
            return await connection.QuerySingleOrDefaultAsync<WeightLog>(sql, new { UserId = userId });
        }

        public async Task<WeightLog?> GetWeightLogByUserIdAndDateAsync(Guid userId, DateTime date)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT * FROM weight_records WHERE user_id = @UserId AND record_date = @Date";
            return await connection.QuerySingleOrDefaultAsync<WeightLog>(sql, new { UserId = userId, Date = date.Date });
        }

        public async Task UpdateWeightLogAsync(WeightLog weightLog)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                UPDATE weight_records
                SET weight = @Weight,
                    pregnancy_week = @PregnancyWeek,
                    pregnancy_day = @PregnancyDay,
                    note = @Note,
                    updated_at = @UpdatedAt
                WHERE id = @Id";
            await connection.ExecuteAsync(sql, weightLog);
        }

        public async Task AddOrUpdateWeightLogAsync(WeightLog weightLog)
        {
            using var connection = new NpgsqlConnection(_connectionString);

            // 首先检查是否存在当天的记录
            var existingLog = await GetWeightLogByUserIdAndDateAsync(weightLog.UserId, weightLog.Date);

            if (existingLog != null)
            {
                // 更新现有记录
                existingLog.Weight = weightLog.Weight;
                existingLog.PregnancyWeek = weightLog.PregnancyWeek;
                existingLog.PregnancyDay = weightLog.PregnancyDay;
                existingLog.Note = weightLog.Note;
                existingLog.UpdatedAt = DateTime.UtcNow;

                await UpdateWeightLogAsync(existingLog);
            }
            else
            {
                // 添加新记录
                await AddWeightLogAsync(weightLog);
            }
        }
    }
}