using System;

namespace PregnancyBattle.Domain.Entities
{
    /// <summary>
    /// 用户实体
    /// </summary>
    public class User : BaseEntity
    {
        /// <summary>
        /// 用户名
        /// </summary>
        public required string Username { get; set; }

        /// <summary>
        /// 电子邮件
        /// </summary>
        public required string Email { get; set; }

        /// <summary>
        /// 手机号码
        /// </summary>
        public required string PhoneNumber { get; set; }

        /// <summary>
        /// 密码哈希
        /// </summary>
        public required string PasswordHash { get; set; }

        /// <summary>
        /// 昵称
        /// </summary>
        public required string Nickname { get; set; }

        /// <summary>
        /// 头像URL
        /// </summary>
        public required string AvatarUrl { get; set; }

        /// <summary>
        /// 最后登录时间
        /// </summary>
        public DateTime? LastLoginAt { get; set; }
    }
}