using System;

namespace PregnancyBattle.Application.Exceptions
{
    /// <summary>
    /// 请求参数无效异常
    /// </summary>
    public class BadRequestException : Exception
    {
        public BadRequestException(string message) : base(message)
        {
        }

        public BadRequestException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
