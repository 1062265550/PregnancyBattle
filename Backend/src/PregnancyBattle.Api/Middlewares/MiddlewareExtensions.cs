using Microsoft.AspNetCore.Builder;

namespace PregnancyBattle.Api.Middlewares
{
    /// <summary>
    /// 中间件扩展方法
    /// </summary>
    public static class MiddlewareExtensions
    {
        /// <summary>
        /// 使用全局异常处理中间件
        /// </summary>
        /// <param name="builder">应用程序构建器</param>
        /// <returns>应用程序构建器</returns>
        public static IApplicationBuilder UseGlobalExceptionHandling(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<GlobalExceptionHandlingMiddleware>();
        }
    }
}
