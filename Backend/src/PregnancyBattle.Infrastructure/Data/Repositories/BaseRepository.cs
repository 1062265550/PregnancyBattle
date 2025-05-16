using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Logging;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Infrastructure.Data.Contexts;

namespace PregnancyBattle.Infrastructure.Data.Repositories
{
    /// <summary>
    /// 基础仓储实现
    /// </summary>
    /// <typeparam name="T">实体类型</typeparam>
    public abstract class BaseRepository<T> : IRepository<T> where T : BaseEntity
    {
        protected readonly IDbContext DbContext;
        protected readonly string TableName;
        protected readonly ILogger<BaseRepository<T>>? Logger;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="dbContext">数据库上下文</param>
        /// <param name="tableName">表名</param>
        /// <param name="logger">日志记录器</param>
        protected BaseRepository(IDbContext dbContext, string tableName, ILogger<BaseRepository<T>>? logger = null)
        {
            DbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
            TableName = !string.IsNullOrEmpty(tableName) ? tableName : throw new ArgumentException("表名不能为空", nameof(tableName));
            Logger = logger;
        }

        /// <summary>
        /// 获取所有实体
        /// </summary>
        /// <returns>实体列表</returns>
        public virtual async Task<IEnumerable<T>> GetAllAsync()
        {
            Logger?.LogInformation($"正在获取所有 {TableName} 记录");

            try
            {
                using var connection = DbContext.GetConnection();
                var sql = $"SELECT * FROM {TableName}";

                var result = await connection.QueryAsync<T>(sql);
                Logger?.LogInformation($"成功获取 {TableName} 记录，共 {result?.Count() ?? 0} 条");

                return result;
            }
            catch (Exception ex)
            {
                Logger?.LogError(ex, $"获取所有 {TableName} 记录时发生错误: {ex.Message}");
                throw new InvalidOperationException($"获取所有 {TableName} 记录时发生错误", ex);
            }
        }

        /// <summary>
        /// 根据ID获取实体
        /// </summary>
        /// <param name="id">实体ID</param>
        /// <returns>实体</returns>
        public virtual async Task<T?> GetByIdAsync(Guid id)
        {
            Logger?.LogInformation($"正在获取 {TableName} 记录，ID: {id}");

            try
            {
                using var connection = DbContext.GetConnection();
                // 对于User实体，使用明确的列名映射
                string sql;
                if (typeof(T).Name == "User")
                {
                    sql = $@"
                        SELECT
                            id, username, email,
                            phone_number as PhoneNumber,
                            password_hash as PasswordHash,
                            nickname, avatar_url,
                            created_at as CreatedAt,
                            updated_at as UpdatedAt,
                            last_login_at as LastLoginAt
                        FROM {TableName}
                        WHERE id = @Id";

                    Logger?.LogInformation($"使用明确的列名映射查询User实体");
                }
                else
                {
                    sql = $"SELECT * FROM {TableName} WHERE id = @Id";
                }

                var result = await connection.QueryFirstOrDefaultAsync<T>(sql, new { Id = id });

                if (result == null)
                {
                    Logger?.LogInformation($"未找到 {TableName} 记录，ID: {id}");
                }
                else
                {
                    Logger?.LogInformation($"成功获取 {TableName} 记录，ID: {id}");
                }

                return result;
            }
            catch (Exception ex)
            {
                Logger?.LogError(ex, $"获取 {TableName} 记录时发生错误，ID: {id}, 错误: {ex.Message}");
                throw new InvalidOperationException($"获取 {TableName} 记录时发生错误，ID: {id}", ex);
            }
        }

        /// <summary>
        /// 添加实体
        /// </summary>
        /// <param name="entity">实体</param>
        /// <returns>添加后的实体</returns>
        public abstract Task<T> AddAsync(T entity);

        /// <summary>
        /// 更新实体
        /// </summary>
        /// <param name="entity">实体</param>
        /// <returns>更新后的实体</returns>
        public abstract Task<T> UpdateAsync(T entity);

        /// <summary>
        /// 删除实体
        /// </summary>
        /// <param name="id">实体ID</param>
        /// <returns>是否删除成功</returns>
        public virtual async Task<bool> DeleteAsync(Guid id)
        {
            Logger?.LogInformation($"正在删除 {TableName} 记录，ID: {id}");

            try
            {
                using var connection = DbContext.GetConnection();
                var sql = $"DELETE FROM {TableName} WHERE id = @Id";

                var result = await connection.ExecuteAsync(sql, new { Id = id });

                if (result > 0)
                {
                    Logger?.LogInformation($"成功删除 {TableName} 记录，ID: {id}");
                    return true;
                }
                else
                {
                    Logger?.LogWarning($"未找到要删除的 {TableName} 记录，ID: {id}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                Logger?.LogError(ex, $"删除 {TableName} 记录时发生错误，ID: {id}, 错误: {ex.Message}");
                throw new InvalidOperationException($"删除 {TableName} 记录时发生错误，ID: {id}", ex);
            }
        }

        /// <summary>
        /// 执行SQL查询并返回第一个结果
        /// </summary>
        /// <typeparam name="TResult">结果类型</typeparam>
        /// <param name="sql">SQL查询</param>
        /// <param name="parameters">参数</param>
        /// <param name="commandType">命令类型</param>
        /// <returns>查询结果</returns>
        protected async Task<TResult?> QueryFirstOrDefaultAsync<TResult>(string sql, object? parameters = null, CommandType commandType = CommandType.Text)
        {
            try
            {
                using var connection = DbContext.GetConnection();
                return await connection.QueryFirstOrDefaultAsync<TResult>(sql, parameters, commandType: commandType);
            }
            catch (Exception ex)
            {
                Logger?.LogError(ex, $"执行SQL查询时发生错误: {ex.Message}, SQL: {sql}");
                throw new InvalidOperationException("执行SQL查询时发生错误", ex);
            }
        }

        /// <summary>
        /// 执行SQL查询并返回结果集
        /// </summary>
        /// <typeparam name="TResult">结果类型</typeparam>
        /// <param name="sql">SQL查询</param>
        /// <param name="parameters">参数</param>
        /// <param name="commandType">命令类型</param>
        /// <returns>查询结果集</returns>
        protected async Task<IEnumerable<TResult>> QueryAsync<TResult>(string sql, object? parameters = null, CommandType commandType = CommandType.Text)
        {
            try
            {
                using var connection = DbContext.GetConnection();
                return await connection.QueryAsync<TResult>(sql, parameters, commandType: commandType);
            }
            catch (Exception ex)
            {
                Logger?.LogError(ex, $"执行SQL查询时发生错误: {ex.Message}, SQL: {sql}");
                throw new InvalidOperationException("执行SQL查询时发生错误", ex);
            }
        }

        /// <summary>
        /// 执行SQL命令
        /// </summary>
        /// <param name="sql">SQL命令</param>
        /// <param name="parameters">参数</param>
        /// <param name="commandType">命令类型</param>
        /// <returns>受影响的行数</returns>
        protected async Task<int> ExecuteAsync(string sql, object? parameters = null, CommandType commandType = CommandType.Text)
        {
            try
            {
                using var connection = DbContext.GetConnection();
                return await connection.ExecuteAsync(sql, parameters, commandType: commandType);
            }
            catch (Exception ex)
            {
                Logger?.LogError(ex, $"执行SQL命令时发生错误: {ex.Message}, SQL: {sql}");
                throw new InvalidOperationException("执行SQL命令时发生错误", ex);
            }
        }
    }
}