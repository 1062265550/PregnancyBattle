using PregnancyBattle.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace PregnancyBattle.Domain.Repositories
{
    public interface IHealthProfileRepository
    {
        Task<HealthProfile?> GetHealthProfileByUserIdAsync(Guid userId);
        Task CreateHealthProfileAsync(HealthProfile healthProfile);
        Task UpdateHealthProfileAsync(HealthProfile healthProfile);
        Task<bool> HealthProfileExistsAsync(Guid userId);

        // For WeightLog
        Task AddWeightLogAsync(WeightLog weightLog);
        Task<IEnumerable<WeightLog>> GetWeightLogsByUserIdAsync(Guid userId, DateTime? startDate, DateTime? endDate);
        Task<WeightLog?> GetLatestWeightLogByUserIdAsync(Guid userId);
        Task<WeightLog?> GetWeightLogByUserIdAndDateAsync(Guid userId, DateTime date);
        Task UpdateWeightLogAsync(WeightLog weightLog);
        Task AddOrUpdateWeightLogAsync(WeightLog weightLog);
    }
}