using System;

namespace PregnancyBattle.Application.DTOs
{
    /// <summary>
    /// 用户DTO
    /// </summary>
    public class UserDto
    {
        /// <summary>
        /// 用户ID
        /// </summary>
        public Guid Id { get; set; }

        /// <summary>
        /// 用户名
        /// </summary>
        public string Username { get; set; }

        /// <summary>
        /// 电子邮件
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// 手机号码
        /// </summary>
        public string PhoneNumber { get; set; } // 保持非空，我们在UserService中确保它有值

        /// <summary>
        /// 昵称
        /// </summary>
        public string Nickname { get; set; }

        /// <summary>
        /// 头像URL
        /// </summary>
        public string AvatarUrl { get; set; }

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>
        /// 最后登录时间
        /// </summary>
        public DateTime? LastLoginAt { get; set; }
    }

    /// <summary>
    /// 创建用户请求DTO
    /// </summary>
    public class CreateUserDto
    {
        /// <summary>
        /// 用户名
        /// </summary>
        public string Username { get; set; }

        /// <summary>
        /// 电子邮件
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// 手机号码
        /// </summary>
        public string PhoneNumber { get; set; }

        /// <summary>
        /// 密码
        /// </summary>
        public string Password { get; set; }

        /// <summary>
        /// 昵称
        /// </summary>
        public string Nickname { get; set; }
    }

    /// <summary>
    /// 更新用户请求DTO
    /// </summary>
    public class UpdateUserDto
    {
        /// <summary>
        /// 昵称
        /// </summary>
        public string? Nickname { get; set; }

        /// <summary>
        /// 头像URL
        /// </summary>
        public string? AvatarUrl { get; set; }
    }

    /// <summary>
    /// 用户登录请求DTO
    /// </summary>
    public class UserLoginDto
    {
        /// <summary>
        /// 用户名/电子邮件/手机号码
        /// </summary>
        public string Username { get; set; }

        /// <summary>
        /// 密码
        /// </summary>
        public string Password { get; set; }
    }

    /// <summary>
    /// 用户登录响应DTO
    /// </summary>
    public class UserLoginResponseDto
    {
        /// <summary>
        /// 访问令牌
        /// </summary>
        public string AccessToken { get; set; }

        /// <summary>
        /// 刷新令牌
        /// </summary>
        public string RefreshToken { get; set; }

        /// <summary>
        /// 令牌类型
        /// </summary>
        public string TokenType { get; set; } = "Bearer";

        /// <summary>
        /// 过期时间（秒）
        /// </summary>
        public int ExpiresIn { get; set; }

        /// <summary>
        /// 用户信息
        /// </summary>
        public UserDto User { get; set; }
    }

    /// <summary>
    /// 发送验证码请求DTO
    /// </summary>
    public class SendVerificationCodeDto
    {
        /// <summary>
        /// 电子邮件
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// 手机号码
        /// </summary>
        public string PhoneNumber { get; set; }
    }

    /// <summary>
    /// 发送验证码响应DTO
    /// </summary>
    public class SendVerificationCodeResponseDto
    {
        /// <summary>
        /// 验证码过期时间
        /// </summary>
        public DateTime CodeExpireTime { get; set; }
    }

    /// <summary>
    /// 验证验证码请求DTO
    /// </summary>
    public class VerifyCodeDto
    {
        /// <summary>
        /// 电子邮件
        /// </summary>
        public string Email { get; set; }

        /// <summary>
        /// 手机号码
        /// </summary>
        public string PhoneNumber { get; set; }

        /// <summary>
        /// 验证码
        /// </summary>
        public string Code { get; set; }
    }

    /// <summary>
    /// 验证验证码响应DTO
    /// </summary>
    public class VerifyCodeResponseDto
    {
        /// <summary>
        /// 重置密码令牌
        /// </summary>
        public string ResetToken { get; set; }
    }

    /// <summary>
    /// 重置密码请求DTO
    /// </summary>
    public class ResetPasswordDto
    {
        /// <summary>
        /// 重置密码令牌
        /// </summary>
        public string ResetToken { get; set; }

        /// <summary>
        /// 新密码
        /// </summary>
        public string NewPassword { get; set; }
    }

    /// <summary>
    /// 重置密码响应DTO
    /// </summary>
    public class ResetPasswordResponseDto
    {
        /// <summary>
        /// 是否成功
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// 消息
        /// </summary>
        public string Message { get; set; }
    }
}