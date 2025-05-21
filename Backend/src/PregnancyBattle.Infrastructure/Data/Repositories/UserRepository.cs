using System;
using System.Threading.Tasks;
using Dapper;
using Microsoft.Extensions.Logging;
using PregnancyBattle.Domain.Entities;
using PregnancyBattle.Domain.Repositories;
using PregnancyBattle.Infrastructure.Data.Contexts;

namespace PregnancyBattle.Infrastructure.Data.Repositories
{
    /// <summary>
    /// 用户仓储实现
    /// </summary>
    public class UserRepository : BaseRepository<User>, IUserRepository
    {
        private readonly ILogger<UserRepository> _logger;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="dbContext">数据库上下文</param>
        /// <param name="logger">日志记录器</param>
        public UserRepository(IDbContext dbContext, ILogger<UserRepository> logger)
            : base(dbContext, "users", logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// 根据电子邮件获取用户
        /// </summary>
        /// <param name="email">电子邮件</param>
        /// <returns>用户</returns>
        public async Task<User?> GetByEmailAsync(string email)
        {
            if (string.IsNullOrEmpty(email))
            {
                _logger.LogWarning("尝试使用空电子邮件查询用户");
                return null;
            }

            _logger.LogInformation($"正在根据电子邮件查询用户: {email}");

            try
            {
                var sql = $@"
                    SELECT
                        id, username, email,
                        phone_number as PhoneNumber,
                        password_hash as PasswordHash,
                        nickname, avatar_url AS ""AvatarUrl"",
                        created_at as CreatedAt,
                        updated_at as UpdatedAt,
                        last_login_at as LastLoginAt
                    FROM {TableName}
                    WHERE email = @Email";

                var result = await QueryFirstOrDefaultAsync<User>(sql, new { Email = email });

                if (result != null)
                {
                    _logger.LogInformation($"[UserRepository.GetByEmailAsync] Raw AvatarUrl from Dapper for user {result.Email}: '{result.AvatarUrl}'");
                    _logger.LogInformation($"查询到用户，ID: {result.Id}, 邮箱: {result.Email}, 密码哈希: {result.PasswordHash ?? "NULL"}");
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"根据电子邮件查询用户时发生错误: {ex.Message}, 电子邮件: {email}");
                throw new InvalidOperationException($"根据电子邮件查询用户时发生错误: {email}", ex);
            }
        }

        /// <summary>
        /// 根据用户名获取用户
        /// </summary>
        /// <param name="username">用户名</param>
        /// <returns>用户</returns>
        public async Task<User?> GetByUsernameAsync(string username)
        {
            if (string.IsNullOrEmpty(username))
            {
                _logger.LogWarning("尝试使用空用户名查询用户");
                return null;
            }

            _logger.LogInformation($"正在根据用户名查询用户: {username}");

            try
            {
                var sql = $@"
                    SELECT
                        id, username, email,
                        phone_number as PhoneNumber,
                        password_hash as PasswordHash,
                        nickname, avatar_url AS ""AvatarUrl"",
                        created_at as CreatedAt,
                        updated_at as UpdatedAt,
                        last_login_at as LastLoginAt
                    FROM {TableName}
                    WHERE username = @Username";

                var result = await QueryFirstOrDefaultAsync<User>(sql, new { Username = username });

                if (result != null)
                {
                    _logger.LogInformation($"[UserRepository.GetByUsernameAsync] Raw AvatarUrl from Dapper for user {result.Username}: '{result.AvatarUrl}'");
                    _logger.LogInformation($"查询到用户，ID: {result.Id}, 用户名: {result.Username}, 密码哈希: {result.PasswordHash ?? "NULL"}, 手机号: {result.PhoneNumber ?? "NULL"}");

                    // 检查所有属性是否正确映射
                    _logger.LogInformation($"用户属性详情: ID={result.Id}, Username={result.Username ?? "NULL"}, Email={result.Email ?? "NULL"}, PhoneNumber={result.PhoneNumber ?? "NULL"}, Nickname={result.Nickname ?? "NULL"}, AvatarUrl={result.AvatarUrl ?? "NULL"}, PasswordHash={(result.PasswordHash != null ? "已设置" : "NULL")}");
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"根据用户名查询用户时发生错误: {ex.Message}, 用户名: {username}");
                throw new InvalidOperationException($"根据用户名查询用户时发生错误: {username}", ex);
            }
        }

        /// <summary>
        /// 根据手机号码获取用户
        /// </summary>
        /// <param name="phoneNumber">手机号码</param>
        /// <returns>用户</returns>
        public async Task<User?> GetByPhoneNumberAsync(string phoneNumber)
        {
            if (string.IsNullOrEmpty(phoneNumber))
            {
                _logger.LogWarning("尝试使用空手机号码查询用户");
                return null;
            }

            _logger.LogInformation($"正在根据手机号码查询用户: {phoneNumber}");

            try
            {
                var sql = $@"
                    SELECT
                        id, username, email,
                        phone_number as PhoneNumber,
                        password_hash as PasswordHash,
                        nickname, avatar_url AS ""AvatarUrl"",
                        created_at as CreatedAt,
                        updated_at as UpdatedAt,
                        last_login_at as LastLoginAt
                    FROM {TableName}
                    WHERE phone_number = @PhoneNumber";

                var result = await QueryFirstOrDefaultAsync<User>(sql, new { PhoneNumber = phoneNumber });

                if (result != null)
                {
                    _logger.LogInformation($"[UserRepository.GetByPhoneNumberAsync] Raw AvatarUrl from Dapper for user with phone {result.PhoneNumber}: '{result.AvatarUrl}'");
                    _logger.LogInformation($"查询到用户，ID: {result.Id}, 手机号: {result.PhoneNumber}, 密码哈希: {result.PasswordHash ?? "NULL"}");
                }

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"根据手机号码查询用户时发生错误: {ex.Message}, 手机号码: {phoneNumber}");
                throw new InvalidOperationException($"根据手机号码查询用户时发生错误: {phoneNumber}", ex);
            }
        }

