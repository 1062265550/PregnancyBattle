using System;

namespace PregnancyBattle.Domain.Exceptions
{
    /// <summary>
    /// 业务逻辑异常
    /// 用于表示业务逻辑错误，如用户名密码错误、资源不存在等
    /// </summary>
    public class BusinessException : Exception
    {
        /// <summary>
        /// 错误代码
        /// </summary>
        public string Code { get; }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">错误消息</param>
        public BusinessException(string message) : base(message)
        {
            Code = "Business.General";
        }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">错误消息</param>
        /// <param name="code">错误代码</param>
        public BusinessException(string message, string code) : base(message)
        {
            Code = code;
        }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">错误消息</param>
        /// <param name="innerException">内部异常</param>
        public BusinessException(string message, Exception innerException) : base(message, innerException)
        {
            Code = "Business.General";
        }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">错误消息</param>
        /// <param name="code">错误代码</param>
        /// <param name="innerException">内部异常</param>
        public BusinessException(string message, string code, Exception innerException) : base(message, innerException)
        {
            Code = code;
        }
    }
}
