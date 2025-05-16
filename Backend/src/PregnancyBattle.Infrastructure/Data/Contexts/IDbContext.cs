using System;
using System.Data;
using System.Threading.Tasks;

namespace PregnancyBattle.Infrastructure.Data.Contexts
{
    /// <summary>
    /// 数据库上下文接口
    /// </summary>
    public interface IDbContext : IDisposable
    {
        /// <summary>
        /// 获取数据库连接
        /// </summary>
        /// <returns>数据库连接</returns>
        IDbConnection GetConnection();
        
        /// <summary>
        /// 开始事务
        /// </summary>
        /// <returns>事务</returns>
        Task<IDbTransaction> BeginTransactionAsync();
        
        /// <summary>
        /// 提交事务
        /// </summary>
        /// <param name="transaction">事务</param>
        Task CommitAsync(IDbTransaction transaction);
        
        /// <summary>
        /// 回滚事务
        /// </summary>
        /// <param name="transaction">事务</param>
        Task RollbackAsync(IDbTransaction transaction);
    }
}