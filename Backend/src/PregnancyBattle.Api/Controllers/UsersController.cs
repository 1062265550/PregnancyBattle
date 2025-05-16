using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Api.Models;
using PregnancyBattle.Application.DTOs;
using PregnancyBattle.Application.Services;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// 用户控制器
    /// </summary>
    public class UsersController : BaseApiController
    {
        private readonly IUserService _userService;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="userService">用户服务</param>
        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        /// <summary>
        /// 注册用户
        /// </summary>
        /// <param name="createUserDto">创建用户请求</param>
        /// <returns>用户信息</returns>
        [HttpPost("register")]
        [ProducesResponseType(typeof(ApiResponse<UserDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        public async Task<IActionResult> Register([FromBody] CreateUserDto createUserDto)
        {
            var user = await _userService.RegisterAsync(createUserDto);
            return Success(user, "注册成功");
        }

        /// <summary>
        /// 用户登录
        /// </summary>
        /// <param name="loginDto">登录请求</param>
        /// <returns>登录响应</returns>
        [HttpPost("login")]
        [ProducesResponseType(typeof(ApiResponse<UserLoginResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        [ProducesResponseType(typeof(ApiResponse), 401)]
        public async Task<IActionResult> Login([FromBody] UserLoginDto loginDto)
        {
            var response = await _userService.LoginAsync(loginDto);
            return Success(response, "登录成功");
        }

        /// <summary>
        /// 获取当前用户信息
        /// </summary>
        /// <returns>用户信息</returns>
        [HttpGet("me")]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<UserDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 401)]
        [ProducesResponseType(typeof(ApiResponse), 404)]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = GetUserId();
            var user = await _userService.GetUserAsync(Guid.Parse(userId));
            return Success(user);
        }

        /// <summary>
        /// 更新当前用户信息
        /// </summary>
        /// <param name="updateUserDto">更新用户请求</param>
        /// <returns>用户信息</returns>
        [HttpPut("me")]
        [Authorize]
        [ProducesResponseType(typeof(ApiResponse<UserDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        [ProducesResponseType(typeof(ApiResponse), 401)]
        [ProducesResponseType(typeof(ApiResponse), 404)]
        public async Task<IActionResult> UpdateCurrentUser([FromBody] UpdateUserDto updateUserDto)
        {
            var userId = GetUserId();
            var user = await _userService.UpdateUserAsync(Guid.Parse(userId), updateUserDto);
            return Success(user, "更新成功");
        }

        /// <summary>
        /// 刷新令牌
        /// </summary>
        /// <param name="refreshToken">刷新令牌</param>
        /// <returns>登录响应</returns>
        [HttpPost("refresh-token")]
        [ProducesResponseType(typeof(ApiResponse<UserLoginResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        public async Task<IActionResult> RefreshToken([FromBody] string refreshToken)
        {
            var response = await _userService.RefreshTokenAsync(refreshToken);
            return Success(response, "令牌刷新成功");
        }

        /// <summary>
        /// 发送验证码
        /// </summary>
        /// <param name="sendVerificationCodeDto">发送验证码请求</param>
        /// <returns>发送验证码响应</returns>
        [HttpPost("forgot-password/send-code")]
        [ProducesResponseType(typeof(ApiResponse<SendVerificationCodeResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        public async Task<IActionResult> SendVerificationCode([FromBody] SendVerificationCodeDto sendVerificationCodeDto)
        {
            var response = await _userService.SendVerificationCodeAsync(sendVerificationCodeDto);
            return Success(response, "验证码已发送到您的邮箱，请查收");
        }

        /// <summary>
        /// 验证验证码
        /// </summary>
        /// <param name="verifyCodeDto">验证验证码请求</param>
        /// <returns>验证验证码响应</returns>
        [HttpPost("forgot-password/verify-code")]
        [ProducesResponseType(typeof(ApiResponse<VerifyCodeResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeDto verifyCodeDto)
        {
            var response = await _userService.VerifyCodeAsync(verifyCodeDto);
            return Success(response, "验证码验证成功");
        }

        /// <summary>
        /// 重置密码
        /// </summary>
        /// <param name="resetPasswordDto">重置密码请求</param>
        /// <returns>重置密码响应</returns>
        [HttpPost("forgot-password/reset-password")]
        [ProducesResponseType(typeof(ApiResponse<ResetPasswordResponseDto>), 200)]
        [ProducesResponseType(typeof(ApiResponse), 400)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto resetPasswordDto)
        {
            var response = await _userService.ResetPasswordAsync(resetPasswordDto);
            return Success(response);
        }
    }
}