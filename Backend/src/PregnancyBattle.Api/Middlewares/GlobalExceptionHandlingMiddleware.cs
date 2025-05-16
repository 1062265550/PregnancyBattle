using System;
using System.Net;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using PregnancyBattle.Api.Models;
using PregnancyBattle.Domain.Exceptions;

namespace PregnancyBattle.Api.Middlewares
{
    /// <summary>
    /// 全局异常处理中间件
    /// </summary>
    public class GlobalExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionHandlingMiddleware> _logger;

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="next">请求委托</param>
        /// <param name="logger">日志记录器</param>
        public GlobalExceptionHandlingMiddleware(RequestDelegate next, ILogger<GlobalExceptionHandlingMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        /// <summary>
        /// 调用中间件
        /// </summary>
        /// <param name="context">HTTP上下文</param>
        /// <returns>任务</returns>
        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                await HandleExceptionAsync(context, ex);
            }
        }

        private async Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";
            
            ApiResponse response;
            
            // 根据异常类型设置状态码和响应内容
            switch (exception)
            {
                case BusinessException businessException:
                    // 业务逻辑异常，返回400状态码
                    context.Response.StatusCode = (int)HttpStatusCode.BadRequest;
                    
                    // 只记录警告级别的日志
                    _logger.LogWarning("业务逻辑异常: {Message}", businessException.Message);
                    
                    response = ApiResponse.CreateFailure(businessException.Message, businessException.Code);
                    break;
                
                case UnauthorizedAccessException:
                    // 未授权异常，返回401状态码
                    context.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                    
                    _logger.LogWarning("未授权访问: {Message}", exception.Message);
                    
                    response = ApiResponse.CreateFailure("未授权，请重新登录", "Unauthorized");
                    break;
                
                default:
                    // 其他系统异常，返回500状态码
                    context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                    
                    // 记录详细的错误日志
                    _logger.LogError(exception, "系统异常: {Message}", exception.Message);
                    
                    // 在生产环境中不返回详细的错误信息
                    response = ApiResponse.CreateFailure("服务器错误", "InternalServerError");
                    break;
            }
            
            // 序列化响应
            var jsonResponse = JsonSerializer.Serialize(response);
            
            // 写入响应
            await context.Response.WriteAsync(jsonResponse);
        }
    }
}
