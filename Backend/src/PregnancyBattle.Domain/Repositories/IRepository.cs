using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Domain.Repositories
{
    /// <summary>
    /// 通用仓储接口
    /// </summary>
    /// <typeparam name="T">实体类型</typeparam>
    public interface IRepository<T> where T : BaseEntity
    {
        /// <summary>
        /// 获取所有实体
        /// </summary>
        /// <returns>实体列表</returns>
        Task<IEnumerable<T>> GetAllAsync();

        /// <summary>
        /// 根据ID获取实体
        /// </summary>
        /// <param name="id">实体ID</param>
        /// <returns>实体，如果未找到则返回null</returns>
        Task<T?> GetByIdAsync(Guid id);

        /// <summary>
        /// 添加实体
        /// </summary>
        /// <param name="entity">实体</param>
        /// <returns>添加后的实体</returns>
        Task<T> AddAsync(T entity);

        /// <summary>
        /// 更新实体
        /// </summary>
        /// <param name="entity">实体</param>
        /// <returns>更新后的实体</returns>
        Task<T> UpdateAsync(T entity);

        /// <summary>
        /// 删除实体
        /// </summary>
        /// <param name="id">实体ID</param>
        /// <returns>是否删除成功</returns>
        Task<bool> DeleteAsync(Guid id);
    }
}