        /// <summary>
        /// 更新用户最后登录时间
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>是否更新成功</returns>
        public async Task<bool> UpdateLastLoginAsync(Guid userId)
        {
            if (userId == Guid.Empty)
            {
                _logger.LogWarning("尝试使用空用户ID更新最后登录时间");
                return false;
            }

            _logger.LogInformation($"正在更新用户最后登录时间，用户ID: {userId}");

            try
            {
                var sql = $"UPDATE {TableName} SET last_login_at = @LastLoginAt, updated_at = @UpdatedAt WHERE id = @Id";

                var result = await ExecuteAsync(sql, new
                {
                    Id = userId,
                    LastLoginAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                });

                if (result > 0)
                {
                    _logger.LogInformation($"成功更新用户最后登录时间，用户ID: {userId}");
                    return true;
                }
                else
                {
                    _logger.LogWarning($"未找到要更新的用户，用户ID: {userId}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"更新用户最后登录时间时发生错误: {ex.Message}, 用户ID: {userId}");
                throw new InvalidOperationException($"更新用户最后登录时间时发生错误，用户ID: {userId}", ex);
            }
        }

        /// <summary>
        /// 添加用户
        /// </summary>
        /// <param name="entity">用户实体</param>
        /// <returns>添加后的用户</returns>
        public override async Task<User> AddAsync(User entity)
        {
            if (entity == null)
            {
                throw new ArgumentNullException(nameof(entity), "用户实体不能为空");
            }

            _logger.LogInformation($"正在添加新用户，用户名: {entity.Username}, 电子邮件: {entity.Email}");

            try
            {
                // 设置必要的字段
                entity.Id = entity.Id == Guid.Empty ? Guid.NewGuid() : entity.Id;
                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;

                // 确保PhoneNumber不为null
                entity.PhoneNumber = entity.PhoneNumber ?? string.Empty;

                var sql = @"
                    INSERT INTO users (id, username, email, phone_number, password_hash, nickname, avatar_url, created_at, updated_at, last_login_at)
                    VALUES (@Id, @Username, @Email, @PhoneNumber, @PasswordHash, @Nickname, @AvatarUrl, @CreatedAt, @UpdatedAt, @LastLoginAt)
                    RETURNING id, username, email,
                             phone_number as PhoneNumber,
                             password_hash as PasswordHash,
                             nickname, avatar_url AS ""AvatarUrl"",
                             created_at as CreatedAt,
                             updated_at as UpdatedAt,
                             last_login_at as LastLoginAt";

                var result = await QueryFirstOrDefaultAsync<User>(sql, entity);

                if (result != null)
                {
                    _logger.LogInformation($"成功添加新用户，用户ID: {result.Id}, 用户名: {result.Username}");
                    return result;
                }
                else
                {
                    throw new InvalidOperationException("添加用户后未返回结果");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"添加用户时发生错误: {ex.Message}, 用户名: {entity.Username}, 电子邮件: {entity.Email}");
                throw new InvalidOperationException($"添加用户时发生错误，用户名: {entity.Username}", ex);
            }
        }

        /// <summary>
        /// 更新用户
        /// </summary>
        /// <param name="entity">用户实体</param>
        /// <returns>更新后的用户</returns>
        public override async Task<User> UpdateAsync(User entity)
        {
            if (entity == null)
            {
                throw new ArgumentNullException(nameof(entity), "用户实体不能为空");
            }

            if (entity.Id == Guid.Empty)
            {
                throw new ArgumentException("用户ID不能为空", nameof(entity));
            }

            _logger.LogInformation($"正在更新用户，用户ID: {entity.Id}, 用户名: {entity.Username}");

            try
            {
                entity.UpdatedAt = DateTime.UtcNow;

                // 确保PhoneNumber不为null
                entity.PhoneNumber = entity.PhoneNumber ?? string.Empty;

                var sql = @"
                    UPDATE users
                    SET username = @Username,
                        email = @Email,
                        phone_number = @PhoneNumber,
                        password_hash = @PasswordHash,
                        nickname = @Nickname,
                        avatar_url = @AvatarUrl,
                        updated_at = @UpdatedAt
                    WHERE id = @Id
                    RETURNING id, username, email,
                             phone_number as PhoneNumber,
                             password_hash as PasswordHash,
                             nickname, avatar_url AS ""AvatarUrl"",
                             created_at as CreatedAt,
                             updated_at as UpdatedAt,
                             last_login_at as LastLoginAt";

                var result = await QueryFirstOrDefaultAsync<User>(sql, entity);

                if (result != null)
                {
                    _logger.LogInformation($"成功更新用户，用户ID: {result.Id}, 用户名: {result.Username}");
                    return result;
                }
                else
                {
                    _logger.LogWarning($"未找到要更新的用户，用户ID: {entity.Id}");
                    throw new InvalidOperationException($"未找到要更新的用户，用户ID: {entity.Id}");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"更新用户时发生错误: {ex.Message}, 用户ID: {entity.Id}, 用户名: {entity.Username}");
                throw new InvalidOperationException($"更新用户时发生错误，用户ID: {entity.Id}", ex);
            }
        }
    }
}