using System;

namespace PregnancyBattle.Domain.Exceptions
{
    /// <summary>
    /// 资源不存在异常
    /// </summary>
    public class NotFoundException : Exception
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">异常消息</param>
        public NotFoundException(string message) : base(message)
        {
        }

        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="message">异常消息</param>
        /// <param name="innerException">内部异常</param>
        public NotFoundException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
