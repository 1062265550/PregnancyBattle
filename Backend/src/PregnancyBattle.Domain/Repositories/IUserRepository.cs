using System;
using System.Threading.Tasks;
using PregnancyBattle.Domain.Entities;

namespace PregnancyBattle.Domain.Repositories
{
    /// <summary>
    /// 用户仓储接口
    /// </summary>
    public interface IUserRepository : IRepository<User>
    {
        /// <summary>
        /// 根据电子邮件获取用户
        /// </summary>
        /// <param name="email">电子邮件</param>
        /// <returns>用户，如果未找到则返回null</returns>
        Task<User?> GetByEmailAsync(string email);

        /// <summary>
        /// 根据用户名获取用户
        /// </summary>
        /// <param name="username">用户名</param>
        /// <returns>用户，如果未找到则返回null</returns>
        Task<User?> GetByUsernameAsync(string username);

        /// <summary>
        /// 根据手机号码获取用户
        /// </summary>
        /// <param name="phoneNumber">手机号码</param>
        /// <returns>用户，如果未找到则返回null</returns>
        Task<User?> GetByPhoneNumberAsync(string phoneNumber);

        /// <summary>
        /// 更新用户最后登录时间
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>是否更新成功</returns>
        Task<bool> UpdateLastLoginAsync(Guid userId);
    }
}