using System;
using System.Threading.Tasks;
using PregnancyBattle.Application.DTOs;

namespace PregnancyBattle.Application.Services.Interfaces
{
    /// <summary>
    /// 用户服务接口
    /// </summary>
    public interface IUserService
    {
        /// <summary>
        /// 注册用户
        /// </summary>
        /// <param name="createUserDto">创建用户请求</param>
        /// <returns>用户信息</returns>
        Task<UserDto> RegisterAsync(CreateUserDto createUserDto);

        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="loginDto">登录请求</param>
        /// <returns>登录响应</returns>
        Task<UserLoginResponseDto> LoginAsync(UserLoginDto loginDto);

        /// <summary>
        /// 获取用户信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <returns>用户信息</returns>
        Task<UserDto> GetUserAsync(Guid userId);

        /// <summary>
        /// 更新用户信息
        /// </summary>
        /// <param name="userId">用户ID</param>
        /// <param name="updateUserDto">更新用户请求</param>
        /// <returns>用户信息</returns>
        Task<UserDto> UpdateUserAsync(Guid userId, UpdateUserDto updateUserDto);

        /// <summary>
        /// 刷新令牌
        /// </summary>
        /// <param name="refreshToken">刷新令牌</param>
        /// <returns>登录响应</returns>
        Task<UserLoginResponseDto> RefreshTokenAsync(string refreshToken);

        /// <summary>
        /// 发送验证码
        /// </summary>
        /// <param name="sendVerificationCodeDto">发送验证码请求</param>
        /// <returns>发送验证码响应</returns>
        Task<SendVerificationCodeResponseDto> SendVerificationCodeAsync(SendVerificationCodeDto sendVerificationCodeDto);

        /// <summary>
        /// 验证验证码
        /// </summary>
        /// <param name="verifyCodeDto">验证验证码请求</param>
        /// <returns>验证验证码响应</returns>
        Task<VerifyCodeResponseDto> VerifyCodeAsync(VerifyCodeDto verifyCodeDto);

        /// <summary>
        /// 重置密码
        /// </summary>
        /// <param name="resetPasswordDto">重置密码请求</param>
        /// <returns>重置密码响应</returns>
        Task<ResetPasswordResponseDto> ResetPasswordAsync(ResetPasswordDto resetPasswordDto);
    }
}