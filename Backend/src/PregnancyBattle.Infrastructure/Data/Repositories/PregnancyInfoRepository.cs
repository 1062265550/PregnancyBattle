using Dapper;
using Microsoft.Extensions.Configuration;
using Npgsql;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Enums;
using PregnancyBattle.Domain.Repositories;
using System;
using System.Reflection;
using System.Threading.Tasks;

namespace PregnancyBattle.Infrastructure.Data.Repositories
{
    public class PregnancyInfoRepository : IPregnancyInfoRepository
    {
        private readonly string _connectionString;

        public PregnancyInfoRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("DefaultConnection string is not configured.");
        }

        public async Task<PregnancyInfo?> GetPregnancyInfoByUserIdAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            // 使用明确的列名映射，确保user_id正确映射到UserId属性
            const string sql = @"
                SELECT
                    id,
                    user_id,
                    lmp_date,
                    due_date,
                    calculation_method,
                    ultrasound_date,
                    ultrasound_weeks,
                    ultrasound_days,
                    ivf_transfer_date,
                    ivf_embryo_age,
                    is_multiple_pregnancy,
                    fetus_count,
                    created_at,
                    updated_at
                FROM pregnancy_info
                WHERE user_id = @UserId";

            var result = await connection.QuerySingleOrDefaultAsync<dynamic>(sql, new { UserId = userId });

            if (result == null)
                return null;

            // 手动将查询结果映射到PregnancyInfo实体
            Guid id = result.id;
            Guid dbUserId = result.user_id;
            DateTime lmpDate = result.lmp_date;
            PregnancyCalculationMethod calculationMethod = Enum.Parse<PregnancyCalculationMethod>(result.calculation_method);
            DateTime? ultrasoundDate = result.ultrasound_date;
            int? ultrasoundWeeks = result.ultrasound_weeks;
            int? ultrasoundDays = result.ultrasound_days;
            DateTime? ivfTransferDate = result.ivf_transfer_date;
            int? ivfEmbryoAge = result.ivf_embryo_age;
            bool isMultiplePregnancy = result.is_multiple_pregnancy;
            int? fetusCount = result.fetus_count;

            // 使用构造函数创建PregnancyInfo实例
            var pregnancyInfo = new PregnancyInfo(
                dbUserId,
                lmpDate,
                calculationMethod,
                ultrasoundDate,
                ultrasoundWeeks,
                ultrasoundDays,
                isMultiplePregnancy,
                fetusCount,
                ivfTransferDate,
                ivfEmbryoAge);

            // 使用反射设置ID，因为ID是在构造函数中自动生成的，但我们需要使用数据库中的ID
            typeof(PregnancyInfo).GetProperty("Id")?.SetValue(pregnancyInfo, id);

            return pregnancyInfo;
        }

        public async Task CreatePregnancyInfoAsync(PregnancyInfo pregnancyInfo)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                INSERT INTO pregnancy_info
                (id, user_id, lmp_date, due_date, calculation_method, ultrasound_date, ultrasound_weeks, ultrasound_days,
                 ivf_transfer_date, ivf_embryo_age, is_multiple_pregnancy, fetus_count, created_at, updated_at)
                VALUES
                (@Id, @UserId, @LmpDate, @DueDate, @CalculationMethod, @UltrasoundDate, @UltrasoundWeeks, @UltrasoundDays,
                 @IvfTransferDate, @IvfEmbryoAge, @IsMultiplePregnancy, @FetusCount, @CreatedAt, @UpdatedAt)";

            // 确保UserId不为空
            if (pregnancyInfo.UserId == Guid.Empty)
            {
                throw new InvalidOperationException("UserId cannot be empty when creating pregnancy info.");
            }

            await connection.ExecuteAsync(sql, new
            {
                Id = pregnancyInfo.Id,
                UserId = pregnancyInfo.UserId,
                LmpDate = pregnancyInfo.LmpDate,
                DueDate = pregnancyInfo.DueDate,
                CalculationMethod = pregnancyInfo.CalculationMethod.ToString(),
                UltrasoundDate = pregnancyInfo.UltrasoundDate,
                UltrasoundWeeks = pregnancyInfo.UltrasoundWeeks,
                UltrasoundDays = pregnancyInfo.UltrasoundDays,
                IvfTransferDate = pregnancyInfo.IvfTransferDate,
                IvfEmbryoAge = pregnancyInfo.IvfEmbryoAge,
                IsMultiplePregnancy = pregnancyInfo.IsMultiplePregnancy,
                FetusCount = pregnancyInfo.FetusCount,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            });
        }

        public async Task UpdatePregnancyInfoAsync(PregnancyInfo pregnancyInfo)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = @"
                UPDATE pregnancy_info SET
                lmp_date = @LmpDate,
                due_date = @DueDate,
                calculation_method = @CalculationMethod,
                ultrasound_date = @UltrasoundDate,
                ultrasound_weeks = @UltrasoundWeeks,
                ultrasound_days = @UltrasoundDays,
                ivf_transfer_date = @IvfTransferDate,
                ivf_embryo_age = @IvfEmbryoAge,
                is_multiple_pregnancy = @IsMultiplePregnancy,
                fetus_count = @FetusCount,
                updated_at = @UpdatedAt
                WHERE id = @Id AND user_id = @UserId";

            // 确保UserId不为空
            if (pregnancyInfo.UserId == Guid.Empty)
            {
                throw new InvalidOperationException("UserId cannot be empty when updating pregnancy info.");
            }

            await connection.ExecuteAsync(sql, new
            {
                Id = pregnancyInfo.Id,
                UserId = pregnancyInfo.UserId,
                LmpDate = pregnancyInfo.LmpDate,
                DueDate = pregnancyInfo.DueDate,
                CalculationMethod = pregnancyInfo.CalculationMethod.ToString(),
                UltrasoundDate = pregnancyInfo.UltrasoundDate,
                UltrasoundWeeks = pregnancyInfo.UltrasoundWeeks,
                UltrasoundDays = pregnancyInfo.UltrasoundDays,
                IvfTransferDate = pregnancyInfo.IvfTransferDate,
                IvfEmbryoAge = pregnancyInfo.IvfEmbryoAge,
                IsMultiplePregnancy = pregnancyInfo.IsMultiplePregnancy,
                FetusCount = pregnancyInfo.FetusCount,
                UpdatedAt = DateTime.UtcNow
            });
        }

        public async Task<bool> PregnancyInfoExistsAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "SELECT COUNT(1) FROM pregnancy_info WHERE user_id = @UserId";
            var count = await connection.ExecuteScalarAsync<int>(sql, new { UserId = userId });
            return count > 0;
        }

        public async Task DeletePregnancyInfoAsync(Guid userId)
        {
            using var connection = new NpgsqlConnection(_connectionString);
            const string sql = "DELETE FROM pregnancy_info WHERE user_id = @UserId";
            await connection.ExecuteAsync(sql, new { UserId = userId });
        }
    }
}