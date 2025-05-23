using System.Text.Json.Serialization;

namespace PregnancyBattle.Api.Models
{
    /// <summary>
    /// API响应模型
    /// </summary>
    /// <typeparam name="T">响应数据类型</typeparam>
    public class ApiResponse<T>
    {
        /// <summary>
        /// 是否成功
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// 消息
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// 错误代码
        /// </summary>
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public string? Code { get; set; }

        /// <summary>
        /// 数据
        /// </summary>
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public T? Data { get; set; }

        public ApiResponse(bool success, string? message, T? data, string? code = null)
        {
            Success = success;
            Message = message;
            Data = data;
            Code = code;
        }

        /// <summary>
        /// 创建成功响应
        /// </summary>
        /// <param name="data">数据</param>
        /// <param name="message">消息</param>
        /// <returns>API响应</returns>
        public static ApiResponse<T> CreateSuccess(T data, string? message = null)
        {
            return new ApiResponse<T>(true, message, data);
        }

        /// <summary>
        /// 创建失败响应
        /// </summary>
        /// <param name="message">错误消息</param>
        /// <param name="code">错误代码</param>
        /// <returns>API响应</returns>
        public static ApiResponse<T> CreateFailure(string message, string? code = null)
        {
            return new ApiResponse<T>(false, message, default, code);
        }
    }

    /// <summary>
    /// API响应模型（无数据）
    /// </summary>
    public class ApiResponse
    {
        /// <summary>
        /// 是否成功
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// 消息
        /// </summary>
        public string? Message { get; set; }

        /// <summary>
        /// 错误代码
        /// </summary>
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public string? Code { get; set; }

        /// <summary>
        /// 创建成功响应
        /// </summary>
        /// <param name="message">消息</param>
        /// <returns>API响应</returns>
        public static ApiResponse CreateSuccess(string? message = null)
        {
            return new ApiResponse
            {
                Success = true,
                Message = message
            };
        }

        /// <summary>
        /// 创建失败响应
        /// </summary>
        /// <param name="message">错误消息</param>
        /// <param name="code">错误代码</param>
        /// <returns>API响应</returns>
        public static ApiResponse CreateFailure(string message, string? code = null)
        {
            return new ApiResponse
            {
                Success = false,
                Message = message,
                Code = code
            };
        }
    }
}
