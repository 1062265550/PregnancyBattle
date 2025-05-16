using System;
using System.Threading.Tasks;
using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Domain.Repositories
{
    /// <summary>
    /// 孕期信息仓储接口
    /// </summary>
    public interface IPregnancyInfoRepository : IRepository<PregnancyInfo>
    {
        /// <summary>
        /// 根据用户ID获取孕期信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>孕期信息</returns>
        Task<PregnancyInfo> GetByUserIdAsync(Guid userId);
        
        /// <summary>
        /// 更新预产期
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="dueDate">预产期</param>
        /// <param name="calculationMethod">计算方式</param>
        /// <returns>是否更新成功</returns>
        Task<bool> UpdateDueDateAsync(Guid userId, DateTime dueDate, string calculationMethod);
    }
}