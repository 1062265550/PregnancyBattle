using System;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace PregnancyBattle.Infrastructure.Data.Contexts
{
    /// <summary>
    /// PostgreSQL数据库上下文实现
    /// </summary>
    public class PostgresDbContext : IDbContext
    {
        private readonly string _connectionString;
        private IDbConnection? _connection;
        private readonly ILogger<PostgresDbContext>? _logger;
        private const int MaxRetries = 3;
        private static readonly TimeSpan InitialRetryDelay = TimeSpan.FromSeconds(1);

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="configuration">配置</param>
        /// <param name="logger">日志记录器</param>
        public PostgresDbContext(IConfiguration configuration, ILogger<PostgresDbContext>? logger = null)
        {
            if (configuration == null)
                throw new ArgumentNullException(nameof(configuration));

            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("未找到DefaultConnection连接字符串配置");
            _logger = logger;
        }

        /// <summary>
        /// 获取数据库连接
        /// </summary>
        /// <returns>数据库连接</returns>
        public IDbConnection GetConnection()
        {
            // 每次都创建新的连接，而不是重用
            int retryCount = 0;
            Exception? lastException = null;

            while (retryCount < MaxRetries)
            {
                try
                {
                    // 如果有旧连接，确保它已关闭并释放
                    if (_connection != null)
                    {
                        try
                        {
                            if (_connection.State != ConnectionState.Closed)
                            {
                                _connection.Close();
                            }
                            _connection.Dispose();
                        }
                        catch (Exception ex)
                        {
                            _logger?.LogWarning(ex, "关闭旧连接时发生错误");
                        }
                    }

                    // 创建并初始化新连接
                    var connection = new NpgsqlConnection(_connectionString);

                    // 打开连接前记录日志
                    _logger?.LogInformation("正在尝试打开数据库连接...");

                    // 打开连接
                    connection.Open();

                    // 连接成功后记录日志
                    _logger?.LogInformation("数据库连接已成功打开");

                    // 保存连接引用
                    _connection = connection;

                    return connection;
                }
                catch (NpgsqlException ex)
                {
                    lastException = ex;
                    retryCount++;

                    _logger?.LogWarning(ex, $"数据库连接失败 (NpgsqlException)，正在重试 ({retryCount}/{MaxRetries})");

                    // 如果已达到最大重试次数，记录错误并抛出异常
                    if (retryCount >= MaxRetries)
                    {
                        _logger?.LogError(ex, "数据库连接失败，已达到最大重试次数");
                        throw new InvalidOperationException($"无法连接到数据库，已重试 {MaxRetries} 次", ex);
                    }

                    // 指数退避策略
                    var delay = TimeSpan.FromMilliseconds(InitialRetryDelay.TotalMilliseconds * Math.Pow(2, retryCount - 1));
                    Thread.Sleep(delay);
                }
                catch (Exception ex)
                {
                    lastException = ex;
                    retryCount++;

                    _logger?.LogWarning(ex, $"数据库连接失败，正在重试 ({retryCount}/{MaxRetries})");

                    // 如果已达到最大重试次数，记录错误并抛出异常
                    if (retryCount >= MaxRetries)
                    {
                        _logger?.LogError(ex, "数据库连接失败，已达到最大重试次数");
                        throw new InvalidOperationException($"无法连接到数据库，已重试 {MaxRetries} 次", ex);
                    }

                    // 指数退避策略
                    var delay = TimeSpan.FromMilliseconds(InitialRetryDelay.TotalMilliseconds * Math.Pow(2, retryCount - 1));
                    Thread.Sleep(delay);
                }
            }

            // 这行代码理论上不会执行，因为在循环中如果重试次数达到上限会抛出异常
            throw new InvalidOperationException("无法创建数据库连接", lastException);
        }

        /// <summary>
        /// 开始事务
        /// </summary>
        /// <returns>事务</returns>
        public async Task<IDbTransaction> BeginTransactionAsync()
        {
            try
            {
                _logger?.LogInformation("正在开始数据库事务...");
                var connection = GetConnection();
                var transaction = await Task.FromResult(connection.BeginTransaction());
                _logger?.LogInformation("数据库事务已成功开始");
                return transaction;
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "开始数据库事务时发生错误");
                throw new InvalidOperationException("无法开始数据库事务", ex);
            }
        }

        /// <summary>
        /// 提交事务
        /// </summary>
        /// <param name="transaction">事务</param>
        public async Task CommitAsync(IDbTransaction transaction)
        {
            if (transaction == null)
                throw new ArgumentNullException(nameof(transaction));

            try
            {
                _logger?.LogInformation("正在提交数据库事务...");
                await Task.Run(() => transaction.Commit());
                _logger?.LogInformation("数据库事务已成功提交");
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "提交数据库事务时发生错误");
                throw new InvalidOperationException("无法提交数据库事务", ex);
            }
        }

        /// <summary>
        /// 回滚事务
        /// </summary>
        /// <param name="transaction">事务</param>
        public async Task RollbackAsync(IDbTransaction transaction)
        {
            if (transaction == null)
                throw new ArgumentNullException(nameof(transaction));

            try
            {
                _logger?.LogInformation("正在回滚数据库事务...");
                await Task.Run(() => transaction.Rollback());
                _logger?.LogInformation("数据库事务已成功回滚");
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "回滚数据库事务时发生错误");
                throw new InvalidOperationException("无法回滚数据库事务", ex);
            }
        }

        /// <summary>
        /// 释放资源
        /// </summary>
        public void Dispose()
        {
            try
            {
                if (_connection != null)
                {
                    if (_connection.State != ConnectionState.Closed)
                    {
                        _connection.Close();
                    }
                    _connection.Dispose();
                    _connection = null;
                    _logger?.LogInformation("数据库连接已关闭并释放");
                }
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "关闭数据库连接时发生错误");
            }
        }
    }
}