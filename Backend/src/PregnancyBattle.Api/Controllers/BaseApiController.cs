using Microsoft.AspNetCore.Mvc;
using PregnancyBattle.Api.Models;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;

namespace PregnancyBattle.Api.Controllers
{
    /// <summary>
    /// API控制器基类
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public abstract class BaseApiController : ControllerBase
    {
        /// <summary>
        /// 从令牌中获取用户ID
        /// </summary>
        /// <returns>用户ID</returns>
        /// <exception cref="System.Security.Authentication.AuthenticationException">当无法从令牌中获取有效的用户ID时抛出</exception>
        protected string GetUserId()
        {
            var userIdClaim = User.FindFirst(JwtRegisteredClaimNames.Sub)
                             ?? User.FindFirst("sub")
                             ?? User.FindFirst(ClaimTypes.NameIdentifier);

            if (userIdClaim != null && !string.IsNullOrEmpty(userIdClaim.Value))
            {
                return userIdClaim.Value;
            }

            var allClaims = User.Claims.Select(c => $"{c.Type}: {c.Value}").ToList();
            Console.WriteLine($"[BaseApiController] 无法获取用户ID。Claims: {string.Join(", ", allClaims)}");
            
            throw new System.Security.Authentication.AuthenticationException("无法从令牌中识别用户身份。");
        }

        /// <summary>
        /// 返回成功响应
        /// </summary>
        /// <typeparam name="T">数据类型</typeparam>
        /// <param name="data">数据</param>
        /// <param name="message">消息</param>
        /// <returns>操作结果</returns>
        protected IActionResult Success<T>(T data, string message = null)
        {
            return Ok(ApiResponse<T>.CreateSuccess(data, message));
        }

        /// <summary>
        /// 返回成功响应（无数据）
        /// </summary>
        /// <param name="message">消息</param>
        /// <returns>操作结果</returns>
        protected IActionResult Success(string message = null)
        {
            return Ok(ApiResponse.CreateSuccess(message));
        }

        /// <summary>
        /// 返回失败响应
        /// </summary>
        /// <param name="message">错误消息</param>
        /// <param name="code">错误代码</param>
        /// <returns>操作结果</returns>
        protected IActionResult Failure(string message, string code = null)
        {
            return BadRequest(ApiResponse.CreateFailure(message, code));
        }

        /// <summary>
        /// 返回失败响应
        /// </summary>
        /// <typeparam name="T">数据类型</typeparam>
        /// <param name="message">错误消息</param>
        /// <param name="code">错误代码</param>
        /// <returns>操作结果</returns>
        protected IActionResult Failure<T>(string message, string code = null)
        {
            return BadRequest(ApiResponse<T>.CreateFailure(message, code));
        }
    }
}