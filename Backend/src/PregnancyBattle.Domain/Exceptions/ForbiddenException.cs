using System;

namespace PregnancyBattle.Domain.Exceptions
{
    /// <summary>
    /// 禁止访问异常
    /// </summary>
    public class ForbiddenException : Exception
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">异常消息</param>
        public ForbiddenException(string message) : base(message)
        {
        }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">异常消息</param>
        /// <param name="innerException">内部异常</param>
        public ForbiddenException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
