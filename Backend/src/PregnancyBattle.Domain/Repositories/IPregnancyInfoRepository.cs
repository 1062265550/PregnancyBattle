using System;
using System.Threading.Tasks;
using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Domain.Repositories
{
    /// <summary>
    /// 孕期信息仓储接口
    /// </summary>
    public interface IPregnancyInfoRepository
    {
        /// <summary>
        /// 根据用户ID获取孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>孕期信息</returns>
        Task<PregnancyInfo?> GetByUserIdAsync(Guid userId);
        
        /// <summary>
        /// 添加孕期信息
        /// </summary>
        /// <param name="pregnancyInfo">孕期信息</param>
        Task AddAsync(PregnancyInfo pregnancyInfo);
        
        /// <summary>
        /// 更新孕期信息
        /// </summary>
        /// <param name="pregnancyInfo">孕期信息</param>
        Task UpdateAsync(PregnancyInfo pregnancyInfo);
        
        /// <summary>
        /// 判断用户是否存在孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>是否存在</returns>
        Task<bool> ExistsByUserIdAsync(Guid userId);
    }
}